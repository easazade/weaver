import 'package:weaver/src/base/scope_handlers/proxies/scope_handler_weaver_proxy.dart';
import 'package:weaver/src/base/scope_handlers/scope_handler.dart';
import 'package:weaver/src/base/weaver.dart';

abstract class MultiScopeHandler<T> extends ScopeHandler<T> {
  /// The [Weaver] proxy used to manage dependencies within this scope.
  final ScopeHandlerWeaverProxy weaver;

  MultiScopeHandler(final Weaver weaver) : weaver = ScopeHandlerWeaverProxy(weaver);

  String? currentScopeName;

  @override
  Future<void> handle() async {
    // get a list of current entered scopes in weaver which this class can handle
    final currentScopes = weaver.scopes.where((final scope) => canHandleScope(scope.name));
    if (currentScopeName != null &&
        (currentScopes.isEmpty || currentScopes.length > 1 || currentScopes.firstOrNull?.name != currentScopeName)) {
      await leaveScopeByName(currentScopeName!);
      currentScopeName = null;
    }
  }

  @override
  Future<void> leaveScope() async {
    weaver.unregisterDependenciesRegisteredByThisProxy();
  }

  Future<void> leaveScopeByName(final String name);
  Future<void> enterScopeByName(final String name);

  @override
  void dispose() {}
}
