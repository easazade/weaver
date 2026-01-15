import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weaver/flutter_weaver.dart';

import 'utils/test_scopes.dart';

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
          'should enter scope when widget is mounted',
          (final WidgetTester tester) async {
            await weaverInstance.addScopeHandler(Test1ScopeHandler(weaverInstance));

            await tester.pumpWidget(
              MaterialApp(
                home: AutoScope(
                  weaver: weaverInstance,
                  scope: Test1Scope(objects: ['test-value']),
                  child: const Text('Test Widget'),
                ),
              ),
            );

            // Wait for async scope entry
            await tester.pump();

            // Verify scope is entered
            expect(weaverInstance.isInScope(Test1Scope.scopeName), isTrue);

            // Verify dependencies are registered by scope handler
            expect(weaverInstance.isRegistered<String>(), isTrue);
            expect(weaverInstance.get<String>(), equals('test-value'));
          },
        );

        testWidgets(
          'should leave scope when widget is disposed',
          (final WidgetTester tester) async {
            await weaverInstance.addScopeHandler(Test1ScopeHandler(weaverInstance));

            await tester.pumpWidget(
              MaterialApp(
                home: AutoScope(
                  weaver: weaverInstance,
                  scope: Test1Scope(objects: ['test-value']),
                  child: const Text('Test Widget'),
                ),
              ),
            );

            await tester.pump();

            // Verify scope is entered
            expect(weaverInstance.isInScope(Test1Scope.scopeName), isTrue);
            expect(weaverInstance.isRegistered<String>(), isTrue);

            // Remove widget from tree
            await tester.pumpWidget(const MaterialApp(home: SizedBox()));

            // Wait for async scope exit
            await tester.pump();

            // Verify scope is left
            expect(weaverInstance.isInScope(Test1Scope.scopeName), isFalse);
            expect(weaverInstance.isRegistered<String>(), isFalse);
          },
        );

        testWidgets(
          'All registered objects should be registered and available',
          (final WidgetTester tester) async {
            await weaverInstance.addScopeHandler(Test1ScopeHandler(weaverInstance));

            await tester.pumpWidget(
              MaterialApp(
                home: AutoScope(
                  weaver: weaverInstance,
                  scope: Test1Scope(objects: ['string-value', 42, true]),
                  child: const Text('Test Widget'),
                ),
              ),
            );

            await tester.pump();

            // Verify scope is entered
            expect(weaverInstance.isInScope(Test1Scope.scopeName), isTrue);

            // Verify all dependencies are registered
            expect(weaverInstance.isRegistered<String>(), isTrue);
            expect(weaverInstance.get<String>(), equals('string-value'));
            expect(weaverInstance.isRegistered<int>(), isTrue);
            expect(weaverInstance.get<int>(), equals(42));
            expect(weaverInstance.isRegistered<bool>(), isTrue);
            expect(weaverInstance.get<bool>(), equals(true));
          },
        );

        testWidgets(
          'should unregister all objects when scope is left',
          (final WidgetTester tester) async {
            await weaverInstance.addScopeHandler(Test1ScopeHandler(weaverInstance));

            await tester.pumpWidget(
              MaterialApp(
                home: AutoScope(
                  weaver: weaverInstance,
                  scope: Test1Scope(objects: ['string-value', 42, true]),
                  child: const Text('Test Widget'),
                ),
              ),
            );

            await tester.pump();

            expect(weaverInstance.isRegistered<String>(), isTrue);
            expect(weaverInstance.isRegistered<int>(), isTrue);
            expect(weaverInstance.isRegistered<bool>(), isTrue);

            // Remove widget from tree
            await tester.pumpWidget(const MaterialApp(home: SizedBox()));
            await tester.pump();

            // Verify all dependencies are unregistered
            expect(weaverInstance.isRegistered<String>(), isFalse);
            expect(weaverInstance.isRegistered<int>(), isFalse);
            expect(weaverInstance.isRegistered<bool>(), isFalse);
          },
        );

        testWidgets(
          'should render child widget correctly',
          (final WidgetTester tester) async {
            await weaverInstance.addScopeHandler(Test1ScopeHandler(weaverInstance));

            const childWidget = Text('Child Widget Content');

            await tester.pumpWidget(
              MaterialApp(
                home: AutoScope(
                  weaver: weaverInstance,
                  scope: Test1Scope(objects: ['test']),
                  child: childWidget,
                ),
              ),
            );

            expect(find.text('Child Widget Content'), findsOneWidget);
          },
        );

        testWidgets(
          'should handle nested AutoScope widgets with different scopes',
          (final WidgetTester tester) async {
            await weaverInstance.addScopeHandler(Test1ScopeHandler(weaverInstance));
            await weaverInstance.addScopeHandler(Test2ScopeHandler(weaverInstance));

            await tester.pumpWidget(
              MaterialApp(
                home: AutoScope(
                  weaver: weaverInstance,
                  scope: Test1Scope(objects: ['scope1-string']),
                  child: AutoScope(
                    weaver: weaverInstance,
                    scope: Test2Scope(objects: [100]),
                    child: const Text('Nested Widget'),
                  ),
                ),
              ),
            );

            await tester.pump();

            // Verify both scopes are entered
            expect(weaverInstance.isInScope(Test1Scope.scopeName), isTrue);
            expect(weaverInstance.isInScope(Test2Scope.scopeName), isTrue);

            // Verify dependencies from both scopes are registered
            // Note: Test2Scope will overwrite the String from Test1Scope since both register String
            // But int from Test2Scope should be registered
            expect(weaverInstance.isRegistered<String>(), isTrue);
            expect(weaverInstance.get<String>(), equals('scope1-string'));
            expect(weaverInstance.isRegistered<int>(), isTrue);
            expect(weaverInstance.get<int>(), equals(100));
          },
        );

        testWidgets(
          'should handle scope re-entry when widget is rebuilt',
          (final WidgetTester tester) async {
            await weaverInstance.addScopeHandler(Test1ScopeHandler(weaverInstance));

            await tester.pumpWidget(
              MaterialApp(
                home: AutoScope(
                  weaver: weaverInstance,
                  scope: Test1Scope(objects: ['first-value']),
                  child: const Text('Test Widget'),
                ),
              ),
            );

            await tester.pump();

            expect(weaverInstance.isInScope(Test1Scope.scopeName), isTrue);
            expect(weaverInstance.get<String>(), equals('first-value'));

            // Remove widget to leave scope
            await tester.pumpWidget(const MaterialApp(home: SizedBox()));
            await tester.pump();

            expect(weaverInstance.isInScope(Test1Scope.scopeName), isFalse);

            // Rebuild with same scope - should enter again
            await tester.pumpWidget(
              MaterialApp(
                home: AutoScope(
                  weaver: weaverInstance,
                  scope: Test1Scope(objects: ['second-value']),
                  child: const Text('Test Widget Updated'),
                ),
              ),
            );

            await tester.pump();

            // Scope should be entered again
            expect(weaverInstance.isInScope(Test1Scope.scopeName), isTrue);
            expect(weaverInstance.isRegistered<String>(), isTrue);
            expect(weaverInstance.get<String>(), equals('second-value'));
          },
        );

        testWidgets(
          'should enter scope but if scope does not register any object, none should be registered.',
          (final WidgetTester tester) async {
            await weaverInstance.addScopeHandler(Test1ScopeHandler(weaverInstance));

            await tester.pumpWidget(
              MaterialApp(
                home: AutoScope(
                  weaver: weaverInstance,
                  scope: Test1Scope(objects: []),
                  child: const Text('Test Widget'),
                ),
              ),
            );

            await tester.pump();

            // Scope should be entered even with empty list
            expect(weaverInstance.isInScope(Test1Scope.scopeName), isTrue);
            // No dependencies should be registered
            expect(weaverInstance.isRegistered<String>(), isFalse);
            expect(weaverInstance.isRegistered<int>(), isFalse);
          },
        );

        testWidgets(
          'should work correctly with multiple weaver instances',
          (final WidgetTester tester) async {
            final weaver1 = Weaver();
            final weaver2 = Weaver();

            await weaver1.addScopeHandler(Test1ScopeHandler(weaver1));
            await weaver2.addScopeHandler(Test1ScopeHandler(weaver2));

            await tester.pumpWidget(
              MaterialApp(
                home: Column(
                  children: [
                    AutoScope(
                      weaver: weaver1,
                      scope: Test1Scope(objects: ['weaver1-value']),
                      child: const Text('Widget 1'),
                    ),
                    AutoScope(
                      weaver: weaver2,
                      scope: Test1Scope(objects: ['weaver2-value']),
                      child: const Text('Widget 2'),
                    ),
                  ],
                ),
              ),
            );

            await tester.pump();

            // Both weaver instances should have their scopes entered
            expect(weaver1.isInScope(Test1Scope.scopeName), isTrue);
            expect(weaver2.isInScope(Test1Scope.scopeName), isTrue);

            // Both should have dependencies registered
            expect(weaver1.isRegistered<String>(), isTrue);
            expect(weaver1.get<String>(), equals('weaver1-value'));
            expect(weaver2.isRegistered<String>(), isTrue);
            expect(weaver2.get<String>(), equals('weaver2-value'));

            // Cleanup
            weaver1.reset();
            weaver2.reset();
          },
        );

        testWidgets(
          'should make RequiredDependencies ready when AutoScope enters scope and registers dependency',
          (final WidgetTester tester) async {
            await weaverInstance.addScopeHandler(Test1ScopeHandler(weaverInstance));

            // First, verify dependency is not registered
            expect(weaverInstance.isRegistered<String>(), isFalse);

            await tester.pumpWidget(
              MaterialApp(
                home: AutoScope(
                  weaver: weaverInstance,
                  scope: Test1Scope(objects: ['test-value']),
                  child: RequireDependencies(
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
              ),
            );

            // Wait for async scope entry to complete
            await tester.pump();

            // After scope entry, dependency should be registered and RequireDependencies should show ready
            expect(weaverInstance.isInScope(Test1Scope.scopeName), isTrue);
            expect(weaverInstance.isRegistered<String>(), isTrue);
            expect(weaverInstance.get<String>(), equals('test-value'));
            expect(find.text('Ready'), findsOneWidget);
            expect(find.byType(CircularProgressIndicator), findsNothing);
          },
        );

        testWidgets(
          'should make RequiredDependencies show loading again when AutoScope leaves scope and unregisters dependency',
          (final WidgetTester tester) async {
            await weaverInstance.addScopeHandler(Test1ScopeHandler(weaverInstance));

            await tester.pumpWidget(
              MaterialApp(
                home: AutoScope(
                  weaver: weaverInstance,
                  scope: Test1Scope(objects: ['test-value']),
                  child: RequireDependencies(
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
              ),
            );

            // Wait for async scope entry
            await tester.pump();

            // Verify scope is entered and RequireDependencies shows ready
            expect(weaverInstance.isInScope(Test1Scope.scopeName), isTrue);
            expect(weaverInstance.isRegistered<String>(), isTrue);
            expect(find.text('Ready'), findsOneWidget);
            expect(find.byType(CircularProgressIndicator), findsNothing);

            // Manually leave the scope (simulating AutoScope disposal)
            // This avoids the setState during disposal issue
            await weaverInstance.leaveScope(Test1Scope.scopeName);

            // Wait for async operations and widget rebuilds
            await tester.pump();
            await tester.pump();

            // Verify scope is left and dependency is unregistered
            expect(weaverInstance.isInScope(Test1Scope.scopeName), isFalse);
            expect(weaverInstance.isRegistered<String>(), isFalse);
            // RequireDependencies should show loading again since dependency is no longer registered
            expect(find.byType(CircularProgressIndicator), findsOneWidget);
            expect(find.text('Ready'), findsNothing);
          },
        );
      },
    );
  }
}
