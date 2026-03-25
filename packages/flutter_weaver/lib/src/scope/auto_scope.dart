import 'package:flutter/widgets.dart';
import 'package:weaver/weaver.dart' hide weaver;
import 'package:weaver/weaver.dart' as wv show weaver;

/// A widget that automatically manages the lifecycle of a [Scope].
///
/// [AutoScope] enters the provided [scope] when the widget is mounted and
/// leaves it when the widget is disposed. This ensures that dependencies
/// defined within the scope are only available while this widget (or its subtree)
/// is part of the widget tree.
///
/// Omit [weaver] to use the default `weaver` from `package:weaver/weaver.dart`.
///
/// This is particularly useful for tying dependencies to specific routes or
/// features in a Flutter application.
///
/// Example:
/// ```dart
/// AutoScope(
///   scope: ProductDetailScope(productId: 123),
///   child: ProductDetailPage(),
/// )
/// ```
class AutoScope extends StatefulWidget {
  /// The [Weaver] instance used to manage the scope.
  ///
  /// When omitted, the default `weaver` from `package:weaver/weaver.dart` is used.
  final Weaver weaver;

  /// The [Scope] to enter when mounted and leave when disposed.
  final Scope scope;

  /// The child widget that will have access to the scoped dependencies.
  final Widget child;

  /// Creates an [AutoScope] widget.
  AutoScope({
    super.key,
    final Weaver? weaver,
    required this.scope,
    required this.child,
  }) : weaver = weaver ?? wv.weaver;

  @override
  State<AutoScope> createState() => _AutoScopeState();
}

class _AutoScopeState extends State<AutoScope> {
  @override
  void initState() {
    super.initState();
    // Note: enterScope is async but we can't await in initState.
    // The scope handler will handle the async operations.
    widget.weaver.enterScope(widget.scope);
  }

  @override
  void dispose() {
    // Note: leaveScope is async but we can't await in dispose.
    // The scope handler will handle the async operations.
    widget.weaver.leaveScope(widget.scope.name);
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return widget.child;
  }
}
