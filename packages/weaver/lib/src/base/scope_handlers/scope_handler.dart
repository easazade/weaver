import 'dart:async';

import 'package:weaver/src/base/scope.dart';

/// [T] is the type of arguments required when entering the scope.
abstract class ScopeHandler<T> {
  bool canHandleScope(final String scopeName);

  Scope<T>? _currentScope;
  Scope<T>? get currentScope => _currentScope;

  Future<void> handle(final HandlerEvent event);

  void dispose();

  Future<void> clearAllRegisteredObjects();

  /// The name of the scope this handler manages.
  String get scopeName;

  Completer<Scope<T>> _currentScopeCompleter = Completer();

  /// This method can be used to wait and ensure for enter scope.
  /// If scope has already entered Returns current scope.
  Future<Scope<T>> ensureEnterScope() async {
    if (currentScope != null) {
      return currentScope!;
    } else {
      return _currentScopeCompleter.future;
    }
  }

  set currentScope(final Scope<T>? scope) {
    if (scope != null) {
      _currentScope = scope;
      _currentScopeCompleter.complete(scope);
    } else {
      _currentScope = null;
      _currentScopeCompleter = Completer();
    }
  }
}
