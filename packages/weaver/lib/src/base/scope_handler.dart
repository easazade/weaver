import 'package:collection/collection.dart';
import 'package:weaver/src/base/proxy_weavers/scope_handler_weaver_proxy.dart';
import 'package:weaver/src/base/weaver.dart';

/// Represents the state of a [ScopeHandler].
enum ScopeState { entered, left }

/// Manages the lifecycle of dependencies within a specific scope.
///
/// When [Weaver] enters or leaves a scope with a name matching [scopeName],
/// this handler is notified and calls [onEnterScope] or [onLeaveScope] accordingly.
///
/// [T] is the type of arguments required when entering the scope.
abstract class ScopeHandler<T> {
  /// The [Weaver] proxy used to manage dependencies within this scope.
  final ScopeHandlerWeaverProxy weaver;

  ScopeHandler(final Weaver weaver) : weaver = ScopeHandlerWeaverProxy(weaver);

  /// The name of the scope this handler manages.
  String get scopeName;

  /// The current state of the scope (entered or left).
  var scopeState = ScopeState.left;

  /// Handles the scope state transition by checking if the scope is currently active in [weaver].
  Future<void> handle() async {
    final scope = weaver.scopes.firstWhereOrNull((final scope) => scope.name == scopeName);
    final isInScope = scope != null;

    if (isInScope && scopeState == ScopeState.left) {
      if (scope.args != null && scope.args is! T) {
        throw WeaverException(
          'Scope and ScopeHandler that use the same scope-name should '
          'have the same argument type scope argument of type '
          '${scope.args.runtimeType} is not of argument type accepted '
          'by this ScopeHandler which is ${T.runtimeType}. ',
        );
      }

      scopeState = ScopeState.entered;
      await onEnterScope(weaver, scope.args as T);
    } else if (!isInScope && scopeState == ScopeState.entered) {
      await onLeaveScope(weaver);
      scopeState = ScopeState.left;
    }
  }

  /// Called when the scope is entered. Dependencies should be registered here.
  Future<void> onEnterScope(final Weaver weaver, final T argument);

  /// Called when the scope is left. Cleanup or custom un-registration should happen here.
  Future<void> onLeaveScope(final Weaver weaver);

  bool canHandleScope(final String scope) => scope == scopeName;

  /// Called when the [ScopeHandler] is being removed from [Weaver].
  void dispose() {}
}
