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
