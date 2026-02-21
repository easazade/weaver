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

  @override
  Future<void> handle(final HandlerEvent event) async {
    if (event is EnterScope) {
      if (currentScope != null && currentScope?.name != event.scope.name) {
        final currentScopeName = currentScope!.name;
        currentScope = null;
        await onLeaveScopeByName(currentScopeName);
      }
      await onEnterScopeByScope(event.scope);
      currentScope = event.scope as Scope<T>;
    } else if (event is LeaveScope) {
      if (currentScope != null) {
        currentScope = null;
        await onLeaveScopeByName(event.scopeName);
      }
    } else if (event is HandlerAddedToWeaver) {
      if (currentScope == null && defaultScope != null) {
        await onEnterScopeByScope(defaultScope!);
        currentScope = defaultScope;
      }
    }

    if (currentScope == null && defaultScope != null) {
      await onEnterScopeByScope(defaultScope!);
      currentScope = defaultScope;
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
