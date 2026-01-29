/// Annotation used to define a scope for dependencies.
///
/// Scopes allow grouping dependencies that should only exist during a specific
/// part of the application lifecycle (e.g., while a user is logged in).
///
/// Classes annotated with `@WeaverScope` are used by `weaver_builder` to generate
/// scope handlers and scope accessors.
class WeaverScope {
  /// The unique name of the scope.
  final String name;

  const WeaverScope({required this.name});
}

/// Annotation used to mark a method that should be called when entering a scope.
///
/// The method should be inside a class annotated with `@WeaverScope`.
/// It is responsible for registering dependencies specific to that scope.
class OnEnterScope {
  final String? name;

  const OnEnterScope({this.name});
}

/// Annotation used to mark a method that should be called when leaving a scope.
///
/// The method should be inside a class annotated with `@WeaverScope`.
/// It is responsible for unregistering dependencies or performing cleanup.
/// If not provided, Weaver handles unregistering dependencies automatically.
class OnLeaveScope {
  final String? name;

  const OnLeaveScope({this.name});
}

/// Annotation used to define a named dependency within a scope or session.
///
/// This allows registering multiple instances of the same type and generating
/// type-safe accessors methods for them.
class NamedDependency {
  /// The unique name for this dependency instance.
  final String name;

  /// Whether the dependency should be automatically disposed when the scope is left.
  /// Defaults to true.
  final bool autoDispose;

  /// Creates a [NamedDependency] with the given [name] and [autoDispose] flag.
  const NamedDependency({
    required this.name,
    this.autoDispose = true,
  });
}

/// Annotation used to define a session for grouping dependencies.
///
/// Sessions allow registering and clearing a set of related dependencies
/// incrementally as a workflow progresses (e.g., a checkout process).
class WeaverSession {
  /// The unique name of the session.
  final String name;

  /// Creates a [WeaverSession] with the given [name].
  const WeaverSession({required this.name});
}
