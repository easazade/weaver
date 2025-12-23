import 'package:flutter/material.dart';
import 'package:flutter_weaver/flutter_weaver.dart';

/// A wrapper test class that provides testing functionality for [RequireDependencies] widget
/// to provide/change weaver instance for child widgets
/// Also allow providing/changing required dependencies
class RequireDependenciesTester extends StatefulWidget {
  final Weaver weaver;
  final List<DependencyKey> dependencies;
  final Widget Function(BuildContext context, Widget? child, bool isReady) builder;
  final RequireDependenciesTesterController controller;

  const RequireDependenciesTester({
    super.key,
    required this.controller,
    required this.weaver,
    required this.dependencies,
    required this.builder,
  });

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<RequireDependenciesTester> {
  late Weaver _weaver;
  late List<DependencyKey> _dependencies;

  @override
  void initState() {
    super.initState();
    _weaver = widget.weaver;
    _dependencies = widget.dependencies;
    widget.controller._state = this;
  }

  @override
  void didUpdateWidget(covariant final RequireDependenciesTester oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller._state = null;
      widget.controller._state = this;
    }
  }

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      home: RequireDependencies(
        weaver: _weaver,
        dependencies: _dependencies,
        builder: widget.builder,
      ),
    );
  }

  void changeWeaverInstance(final Weaver weaver) {
    setState(() {
      _weaver = weaver;
    });
  }

  void changeDependencies(final List<DependencyKey> dependencies) {
    setState(() {
      _dependencies = dependencies;
    });
  }
}

class RequireDependenciesTesterController {
  _State? _state;

  void changeWeaverInstance(final Weaver weaver) {
    _state?.changeWeaverInstance(weaver);
  }

  void changeDependencies(final List<DependencyKey> dependencies) {
    _state?.changeDependencies(dependencies);
  }
}
