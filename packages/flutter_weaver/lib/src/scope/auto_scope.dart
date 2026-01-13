import 'package:flutter/widgets.dart';
import 'package:weaver/weaver.dart';

/// A widget that automatically enters a scope when mounted and leaves it when disposed.
///
/// This widget manages the lifecycle of a [Scope] by calling [Weaver.enterScope] in
/// [initState] and [Weaver.leaveScope] in [dispose]. The scope object is provided
/// through the constructor.
///
/// Example:
/// ```dart
/// AutoScope(
///   weaver: weaver,
///   scope: AuthScope(user: currentUser),
///   child: MyAuthenticatedWidget(),
/// )
/// ```
class AutoScope extends StatefulWidget {
  /// The [Weaver] instance to manage scopes with.
  final Weaver weaver;

  /// The [Scope] to enter when mounted and leave when disposed.
  final Scope scope;

  /// The child widget to display.
  final Widget child;

  const AutoScope({
    super.key,
    required this.weaver,
    required this.scope,
    required this.child,
  });

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
