import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:weaver/di/base/dependency.dart';
import 'package:weaver/di/base/scope_registry.dart';
import 'package:weaver/di/utils/log.dart';

final weaver = Weaver();

/// [Weaver] stand for dependency injection. It is a class responsible for
/// managing dependencies and dependency scopes.
class Weaver extends ChangeNotifier {
  Weaver();

  final _dependencies = <Type, Dependency>{};
  final List<_ScopeRegistryBundle> _scopeRegistryBundles = [];
  var allowReassignment = false;

  void register<T extends Object>(final T instance) {
    log('Registering object of type $T');

    if (isRegistered<T>() && !allowReassignment) {
      throw DIException(
        'Cannot register object of type $T because there is an instance already registered',
      );
    }
    if (_dependencies.containsKey(T)) {
      final dependency = (_dependencies[T]! as Dependency<T>);
      dependency.setValue(instance);
    } else {
      _dependencies[T] = Dependency<T>(instance);
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
      return _dependencies.containsKey(t) && _dependencies[t]?.value != null;
    }
    return _dependencies.containsKey(T) && _dependencies[T]?.value != null;
  }

  T get<T extends Object>() {
    if (isRegistered<T>()) {
      return _dependencies[T]!.value;
    } else {
      throw DIException('There is no instance of $T registered');
    }
  }

  Future<T> getAsync<T extends Object>() async {
    if (isRegistered<T>()) {
      return get<T>();
    } else {
      if (!_dependencies.containsKey(T)) {
        _dependencies[T] = Dependency<T>(null);
      }

      return (_dependencies[T]! as Dependency<T>).completer.future;
    }
  }

  Future<void> addScopeRegistry(final ScopeRegistry scopeRegistry) async {
    final alreadyRegistered = _scopeRegistryBundles.firstWhereOrNull(
            (final e) => e.scopeRegistry.name == scopeRegistry.name) !=
        null;

    if (alreadyRegistered && !allowReassignment) {
      throw DIException(
        'Cannot register ScopeRegistry with name ${scopeRegistry.name}, since one is already registered',
      );
    }

    void listener() {
      _checkAndUpdateScopeFrom(scopeRegistry);
    }

    scopeRegistry.isInScope.addListener(listener);

    final scopeRegistryBundle = _ScopeRegistryBundle(
      scopeRegistry: scopeRegistry,
      listener: listener,
    );

    _scopeRegistryBundles.add(scopeRegistryBundle);
    await _checkAndUpdateScopeFrom(scopeRegistry);
  }

  Future<void> removeScopeRegistry(final String scopeName) async {
    final bundle = _scopeRegistryBundles.firstWhereOrNull(
        (final bundle) => bundle.scopeRegistry.name == scopeName);
    if (bundle != null) {
      bundle.scopeRegistry.isInScope.removeListener(bundle.listener);
      await bundle.scopeRegistry.unregister(this);
      _scopeRegistryBundles.removeWhere(
        (final bundle) => bundle.scopeRegistry.name == scopeName,
      );
      bundle.scopeRegistry.dispose();
    }
  }

  Future<void> _checkAndUpdateScopeFrom(
    final ScopeRegistry scopeRegistry,
  ) async {
    if (scopeRegistry.isInScope.value) {
      await scopeRegistry.register(this);
    } else {
      await scopeRegistry.unregister(this);
    }
  }

  /// Deletes all registered dependencies and all scope registries
  void reset() {
    _dependencies.clear();
    _scopeRegistryBundles.clear();
  }
}

class _ScopeRegistryBundle {
  final ScopeRegistry scopeRegistry;
  final void Function() listener;

  _ScopeRegistryBundle({required this.scopeRegistry, required this.listener});
}

class DIException implements Exception {
  DIException(this.message) {
    // Since in web sometimes uncaught exception do not get logged correctly
    if (kIsWeb) {
      log(message);
    }
  }

  final String message;

  @override
  String toString() => message;
}
