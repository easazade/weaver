class WeaverScope {
  final String name;

  const WeaverScope({required this.name});
}

class OnEnterScope {
  const OnEnterScope();
}

class OnLeaveScope {
  const OnLeaveScope();
}

class NamedDependency {
  final String name;
  final bool autoDispose;

  const NamedDependency({
    required this.name,
    this.autoDispose = true,
  });
}

class WeaverSession {
  final String name;

  const WeaverSession({required this.name});
}
