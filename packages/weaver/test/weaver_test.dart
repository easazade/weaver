import 'package:flutter_test/flutter_test.dart';
import 'package:weaver/src/base/scope.dart';
import 'package:weaver/src/base/weaver.dart';

import 'utils/test_scope_handler.dart';

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

        test(
          'When no object registered should not be able to fetch it',
          () {
            expect(() => weaverInstance.get<String>(), throwsException);
          },
        );

        test(
          'When object registered should be able to fetch it',
          () {
            weaverInstance.register('ali');
            expect(weaverInstance.get<String>(), 'ali');
          },
        );

        test(
          'When object registered should be able to fetch it and '
          'when unregistered should not be able to fetch it.',
          () {
            weaverInstance.register('ali');
            expect(weaverInstance.get<String>(), 'ali');
            weaverInstance.unregister<String>();
            expect(() => weaverInstance.get<String>(), throwsException);
          },
        );

        test(
          'Should be able to request an object from weaver class before it is created using getAsync method. '
          'And wait for its creation and fetch the object as soon as it is created.',
          () async {
            Future.delayed(const Duration(milliseconds: 500), () {
              weaverInstance.register('Ali');
            });

            expect(() => weaverInstance.get<String>(), throwsException);
            expect(await weaverInstance.getAsync<String>(), 'Ali');
          },
        );

        test(
          'isRegistered method should be able to tell whether a dependency object is registered or not',
          () {
            weaverInstance.register('ali');
            expect(weaverInstance.isRegistered<String>(), true);
            weaverInstance.unregister<String>();
            expect(weaverInstance.isRegistered<String>(), false);
          },
        );

        test(
          'When multiple objects registered should be able to fetch each',
          () {
            weaverInstance.register('ali');
            weaverInstance.register<int>(10);
            weaverInstance.register(true);

            expect(weaverInstance.get<String>(), 'ali');
            expect(weaverInstance.get<int>(), 10);
            expect(weaverInstance.get<bool>(), true);
          },
        );

        test(
          'Should not be able to re-register objects of the same type',
          () {
            weaverInstance.register('ali');
            expect(() => weaverInstance.register('till'), throwsException);
          },
        );

        test(
          'Should be able to re-register objects of the same type when allowed reassignment',
          () {
            weaverInstance.allowReassignment = true;
            weaverInstance.register('ali');
            weaverInstance.register('till');

            expect(weaverInstance.get<String>(), 'till');
          },
        );

        test(
          'When registered a new ScopeHandler which currently is in scope '
          'its dependencies should be registered and available to fetch',
          () async {
            final scopeHandler = TestScopeHandler(
              stringObject: 'ali',
              intObject: 9,
            );

            await weaverInstance.addScopeHandler(scopeHandler);

            await weaverInstance.enterScope(TestScope(args: 'WHAT'));

            expect(weaverInstance.get<String>(), 'ali');
            expect(weaverInstance.get<int>(), 9);
          },
        );

        test(
          'Should not allow registering ScopeHandlers with duplicate names',
          () {
            final scopeHandler = TestScopeHandler(
              stringObject: 'ali',
              intObject: 9,
              scopeName: 'duplicate-scope-name',
            );

            weaverInstance.addScopeHandler(scopeHandler);

            final scopeHandler2 = TestScopeHandler(
              intObject: 90,
              scopeName: 'duplicate-scope-name',
            );

            expect(() => weaverInstance.addScopeHandler(scopeHandler2), throwsException);
          },
        );

        test(
          'When removed a ScopeHandler which currently is in scope '
          'its dependencies should not be available to fetch anymore',
          () async {
            final scopeHandler = TestScopeHandler(
              stringObject: 'ali',
              intObject: 9,
            );

            await weaverInstance.addScopeHandler(scopeHandler);

            await weaverInstance.enterScope(TestScope(args: 'WHAT'));

            expect(weaverInstance.get<String>(), 'ali');
            expect(weaverInstance.get<int>(), 9);

            // remove scopeHandler

            await weaverInstance.removeScopeHandler(scopeHandler.scopeName);
            expect(() => weaverInstance.get<String>(), throwsException);
            expect(() => weaverInstance.get<int>(), throwsException);
          },
        );

        test(
          'Should register the dependencies of a registered ScopeHandler after it comes in scope. '
          'And unregister after weaver leaves the scope',
          () async {
            final scopeHandler = TestScopeHandler(
              stringObject: 'ali',
              intObject: 9,
            );

            await weaverInstance.addScopeHandler(scopeHandler);

            expect(() => weaverInstance.get<String>(), throwsException);
            expect(() => weaverInstance.get<int>(), throwsException);

            final testScope = TestScope(args: 'WHAT');
            await weaverInstance.enterScope(testScope);

            expect(weaverInstance.get<String>(), 'ali');
            expect(weaverInstance.get<int>(), 9);

            await weaverInstance.leaveScope(testScope.name);

            expect(() => weaverInstance.get<String>(), throwsException);
            expect(() => weaverInstance.get<int>(), throwsException);
          },
        );

        test(
          'Should register the dependency lazy',
          () {
            expect(weaverInstance.isRegistered<String>(), false);
            weaverInstance.registerLazy(() => 'Ali');
            expect(weaverInstance.isRegistered<String>(), true);
            expect(weaverInstance.get<String>(), 'Ali');
          },
        );

        test(
          'Should register the dependency lazy',
          () {
            expect(weaverInstance.isRegistered<String>(), false);
            weaverInstance.registerLazy(() => 'Ali');
            expect(weaverInstance.isRegistered<String>(), true);
            expect(weaverInstance.get<String>(), 'Ali');
          },
        );

        test(
          'Should unregister the dependency that was lazily registered',
          () {
            expect(weaverInstance.isRegistered<String>(), false);
            weaverInstance.registerLazy(() => 'Ali');
            expect(weaverInstance.isRegistered<String>(), true);
            expect(weaverInstance.get<String>(), 'Ali');

            weaverInstance.unregister<String>();
            expect(weaverInstance.isRegistered<String>(), false);
            expect(() => weaverInstance.get<String>(), throwsException);
          },
        );

        test(
          'Should throw an error if scope handler registered and scope object used to enter scope '
          'have the same name but different argument types',
          () async {
            final scopeHandler = TestScopeHandler(
              stringObject: 'ali',
              intObject: 9,
            );

            await weaverInstance.addScopeHandler(scopeHandler);

            expect(() => weaverInstance.get<String>(), throwsException);
            expect(() => weaverInstance.get<int>(), throwsException);

            expect(
              () => weaverInstance.enterScope(WrongArgTestScope(args: 2)),
              throwsException,
            );
          },
        );

        test(
          'Should throw an exception if there is no ScopeHandler registered for entered scope',
          () async {
            expect(
              () => weaverInstance.enterScope(TestScope(args: 'args')),
              throwsException,
            );
          },
        );

        test(
          'Should Register a named object and fetch it with name and type',
          () async {
            const userObject = 'ali';
            expect(weaverInstance.isRegistered<String>(name: 'user'), isFalse);
            weaverInstance.register<String>(userObject, name: 'user');
            expect(weaverInstance.isRegistered<String>(name: 'user'), isTrue);
            expect(weaverInstance.get<String>(name: 'user'), equals(userObject));
          },
        );

        test(
          'Should Register a named object lazily and fetch it with name and type',
          () async {
            const userObject = 'ali';
            expect(weaverInstance.isRegistered<String>(name: 'user'), isFalse);
            weaverInstance.registerLazy<String>(() => userObject, name: 'user');
            expect(weaverInstance.isRegistered<String>(name: 'user'), isTrue);
            expect(weaverInstance.get<String>(name: 'user'), equals(userObject));
          },
        );

        test(
          'Should Register a named object and fetch it with only its type if there is only '
          'a single object of that type registered',
          () async {
            const userObject = 'ali';
            weaverInstance.register<String>(userObject, name: 'user');
            expect(weaverInstance.isRegistered<String>(name: 'user'), isTrue);
            expect(weaverInstance.get<String>(name: 'user'), userObject);
            expect(() => weaverInstance.get<String>(), throwsA(isA<WeaverException>()));
          },
        );
      },
    );
  }
}

class WrongArgTestScope extends Scope<int> {
  WrongArgTestScope({required super.args}) : super(name: 'test');
}
