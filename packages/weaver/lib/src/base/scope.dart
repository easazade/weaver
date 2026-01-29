import 'package:collection/collection.dart';
import 'package:weaver/weaver.dart';

/// Represents the state of a [ScopeHandler].
enum ScopeState { entered, left }

/// Defines a scope that holds dependencies tied to a specific lifecycle.
///
/// For example, some dependencies may only need to exist after authentication
/// and should be disposed of when the user logs out. This would be defined as
/// an "auth" scope.
///
/// [Weaver] can enter or leave scopes. When entering a scope, if a corresponding
/// [ScopeHandler] is registered, it will be notified to register the dependencies.
abstract class Scope<T> {
  /// Creates a [Scope] with a unique [name] and optional [args].
  Scope({required this.name, required this.args});

  /// The unique name identifying this scope.
  final String name;

  /// The arguments passed to the scope when entering it.
  final T args;
}

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
