import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:weaver/weaver.dart';

class RequireDependencies extends StatefulWidget {
  final Weaver weaver;
  final List<DependencyKey> dependencies;
  final Widget Function(
    BuildContext context,
    Widget? child,
    bool isReady,
  ) builder;
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
