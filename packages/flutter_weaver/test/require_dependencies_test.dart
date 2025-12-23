import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weaver/flutter_weaver.dart';

class _WeaverTestWrapper extends StatefulWidget {
  const _WeaverTestWrapper({
    required this.initialWeaver,
    required this.onWeaverChanged,
  });

  final Weaver initialWeaver;
  final void Function(Weaver) onWeaverChanged;

  @override
  State<_WeaverTestWrapper> createState() => _WeaverTestWrapperState();
}

class _WeaverTestWrapperState extends State<_WeaverTestWrapper> {
  late Weaver _weaver;

  @override
  void initState() {
    super.initState();
    _weaver = widget.initialWeaver;
  }

  void updateWeaver(final Weaver newWeaver) {
    setState(() {
      _weaver = newWeaver;
    });
  }

  @override
  Widget build(final BuildContext context) {
    widget.onWeaverChanged(_weaver);
    return RequireDependencies(
      weaver: _weaver,
      dependencies: [DependencyKey(type: String)],
      builder: (final context, final child, final isReady) {
        if (isReady) {
          return const Text('Ready');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

class _DependenciesTestWrapper extends StatefulWidget {
  const _DependenciesTestWrapper({
    required this.weaver,
    required this.initialDependencies,
    required this.onDependenciesChanged,
  });

  final Weaver weaver;
  final List<DependencyKey> initialDependencies;
  final void Function(List<DependencyKey>) onDependenciesChanged;

  @override
  State<_DependenciesTestWrapper> createState() => _DependenciesTestWrapperState();
}

class _DependenciesTestWrapperState extends State<_DependenciesTestWrapper> {
  late List<DependencyKey> _dependencies;

  @override
  void initState() {
    super.initState();
    _dependencies = widget.initialDependencies;
  }

  void updateDependencies(final List<DependencyKey> newDependencies) {
    setState(() {
      _dependencies = newDependencies;
    });
  }

  @override
  Widget build(final BuildContext context) {
    widget.onDependenciesChanged(_dependencies);
    return RequireDependencies(
      weaver: widget.weaver,
      dependencies: _dependencies,
      builder: (final context, final child, final isReady) {
        if (isReady) {
          return const Text('Ready');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

void main() {
  group('RequireDependencies', () {
    late Weaver testWeaver;

    setUp(() {
      testWeaver = Weaver();
    });

    tearDown(() {
      testWeaver.reset();
    });

    testWidgets(
      'should show loading state when dependencies are not ready',
      (final WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: RequireDependencies(
              weaver: testWeaver,
              dependencies: [DependencyKey(type: String)],
              builder: (final context, final child, final isReady) {
                if (isReady) {
                  return const Text('Ready');
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Ready'), findsNothing);
      },
    );

    testWidgets(
      'should show ready state when dependencies are registered',
      (final WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: RequireDependencies(
              weaver: testWeaver,
              dependencies: [DependencyKey(type: String)],
              builder: (final context, final child, final isReady) {
                if (isReady) {
                  return const Text('Ready');
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        testWeaver.register('test');
        await tester.pump();

        expect(find.text('Ready'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets(
      'should show loading state again when dependencies are unregistered',
      (final WidgetTester tester) async {
        testWeaver.register('test');

        await tester.pumpWidget(
          MaterialApp(
            home: RequireDependencies(
              weaver: testWeaver,
              dependencies: [DependencyKey(type: String)],
              builder: (final context, final child, final isReady) {
                if (isReady) {
                  return const Text('Ready');
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ),
        );

        expect(find.text('Ready'), findsOneWidget);

        testWeaver.unregister<String>();
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Ready'), findsNothing);
      },
    );

    testWidgets(
      'should require all dependencies to be ready before showing ready state',
      (final WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: RequireDependencies(
              weaver: testWeaver,
              dependencies: [
                DependencyKey(type: String),
                DependencyKey(type: int),
              ],
              builder: (final context, final child, final isReady) {
                if (isReady) {
                  return const Text('Ready');
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        testWeaver.register('test');
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        testWeaver.register<int>(42);
        await tester.pump();

        expect(find.text('Ready'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets(
      'should show loading state when one of multiple dependencies is unregistered',
      (final WidgetTester tester) async {
        testWeaver.register('test');
        testWeaver.register<int>(42);

        await tester.pumpWidget(
          MaterialApp(
            home: RequireDependencies(
              weaver: testWeaver,
              dependencies: [
                DependencyKey(type: String),
                DependencyKey(type: int),
              ],
              builder: (final context, final child, final isReady) {
                if (isReady) {
                  return const Text('Ready');
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ),
        );

        expect(find.text('Ready'), findsOneWidget);

        testWeaver.unregister<int>();
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Ready'), findsNothing);
      },
    );

    testWidgets(
      'should pass child widget to builder',
      (final WidgetTester tester) async {
        const childWidget = Text('Child Widget');

        await tester.pumpWidget(
          MaterialApp(
            home: RequireDependencies(
              weaver: testWeaver,
              dependencies: [DependencyKey(type: String)],
              child: childWidget,
              builder: (final context, final child, final isReady) {
                return child ?? const SizedBox();
              },
            ),
          ),
        );

        expect(find.text('Child Widget'), findsOneWidget);
      },
    );

    testWidgets(
      'should handle named dependencies',
      (final WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: RequireDependencies(
              weaver: testWeaver,
              dependencies: [
                DependencyKey(type: String, name: 'user'),
              ],
              builder: (final context, final child, final isReady) {
                if (isReady) {
                  return const Text('Ready');
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        testWeaver.register<String>('test', name: 'user');
        await tester.pump();

        expect(find.text('Ready'), findsOneWidget);
      },
    );

    testWidgets(
      'should update when weaver instance changes',
      (final WidgetTester tester) async {
        final weaver1 = Weaver();
        final weaver2 = Weaver();

        weaver1.register('weaver1');

        _WeaverTestWrapperState? wrapperState;

        await tester.pumpWidget(
          MaterialApp(
            home: _WeaverTestWrapper(
              initialWeaver: weaver1,
              onWeaverChanged: (final _) {},
            ),
          ),
        );

        wrapperState = tester.state<_WeaverTestWrapperState>(
          find.byType(_WeaverTestWrapper),
        );

        expect(find.text('Ready'), findsOneWidget);

        wrapperState.updateWeaver(weaver2);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        weaver2.register('weaver2');
        await tester.pump();

        expect(find.text('Ready'), findsOneWidget);

        weaver1.reset();
        weaver2.reset();
      },
    );

    testWidgets(
      'should update when dependencies list changes',
      (final WidgetTester tester) async {
        testWeaver.register('test');

        _DependenciesTestWrapperState? wrapperState;

        await tester.pumpWidget(
          MaterialApp(
            home: _DependenciesTestWrapper(
              weaver: testWeaver,
              initialDependencies: [DependencyKey(type: String)],
              onDependenciesChanged: (final _) {},
            ),
          ),
        );

        wrapperState = tester.state<_DependenciesTestWrapperState>(
          find.byType(_DependenciesTestWrapper),
        );

        expect(find.text('Ready'), findsOneWidget);

        wrapperState.updateDependencies([
          DependencyKey(type: String),
          DependencyKey(type: int),
        ]);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        testWeaver.register<int>(42);
        await tester.pump();

        expect(find.text('Ready'), findsOneWidget);
      },
    );

    testWidgets(
      'should handle empty dependencies list',
      (final WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: RequireDependencies(
              weaver: testWeaver,
              dependencies: const [],
              builder: (final context, final child, final isReady) {
                if (isReady) {
                  return const Text('Ready');
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ),
        );

        expect(find.text('Ready'), findsOneWidget);
      },
    );
  });
}
