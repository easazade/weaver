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

/// Defines a **switch** scope: several labeled child entry points, only one active at a time.
///
/// Use with multiple [OnEnterScope] methods, each with a distinct [OnEnterScope.name].
/// `weaver_builder` generates a handler and a scope type with one factory per child
/// (similar to an enum of modes). See [WeaverScope] for ordinary single-entry scopes.
class WeaverSwitchScope {
  /// Parent scope name (used for registration and `leaveScope`).
  final String name;

  const WeaverSwitchScope({required this.name});
}

/// Annotation used to mark a method that should be called when entering a scope.
///
/// Use on a class annotated with [WeaverScope] (single entry) or [WeaverSwitchScope]
/// (one method per child scope; set [name] to distinguish children).
class OnEnterScope {
  final String? name;

  const OnEnterScope({this.name});
}

/// Annotation used to mark a method that should be called when leaving a scope.
///
/// The method should be inside a class annotated with [WeaverScope] or [WeaverSwitchScope].
///
/// **Single scope:** If you omit [OnLeaveScope], the generated handler unregisters
/// dependencies you registered in [OnEnterScope]. If you add [OnLeaveScope], you must
/// unregister (or dispose) those yourself; [NamedDependency] fields are still cleaned up
/// unless [NamedDependency.autoDispose] is `false`.
///
/// **Switch scope:** Same idea per child; omit [OnLeaveScope] for automatic cleanup when
/// switching away from that child.
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
