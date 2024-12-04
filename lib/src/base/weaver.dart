import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:weaver/src/base/dependency.dart';
import 'package:weaver/src/base/weaver_scope.dart';
import 'package:weaver/src/utils/log.dart';

final weaver = Weaver();

/// [Weaver] stand for dependency injection. It is a class responsible for
/// managing dependencies and dependency scopes.
class Weaver extends ChangeNotifier {
  Weaver();

  final _dependencies = <Type, Dependency>{};
  final _scopeHandlers = <ScopeHandler>[];
  final _scopes = <Scope>{};

  Iterable<Scope> get scopes => _scopes;
  var allowReassignment = false;

  void registerLazy<T extends Object>(final T Function() callback) {
    log('Registering object of type $T');

    if (isRegistered<T>() && !allowReassignment) {
      throw WeaverException(
        'Cannot register object of type $T because there is an instance already registered',
      );
    }

    if (_dependencies.containsKey(T)) {
      final dependency = (_dependencies[T]! as Dependency<T>);
      dependency.lazyInstantiateCallback = callback;
    } else {
      _dependencies[T] = Dependency<T>.lazy(callback);
    }

    notifyListeners();
  }

  void register<T extends Object>(final T instance) {
    log('Registering object of type $T');

    if (isRegistered<T>() && !allowReassignment) {
      throw WeaverException(
        'Cannot register object of type $T because there is an instance already registered',
      );
    }
    if (_dependencies.containsKey(T)) {
      final dependency = (_dependencies[T]! as Dependency<T>);
      dependency.value = instance;
    } else {
      _dependencies[T] = Dependency<T>.value(instance);
    }
    notifyListeners();
  }

  void unregister<T extends Object>() {
    if (isRegistered<T>()) {
      _dependencies.remove(T);
    }
    notifyListeners();
  }

  bool isRegistered<T extends Object>([final Type? t]) {
    if (t != null) {
      return _dependencies.containsKey(t) && _dependencies[t]!.hasValue;
    }
    return _dependencies.containsKey(T) && _dependencies[T]!.hasValue;
  }

  T get<T extends Object>() {
    if (isRegistered<T>()) {
      final dependency = _dependencies[T]! as Dependency<T>;
      if (dependency.value == null &&
          dependency.lazyInstantiateCallback != null) {
        dependency.value = dependency.lazyInstantiateCallback!();
      }

      return dependency.value!;
    } else {
      throw WeaverException('There is no instance of $T registered');
    }
  }

  Future<T> getAsync<T extends Object>() async {
    if (isRegistered<T>()) {
      return get<T>();
    } else {
      if (!_dependencies.containsKey(T)) {
        _dependencies[T] = Dependency<T>.placeHolder();
      }

      return (_dependencies[T]! as Dependency<T>).completer.future;
    }
  }

  bool hasEnteredScope(final String scopeName) =>
      scopes.firstWhereOrNull((final e) => e.name == scopeName) != null;

  void enterScope(final Scope scope) {
    if (hasEnteredScope(scope.name)) {
      throw WeaverException(
        'Has already entered scope <${scope.name}>, '
        'cannot call method weaver.enterScope on this scope again',
      );
    }

    _scopes.add(scope);
    for (final scopeHandler in _scopeHandlers) {
      scopeHandler.handle(this);
    }
  }

  void leaveScope(final String scopeName) {
    if (hasEnteredScope(scopeName)) {
      _scopes.removeWhere((final e) => e.name == scopeName);
      for (final scopeHandler in _scopeHandlers) {
        scopeHandler.handle(this);
      }
    }
  }

  Future<void> addScopeHandler(final ScopeHandler handler) async {
    final alreadyAdded = _scopeHandlers
            .firstWhereOrNull((final e) => e.scopeName == handler.scopeName) !=
        null;

    if (alreadyAdded && !allowReassignment) {
      throw WeaverException(
        'Cannot add ScopeHandler with name ${handler.scopeName}, since one is already added',
      );
    }

    _scopeHandlers.add(handler);
    handler.handle(this);
  }

  Future<void> removeScopeHandler(final String scopeName) async {
    final handler = _scopeHandlers
        .firstWhereOrNull((final handler) => handler.scopeName == scopeName);

    if (handler != null) {
      _scopeHandlers.removeWhere((final e) => e.scopeName == scopeName);
      await handler.onLeaveScope(this);
      handler.scopeHandlerState = ScopeHandlerState.left;
      handler.dispose();
    }
  }

  /// Deletes all registered dependencies and all scope registries
  void reset() {
    _dependencies.clear();
    _scopes.clear();
    _scopeHandlers.clear();
  }
}

class WeaverException implements Exception {
  WeaverException(this.message) {
    // Since in web sometimes uncaught exception do not get logged correctly
    if (kIsWeb) {
      log(message);
    }
  }

  final String message;

  @override
  String toString() => message;
}
