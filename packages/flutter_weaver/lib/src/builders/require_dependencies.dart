import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:weaver/weaver.dart';

/// A widget that waits for a set of dependencies to be registered before building its child.
///
/// [RequireDependencies] observes the [weaver] instance and rebuilds whenever
/// a dependency is registered or unregistered. It passes an `isReady` flag to the
/// [builder] function, which is true only when all specified [dependencies] are
/// registered and available in [weaver].
///
/// This widget is useful for ensuring that a widget tree is only built when its
/// required dependencies (e.g., Blocs, Services) are ready, avoiding
/// `WeaverException` or null-reference errors.
///
/// Example:
/// ```dart
/// RequireDependencies(
///   weaver: weaver,
///   dependencies: const [
///     DependencyKey(type: UserBloc),
///     DependencyKey(type: SettingsBloc),
///   ],
///   builder: (context, child, isReady) {
///     if (isReady) {
///       return const DashboardPage();
///     } else {
///       return const LoadingIndicator();
///     }
///   },
/// )
/// ```
class RequireDependencies extends StatefulWidget {
  /// The [Weaver] instance to observe for dependency changes.
  final Weaver weaver;

  /// The list of [DependencyKey]s that must be registered for [isReady] to be true.
  final List<DependencyKey> dependencies;

  /// A builder function that is called whenever the dependency state changes.
  ///
  /// - [context]: The build context.
  /// - [child]: The optional [child] widget passed to [RequireDependencies].
  /// - [isReady]: True if all [dependencies] are registered in [weaver].
  final Widget Function(
    BuildContext context,
    Widget? child,
    bool isReady,
  ) builder;

  /// An optional child widget that is passed to the [builder].
  final Widget? child;

  const RequireDependencies({
    super.key,
    required this.weaver,
    required this.dependencies,
    required this.builder,
    this.child,
  });

  @override
  State<RequireDependencies> createState() => _State();
}

class _State extends State<RequireDependencies> {
  bool areDependenciesReady = false;

  @override
  void initState() {
    super.initState();
    widget.weaver.addObserver(_updateReadyState);
    _updateReadyState(callSetState: false);
  }

  @override
  void didUpdateWidget(covariant final RequireDependencies oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.weaver != oldWidget.weaver) {
      oldWidget.weaver.removeObserver(_updateReadyState);
      widget.weaver.addObserver(_updateReadyState);
      _updateReadyState(callSetState: false);
    }
    if (widget.dependencies != oldWidget.dependencies) {
      _updateReadyState(callSetState: false);
    }
  }

  void _updateReadyState({final bool callSetState = true}) {
    var areDependenciesReadyUpdated = true;
    for (final dependency in widget.dependencies) {
      if (!widget.weaver.isRegistered(type: dependency.type, name: dependency.name)) {
        areDependenciesReadyUpdated = false;
        break;
      }
    }

    // if ready state has changed
    if (areDependenciesReadyUpdated != areDependenciesReady) {
      areDependenciesReady = areDependenciesReadyUpdated;
      if (areDependenciesReady) {
        if (kDebugMode) {
          print('👍 Required dependencies are ready : ${widget.dependencies}.');
        }
      } else {
        if (kDebugMode) {
          print(
            '⏳ Required dependencies are NOT ready yet : ${widget.dependencies}, waiting for required dependencies.',
          );
        }
      }
      if (callSetState) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    return widget.builder(context, widget.child, areDependenciesReady);
  }

  @override
  void dispose() {
    widget.weaver.removeObserver(_updateReadyState);
    super.dispose();
  }
}
