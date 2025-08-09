import 'package:collection/collection.dart';
import 'package:weaver/weaver.dart';

enum ScopeHandlerState { entered, left }

/// Defines a scope in which existence of dependencies are tied to
///
/// For example if it is required for some dependencies to exist only after
/// authentication and be disposed of when user unauthenticated. this scope can
/// be defined as auth scope.
///
/// [Weaver] class can enter or leave scopes, eg: auth scope.
/// When that happens, if a ScopeHandler is registered in [Weaver] class. it will
/// be notified to register or unregister dependencies.
///
abstract class Scope<T> {
  Scope({required this.name, this.argument});

  final String name;
  final T? argument;
}

/// manages dependencies under it's [scopeName]. If [Weaver] class enters/leaves a scope
/// with the same scope name of this class. This handler will be notified and calls
/// onEnterScope/onLeaveScope callbacks accordingly.
///
/// When defining ScopeHandler class, It is also needed to define a Scope class as well
/// which both classes should have the same generic argument type for the scope argument.
///
/// [dispose] method can be overridden to handle disposing this class id needed.
/// It will be called by [Weaver] class when this [ScopeHandler] instance is being
/// removed from [Weaver] class.
abstract class ScopeHandler<T> {
  String get scopeName;

  var scopeHandlerState = ScopeHandlerState.left;

  void handle(final Weaver weaver) {
    final scope = weaver.scopes
        .firstWhereOrNull((final scope) => scope.name == scopeName);
    final isInScope = scope != null;

    if (isInScope && scopeHandlerState == ScopeHandlerState.left) {
      scopeHandlerState = ScopeHandlerState.entered;
      if (scope.argument != null && scope.argument is! T) {
        throw WeaverException(
          'Scope and ScopeHandler that use the same scope-name should '
          'have the same argument type scope argument of type '
          '${scope.argument.runtimeType} is not of argument type accepted '
          'by this ScopeHandler which is ${T.runtimeType}. ',
        );
      }

      onEnterScope(weaver, scope.argument as T?);
    } else if (!isInScope && scopeHandlerState == ScopeHandlerState.entered) {
      onLeaveScope(weaver);
      scopeHandlerState = ScopeHandlerState.left;
    }
  }

  Future<void> onEnterScope(final Weaver weaver, final T? argument);

  Future<void> onLeaveScope(final Weaver weaver);

  void dispose() {}
}
