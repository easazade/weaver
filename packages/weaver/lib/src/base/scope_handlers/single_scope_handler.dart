import 'package:weaver/src/base/scope.dart';
import 'package:weaver/src/base/scope_handlers/proxies/scope_handler_weaver_proxy.dart';
import 'package:weaver/src/base/scope_handlers/scope_handler.dart';
import 'package:weaver/src/base/weaver.dart';

/// Manages the lifecycle of dependencies within a specific scope.
///
/// When [Weaver] enters or leaves a scope with a name matching [scopeName],
/// this handler is notified and calls [onEnterScope] or [onLeaveScope] accordingly.
///
/// [T] is the type of arguments required when entering the scope.
abstract class SingleScopeHandler<T> extends ScopeHandler<T> {
  /// The [Weaver] proxy used to manage dependencies within this scope.
  final ScopeHandlerWeaverProxy weaverInstance;

  SingleScopeHandler(final Weaver weaver, {super.changeScopeStream}) : weaverInstance = ScopeHandlerWeaverProxy(weaver);

  /// Handles the scope state transition by checking if the scope is currently active in [weaverInstance].
  @override
  Future<void> handle(final HandlerEvent event) async {
    if (event is EnterScope && currentScope == null) {
      final scope = event.scope;
      if (scope.args != null && scope.args is! T) {
        throw WeaverException(
          'Scope and ScopeHandler that use the same scope-name should '
          'have the same argument type scope argument of type '
          '${scope.args.runtimeType} is not of argument type accepted '
          'by this ScopeHandler which is ${T.runtimeType}. ',
        );
      }

      await onEnterScope(weaverInstance, scope.args);
      currentScope = scope as Scope<T>;
    } else if (event is LeaveScope && currentScope != null) {
      currentScope = null;
      await onLeaveScope(weaverInstance);
    }
  }

  /// Called when the scope is entered. Dependencies should be registered here.
  Future<void> onEnterScope(final Weaver weaver, final T argument);

  /// Called when the scope is left. Cleanup or custom un-registration should happen here.
  Future<void> onLeaveScope(final Weaver weaver);

  @override
  bool canHandleScope(final String scope) => scope == scopeName;

  @override
  Future<void> clearAllRegisteredObjects() => onLeaveScope(weaverInstance);
}
