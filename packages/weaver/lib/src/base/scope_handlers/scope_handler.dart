import 'package:weaver/src/base/scope.dart';

/// [T] is the type of arguments required when entering the scope.
abstract class ScopeHandler<T> {
  bool canHandleScope(final String scopeName);

  Scope<T>? currentScope;

  Future<void> handle(final HandlerEvent event);

  void dispose();

  Future<void> clearAllRegisteredObjects();

  /// The name of the scope this handler manages.
  String get scopeName;
}
