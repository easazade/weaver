import 'dart:async';

import 'package:weaver/src/base/scope.dart';
import 'package:weaver/src/base/scope_handlers/proxies/scope_handler_weaver_proxy.dart';
import 'package:weaver/src/base/scope_handlers/scope_handler.dart';
import 'package:weaver/src/base/weaver.dart';

abstract class SwitchScopeHandler<T> extends ScopeHandler<T> {
  /// The [Weaver] proxy used to manage dependencies within this scope.
  final ScopeHandlerWeaverProxy weaverInstance;

  SwitchScopeHandler(final Weaver weaver, {this.defaultScope}) : weaverInstance = ScopeHandlerWeaverProxy(weaver);

  final Scope<T>? defaultScope;

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

  @override
  Future<void> handle(final HandlerEvent event) async {
    if (event is EnterScope) {
      if (currentScope != null && currentScope?.name != event.scope.name) {
        final currentScopeName = currentScope!.name;
        _setCurrentScope(null);
        await onLeaveScopeByName(currentScopeName);
      }
      await onEnterScopeByScope(event.scope);
      _setCurrentScope(event.scope as Scope<T>);
    } else if (event is LeaveScope) {
      if (currentScope != null) {
        await onLeaveScopeByName(event.scopeName);
        _setCurrentScope(null);
      }
    } else if (event is HandlerAddedToWeaver) {
      if (currentScope == null && defaultScope != null) {
        await onEnterScopeByScope(defaultScope!);
        _setCurrentScope(defaultScope);
      }
    }

    if (currentScope == null && defaultScope != null) {
      await onEnterScopeByScope(defaultScope!);
      _setCurrentScope(defaultScope);
    }
  }

  void _setCurrentScope(final Scope<T>? scope) {
    if (scope != null) {
      currentScope = scope;
      _currentScopeCompleter.complete(scope);
    } else {
      currentScope = null;
      _currentScopeCompleter = Completer();
    }
  }

  @override
  Future<void> clearAllRegisteredObjects() async {
    weaverInstance.unregisterDependenciesRegisteredByThisProxy();
  }

  Future<void> onLeaveScopeByName(final String name);

  Future<void> onEnterScopeByScope(final Scope scope);

  @override
  void dispose() {}
}
