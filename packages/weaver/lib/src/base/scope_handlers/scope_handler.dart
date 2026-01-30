/// [T] is the type of arguments required when entering the scope.
abstract class ScopeHandler<T> {
  bool canHandleScope(final String scopeName);

  Future<void> handle() async {}

  void dispose();

  Future<void> leaveScope();

  /// The name of the scope this handler manages.
  String get scopeName;
}
