import 'dart:async';

import 'package:collection/collection.dart';
import 'package:weaver/src/base/dependency_map.dart';
import 'package:weaver/src/base/named.dart';
import 'package:weaver/src/utils/log.dart';
import 'package:weaver/src/utils/observable.dart';

import 'dependency.dart';
import 'scope.dart';

/// default instance of [Weaver]
final weaver = Weaver();

/// [Weaver] is the main class of this library. Manages all dependency objects,
/// scopes, scope-handlers, sessions and so on
///
/// All changes can be observer by adding an observer using [addObserver] method.
class Weaver extends Observable {
  Weaver();

  final _dependencyMap = DependencyMap();
  final _scopeHandlers = <ScopeHandler>[];
  final _scopes = <Scope>{};
  late final named = WeaverNamed(weaverInstance: this);

  Iterable<Scope> get scopes => _scopes;
  var allowReassignment = false;

  void register<T extends Object>(final T instance, {final String? name, final String? session}) {
    if (T.toString() == 'Object') {
      throw WeaverException('T is Object. Cannot register object of the exact type of "Object"');
    }
    log('Registering object of type $T');

    final dependencyKey = DependencyKey(type: T, name: name);

    if (isRegistered<T>() && !allowReassignment) {
      throw WeaverException(
        'Cannot register object of $dependencyKey because there is an instance already registered',
      );
    }
    if (_dependencyMap.containsKey(dependencyKey)) {
      final dependency = (_dependencyMap.find(dependencyKey)! as Dependency<T>);
      dependency.value = instance;
    } else {
      _dependencyMap.set(dependencyKey, Dependency<T>.value(instance), session: session);
    }
    notifyObservers();
  }

  /// unregisters an already registered dependency object by its type or name
  ///
  /// the type of the object that is needed to be unregistered can be passed both using value arguments or
  /// generic arguments.
  void unregister<T extends Object>({Type? type, final String? name}) {
    if (type != null && T.toString() != 'Object' && type.toString() != T.toString()) {
      throw WeaverException(
        'calling unregister argument and passing conflicting arguments for the type of the '
        'object that needs to be unregistered is forbidden!, please specify the type correctly only using'
        'generic type argument or value argument. eg: either call weaver.unregister<TYPE>() or weaver.unregister(type: type). '
        'calling weaver.unregister<TYPE_1>(type: TYPE_2) is forbidden',
      );
    }
    type = type ?? T;

    if (name == null && type.toString() == 'Object') {
      throw WeaverException(
        'Type or name is required to unregister the dependency object. passed type of "$type" is not accepted',
      );
    } else if (name != null && type.toString() == 'Object') {
      _dependencyMap.removeWhere((final dependencyKey) => dependencyKey.name == name);
      notifyObservers();
    } else {
      final dependencyKey = DependencyKey(type: type, name: name);
      if (isRegistered(type: type, name: name)) {
        _dependencyMap.remove(dependencyKey);
      } else {
        log('⚠️ Tried to unregister an object that is not registered. '
            'There is no object registered with type: $type ${name != null ? "and name:$name" : ""}');
      }
      notifyObservers();
    }
  }

  bool isRegistered<T extends Object>({Type? type, final String? name}) {
    type = type ?? T;

    if (type.toString() == 'Object') {
      return _dependencyMap.keys.firstWhereOrNull((final key) => key.name == name) != null;
    } else {
      final dependencyKey = DependencyKey(type: type, name: name);
      return _dependencyMap.containsKey(dependencyKey) && _dependencyMap.hasValue(dependencyKey);
    }
  }

  void registerLazy<T extends Object>(final T Function() callback, {final String? name}) {
    final dependencyKey = DependencyKey(type: T, name: name);

    log('Registering object with $dependencyKey');

    if (isRegistered<T>() && !allowReassignment) {
      throw WeaverException(
        'Cannot register object of $dependencyKey because there is an instance already registered',
      );
    }

    if (_dependencyMap.containsKey(dependencyKey)) {
      final dependency = (_dependencyMap.find(dependencyKey)! as Dependency<T>);
      dependency.value = null;
      dependency.lazyInstantiateCallback = callback;
    } else {
      _dependencyMap.set(dependencyKey, Dependency<T>.lazy(callback));
    }

    notifyObservers();
  }

