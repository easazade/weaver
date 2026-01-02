import 'dart:async';

import 'package:collection/collection.dart';
import 'package:weaver/src/base/named.dart';
import 'package:weaver/src/utils/log.dart';
import 'package:weaver/src/utils/observable.dart';

import 'dependency.dart';
import 'scope.dart';

/// default instance of [Weaver]
final weaver = Weaver();

/// [Weaver] stand for dependency injection. It is a class responsible for
/// managing dependencies and dependency scopes.
class Weaver extends Observable {
  Weaver();

  final _dependencies = <DependencyKey, Dependency>{};
  final _scopeHandlers = <ScopeHandler>[];
  final _scopes = <Scope>{};
  late final named = WeaverNamed(weaverInstance: this);

  Iterable<Scope> get scopes => _scopes;
  var allowReassignment = false;

  void register<T extends Object>(final T instance, {final String? name}) {
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
    if (_dependencies.containsKey(dependencyKey)) {
      final dependency = (_dependencies[dependencyKey]! as Dependency<T>);
      dependency.value = instance;
    } else {
      _dependencies[dependencyKey] = Dependency<T>.value(instance);
    }
    notifyObservers();
  }

  void unregister<T extends Object>({final String? name}) {
    if (T.toString() == 'Object') {
      if (name != null) {
        _dependencies.removeWhere((final dependencyKey, final _) => dependencyKey.name == name);
        notifyObservers();
      } else {
        throw WeaverException(
          'When Unregistering an object using unregister method. at least either '
          'name or type of the dependency object should be specified.\n'
          'eg: weaver.unregister<TYPE>() | weaver.unregister(name: "dependency-name")\n',
        );
      }
    } else {
      final dependencyKey = DependencyKey(type: T, name: name);
      if (isRegistered<T>(name: name)) {
        _dependencies.remove(dependencyKey);
      }
      notifyObservers();
    }
  }

  bool isRegistered<T extends Object>({final Type? type, final String? name}) {
    if (type == null && T.toString() == 'Object') {
      return _dependencies.keys.firstWhereOrNull((final key) => key.name == name) != null;
    }

    if (type != null) {
      final dependencyKey = DependencyKey(type: type, name: name);
      return _dependencies.containsKey(dependencyKey) && _dependencies[dependencyKey]!.hasValue;
    }
    final dependencyKey = DependencyKey(type: T, name: name);
    return _dependencies.containsKey(dependencyKey) && _dependencies[dependencyKey]!.hasValue;
  }

  void registerLazy<T extends Object>(final T Function() callback, {final String? name}) {
    final dependencyKey = DependencyKey(type: T, name: name);

    log('Registering object with $dependencyKey');

    if (isRegistered<T>() && !allowReassignment) {
      throw WeaverException(
        'Cannot register object of $dependencyKey because there is an instance already registered',
      );
    }

    if (_dependencies.containsKey(dependencyKey)) {
      final dependency = (_dependencies[dependencyKey]! as Dependency<T>);
      dependency.lazyInstantiateCallback = callback;
    } else {
      _dependencies[dependencyKey] = Dependency<T>.lazy(callback);
    }

    notifyObservers();
  }

  T get<T extends Object>({final String? name}) {
    final dependencyKey = DependencyKey(type: T, name: name);
    if (isRegistered<T>(name: name)) {
      final dependency = _dependencies[dependencyKey]! as Dependency<T>;
      if (dependency.value == null && dependency.lazyInstantiateCallback != null) {
        dependency.value = dependency.lazyInstantiateCallback!();
      }

      return dependency.value!;
    } else {
      var message = 'There is no instance of $dependencyKey registered.';

      final matchKeyForOnlyType = _dependencies.entries.map((final entry) {
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
      if (!_dependencies.containsKey(dependencyKey)) {
        _dependencies[dependencyKey] = Dependency<T>.placeHolder();
      }

      return (_dependencies[dependencyKey]! as Dependency<T>).completer.future;
    }
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
    _dependencies.clear();
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
