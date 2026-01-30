import 'package:weaver/src/base/scope.dart';
import 'package:weaver/src/base/scope_handlers/proxies/scope_handler_weaver_proxy.dart';
import 'package:weaver/src/base/scope_handlers/scope_handler.dart';
import 'package:weaver/src/base/weaver.dart';

abstract class SwitchScopeHandler<T> extends ScopeHandler<T> {
  /// The [Weaver] proxy used to manage dependencies within this scope.
  final ScopeHandlerWeaverProxy weaver;

  SwitchScopeHandler(final Weaver weaver) : weaver = ScopeHandlerWeaverProxy(weaver);

  @override
  Future<void> handle(final ScopeChangeEvent event) async {
    if (event is EnterScope) {
      if (currentScope != null && currentScope?.name != event.scopeName) {
        final currentScopeName = currentScope!.name;
        currentScope = null;
        await onLeaveScopeByName(currentScopeName);
      }
      await onEnterScopeByScope(event.scope);
      currentScope = event.scope as Scope<T>;
    } else if (event is LeaveScope) {
      if (currentScope != null) {
        await onLeaveScopeByName(event.scopeName);
        currentScope = null;
      }
    }
  }

  @override
  Future<void> clearAllRegisteredObjects() async {
    weaver.unregisterDependenciesRegisteredByThisProxy();
  }

  Future<void> onLeaveScopeByName(final String name);
  Future<void> onEnterScopeByScope(final Scope scope);

  @override
  void dispose() {}
}