  T get<T extends Object>({final String? name}) {
    final dependencyKey = DependencyKey(type: T, name: name);
    if (isRegistered<T>(name: name)) {
      final dependency = _dependencyMap.find(dependencyKey)! as Dependency<T>;
      if (dependency.value == null && dependency.lazyInstantiateCallback != null) {
        dependency.value = dependency.lazyInstantiateCallback!();
      }

      return dependency.value!;
    } else {
      var message = 'There is no instance of $dependencyKey registered.';

      final matchKeyForOnlyType = _dependencyMap.entries.map((final entry) {
        final key = entry.key;
        final registeredValue = entry.value.value;
        if (key.type == T && key.name != null && registeredValue != null) {
          return key;
        } else {
          return null;
        }
      }).nonNulls;

      if (matchKeyForOnlyType.isNotEmpty) {
        message = '$message But there are named dependencies registered with this type: $matchKeyForOnlyType. '
            'To retrieve named registered named objects you must pass both type & name when calling weaver.get()';
      }

      throw WeaverException(message);
    }
  }

  Future<T> getAsync<T extends Object>({final String? name}) async {
    if (isRegistered<T>(name: name)) {
      return get<T>(name: name);
    } else {
      final dependencyKey = DependencyKey(type: T, name: name);
      if (!_dependencyMap.containsKey(dependencyKey)) {
        _dependencyMap.set(dependencyKey, Dependency<T>.placeHolder());
      }

      return (_dependencyMap.find(dependencyKey)! as Dependency<T>).completer.future;
    }
  }

  /// Removes all dependency objects registered under given [session] name.
  void clearSession(final String session) {
    _dependencyMap.removeBySession(session);
  }

  bool isInScope(final String scopeName) => scopes.firstWhereOrNull((final e) => e.name == scopeName) != null;

  Future<void> enterScope(final Scope scope) async {
    if (isInScope(scope.name)) {
      throw WeaverException(
        'Has already entered scope <${scope.name}>, '
        'cannot call method weaver.enterScope on this scope again',
      );
    }

    final noHandlerAvailableToHandle = _scopeHandlers.where((final e) => e.scopeName == scope.name).isEmpty;
    if (noHandlerAvailableToHandle) {
      throw WeaverException(
        'Entered scope ${scope.name} but there is no scope handler to handle this scope. '
        'please register a ScopeHandler class that handles scope: ${scope.name} using addScopeHandler() method.',
      );
    }

    _scopes.add(scope);

    // make scope handlers to handle the change in scopes (new scope added)
    for (final scopeHandler in _scopeHandlers) {
      await scopeHandler.handle(this);
    }

    notifyObservers();
  }

  Future<void> leaveScope(final String scopeName) async {
    if (isInScope(scopeName)) {
      _scopes.removeWhere((final e) => e.name == scopeName);
      // make scope handlers to handle the change in scopes
      for (final scopeHandler in _scopeHandlers) {
        await scopeHandler.handle(this);
      }
      notifyObservers();
    }
  }

  /// Adds a [ScopeHandler] instance and weaver which will handle scope changes
  Future<void> addScopeHandler(final ScopeHandler handler) async {
    final alreadyAdded = _scopeHandlers.firstWhereOrNull((final e) => e.scopeName == handler.scopeName) != null;

    if (alreadyAdded && !allowReassignment) {
      throw WeaverException(
        'Cannot add ScopeHandler with name ${handler.scopeName}, since one is already added',
      );
    } else if (allowReassignment) {
      _scopeHandlers.removeWhere((final e) => e.scopeName == handler.scopeName);
    }

    _scopeHandlers.add(handler);
    await handler.handle(this);
  }

  /// Removes the [ScopeHandler] instance that handles the scope with name [scopeName].
  /// NOTE: this method only removes the [ScopeHandler] but does not leaves the scope with name [scopeName]
  /// for that leaveScope method must be called.
  Future<void> removeScopeHandler(final String scopeName) async {
    final handler = _scopeHandlers.firstWhereOrNull((final handler) => handler.scopeName == scopeName);

    if (handler != null) {
      _scopeHandlers.removeWhere((final e) => e.scopeName == scopeName);

      // not calling handler.handle since the scope might not be left yet.
      await handler.onLeaveScope(this);
      handler.scopeState = ScopeState.left;
      handler.dispose();
    }
  }

  /// Deletes all registered dependencies and Removes all current scopes.
  /// Deletes and disposes all scope handlers.
  void reset() {
    _dependencyMap.clear();
    _scopes.clear();
    for (final handler in _scopeHandlers) {
      handler.dispose();
    }
    _scopeHandlers.clear();
  }
}

class WeaverException implements Exception {
  WeaverException(this.message) {
    // Since in web sometimes uncaught exception do not get logged correctly
    // if (kIsWeb) {
    // log(message);
    // }
  }

  final String message;

  @override
  String toString() => '\n\n⛔ $message';
}
