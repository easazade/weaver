import 'package:flutter_test/flutter_test.dart';
import 'package:weaver/src/base/weaver.dart';

import 'test_scope_registry.dart';

void main() {
  final weaverInstances = [
    // default instance
    weaver,
    // instantiated instance
    Weaver(),
  ];

  for (var i = 0; i < weaverInstances.length; i++) {
    final weaver = weaverInstances[i];
    group(
      'Weaver instance $i - ',
      () {
        tearDown(() {
          weaver.reset();
          weaver.allowReassignment = false;
        });

        test(
          'When no object registered should not be able to fetch it',
          () {
            expect(() => weaver.get<String>(), throwsException);
          },
        );

        test(
          'When object registered should be able to fetch it',
          () {
            weaver.register('ali');
            expect(weaver.get<String>(), 'ali');
          },
        );

        test(
          'When object registered should be able to fetch it and '
          'when unregistered should not be able to fetch it.',
          () {
            weaver.register('ali');
            expect(weaver.get<String>(), 'ali');
            weaver.unregister<String>();
            expect(() => weaver.get<String>(), throwsException);
          },
        );

        test(
          'Should be able to request an object from weaver class before it is created using getAsync method. '
          'And wait for its creation and fetch the object as soon as it is created.',
          () async {
            Future.delayed(const Duration(milliseconds: 500), () {
              weaver.register('Ali');
            });

            expect(() => weaver.get<String>(), throwsException);
            expect(await weaver.getAsync<String>(), 'Ali');
          },
        );

        test(
          'isRegistered method should be able to tell whether a dependency object is registered or not',
          () {
            weaver.register('ali');
            expect(weaver.isRegistered<String>(), true);
            weaver.unregister<String>();
            expect(weaver.isRegistered<String>(), false);
          },
        );

        test(
          'When multiple objects registered should be able to fetch each',
          () {
            weaver.register('ali');
            weaver.register<int>(10);
            weaver.register(true);

            expect(weaver.get<String>(), 'ali');
            expect(weaver.get<int>(), 10);
            expect(weaver.get<bool>(), true);
          },
        );

        test(
          'Should not be able to re-register objects of the same type',
          () {
            weaver.register('ali');
            expect(() => weaver.register('till'), throwsException);
          },
        );

        test(
          'Should be able to re-register objects of the same type when allowed reassignment',
          () {
            weaver.allowReassignment = true;
            weaver.register('ali');
            weaver.register('till');

            expect(weaver.get<String>(), 'till');
          },
        );

        test(
          'When registered a new ScopeRegistry which currently is in scope '
          'its dependencies should be registered and available to fetch',
          () {
            final scopeRegistry = TestScope(
              stringObject: 'ali',
              intObject: 9,
            );

            weaver.addScopeRegistry(scopeRegistry);

            expect(weaver.get<String>(), 'ali');
            expect(weaver.get<int>(), 9);
          },
        );

        test(
          'Should not allow registering RegistryScopes with duplicate names',
          () {
            final scopeRegistry = TestScope(
              stringObject: 'ali',
              intObject: 9,
              name: 'duplicate-scope-name',
            );

            weaver.addScopeRegistry(scopeRegistry);

            final scopeRegistry2 = TestScope(
              intObject: 90,
              name: 'duplicate-scope-name',
            );

            expect(
                () => weaver.addScopeRegistry(scopeRegistry2), throwsException);
          },
        );

        test(
          'When removed a ScopeRegistry which currently is in scope '
          'its dependencies should not be available to fetch anymore',
          () {
            final scopeRegistry = TestScope(
              stringObject: 'ali',
              intObject: 9,
            );

            weaver.addScopeRegistry(scopeRegistry);

            expect(weaver.get<String>(), 'ali');
            expect(weaver.get<int>(), 9);

            // remove scopeRegistry

            weaver.removeScopeRegistry(scopeRegistry.name);
            expect(() => weaver.get<String>(), throwsException);
            expect(() => weaver.get<int>(), throwsException);
          },
        );

        test(
          'Should register the dependencies of a registered ScopeRegistry after it comes in scope',
          () {
            final scopeRegistry = TestScope(
              stringObject: 'ali',
              intObject: 9,
              initialIsInScopeValue: false,
            );

            weaver.addScopeRegistry(scopeRegistry);

            expect(() => weaver.get<String>(), throwsException);
            expect(() => weaver.get<int>(), throwsException);

            scopeRegistry.isInScope.value = true;

            expect(weaver.get<String>(), 'ali');
            expect(weaver.get<int>(), 9);
          },
        );

        test(
          'Should register the dependency lazy',
          () {
            expect(weaver.isRegistered<String>(), false);
            weaver.registerLazy(() => 'Ali');
            expect(weaver.isRegistered<String>(), true);
            expect(weaver.get<String>(), 'Ali');
          },
        );

        test(
          'Should register the dependency lazy',
          () {
            expect(weaver.isRegistered<String>(), false);
            weaver.registerLazy(() => 'Ali');
            expect(weaver.isRegistered<String>(), true);
            expect(weaver.get<String>(), 'Ali');
          },
        );

        test(
          'Should unregister the dependency that was lazily registered',
          () {
            expect(weaver.isRegistered<String>(), false);
            weaver.registerLazy(() => 'Ali');
            expect(weaver.isRegistered<String>(), true);
            expect(weaver.get<String>(), 'Ali');

            weaver.unregister<String>();
            expect(weaver.isRegistered<String>(), false);
            expect(() => weaver.get<String>(), throwsException);
          },
        );
      },
    );
  }
}
