import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weaver/flutter_weaver.dart';

import 'utils/require_dependencies_tester.dart';

void main() {
  final weaverInstances = [
    // default instance
    weaver,
    // instantiated instance
    Weaver(),
  ];

  for (var i = 0; i < weaverInstances.length; i++) {
    final weaverInstance = weaverInstances[i];
    group(
      'Weaver instance $i - ',
      () {
        tearDown(() {
          weaverInstance.reset();
          weaverInstance.allowReassignment = false;
        });

        testWidgets(
          'should show loading state when dependencies are not ready',
          (final WidgetTester tester) async {
            await tester.pumpWidget(
              MaterialApp(
                home: RequireDependencies(
                  weaver: weaverInstance,
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
                  weaver: weaverInstance,
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

            weaverInstance.register('test');
            await tester.pump();

            expect(find.text('Ready'), findsOneWidget);
            expect(find.byType(CircularProgressIndicator), findsNothing);
          },
        );

        testWidgets(
          'should show loading state again when dependencies are unregistered',
          (final WidgetTester tester) async {
            weaverInstance.register('test');

            await tester.pumpWidget(
              MaterialApp(
                home: RequireDependencies(
                  weaver: weaverInstance,
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

            weaverInstance.unregister<String>();
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
                  weaver: weaverInstance,
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

            weaverInstance.register('test');
            await tester.pump();

            expect(find.byType(CircularProgressIndicator), findsOneWidget);

            weaverInstance.register<int>(42);
            await tester.pump();

            expect(find.text('Ready'), findsOneWidget);
            expect(find.byType(CircularProgressIndicator), findsNothing);
          },
        );

        testWidgets(
          'should show loading state when one of multiple dependencies is unregistered',
          (final WidgetTester tester) async {
            weaverInstance.register('test');
            weaverInstance.register<int>(42);

            await tester.pumpWidget(
              MaterialApp(
                home: RequireDependencies(
                  weaver: weaverInstance,
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

            weaverInstance.unregister<int>();
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
                  weaver: weaverInstance,
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
                  weaver: weaverInstance,
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

            weaverInstance.register<String>('test', name: 'user');
            await tester.pump();

            expect(find.text('Ready'), findsOneWidget);
          },
        );

        testWidgets(
          'should update when weaver instance changes',
          (final WidgetTester tester) async {
            weaverInstance.register('string object');

            final controller = RequireDependenciesTesterController();
            await tester.pumpWidget(RequireDependenciesTester(
              controller: controller,
              weaver: weaverInstance,
              dependencies: [DependencyKey(type: String)],
              builder: (final context, final child, final isReady) {
                if (isReady) {
                  return const Text('Ready');
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ));

            expect(find.text('Ready'), findsOneWidget);

            final newWeaver = Weaver();
            expect(newWeaver.isRegistered<String>(), isFalse);
            controller.changeWeaverInstance(newWeaver);
            await tester.pump();
            expect(find.byType(CircularProgressIndicator), findsOneWidget);
          },
        );

        testWidgets(
          'should update widget tree when dependencies list changes',
          (final WidgetTester tester) async {
            weaverInstance.register('string object');

            final controller = RequireDependenciesTesterController();
            await tester.pumpWidget(RequireDependenciesTester(
              controller: controller,
              weaver: weaverInstance,
              dependencies: [DependencyKey(type: String)],
              builder: (final context, final child, final isReady) {
                if (isReady) {
                  return const Text('Ready');
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ));

            expect(find.text('Ready'), findsOneWidget);

            controller.changeDependencies([DependencyKey(type: int)]);
            await tester.pump();
            expect(find.byType(CircularProgressIndicator), findsOneWidget);

            weaverInstance.register(1000);

            await tester.pump();
            expect(find.text('Ready'), findsOneWidget);
          },
        );

        testWidgets(
          'should handle empty dependencies list as ready state',
          (final WidgetTester tester) async {
            await tester.pumpWidget(
              MaterialApp(
                home: RequireDependencies(
                  weaver: weaverInstance,
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
      },
    );
  }
}
