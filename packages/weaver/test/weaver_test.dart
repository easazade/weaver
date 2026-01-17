import 'package:test/test.dart';
import 'package:weaver/weaver.dart';

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

        group('get', () {
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

          test(
            'Should provide helpful error message when named dependency exists but type-only requested',
            () {
              weaverInstance.register('ali', name: 'user');
              expect(
                () => weaverInstance.get<String>(),
                throwsA(
                  predicate<WeaverException>(
                    (final e) {
                      final dependencyKey = DependencyKey(type: String);

                      return e.message.contains('There is no instance of $dependencyKey registered.') &&
                          e.message.contains('But there are named dependencies registered with this type:') &&
                          e.message.contains(
                              'To retrieve named registered named objects you must pass both type & name when calling weaver.get()');
                    },
                  ),
                ),
              );
            },
          );

          test(
            'Should instantiate lazy dependency when get is called',
            () {
              var instantiated = false;
              weaverInstance.registerLazy(() {
                instantiated = true;
                return 'Ali';
              });
              expect(instantiated, false);
              expect(weaverInstance.get<String>(), 'Ali');
              expect(instantiated, true);
            },
          );
        });

        group('getAsync', () {
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
            'Should return immediately when dependency is already registered',
            () async {
              weaverInstance.register('Ali');
              final result = await weaverInstance.getAsync<String>();
              expect(result, 'Ali');
            },
          );

          test(
            'Should work with named dependencies',
            () async {
              Future.delayed(const Duration(milliseconds: 500), () {
                weaverInstance.register('Ali', name: 'user');
              });

              expect(() => weaverInstance.get<String>(name: 'user'), throwsException);
              expect(await weaverInstance.getAsync<String>(name: 'user'), 'Ali');
            },
          );

          test(
            'Should return immediately when named dependency is already registered',
            () async {
              weaverInstance.register('Ali', name: 'user');
              final result = await weaverInstance.getAsync<String>(name: 'user');
              expect(result, 'Ali');
            },
          );
        });

        group('register', () {
          test(
            'Should not be able to re-register objects of the same type',
            () {
              weaverInstance.register('ali');
              expect(() => weaverInstance.register('Hasan'), throwsException);
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
            'Should throw exception when trying to register Object type',
            () {
              expect(
                () => weaverInstance.register<Object>('test'),
                throwsA(isA<WeaverException>()),
              );
            },
          );

          test(
            'Should be able to re-register named objects when allowReassignment is true',
            () {
              weaverInstance.allowReassignment = true;
              weaverInstance.register<String>('ali', name: 'user');
              weaverInstance.register<String>('Hasan', name: 'user');
              expect(weaverInstance.get<String>(name: 'user'), 'Hasan');
            },
          );

          test(
            'Should register an object with a session and be able to fetch it',
            () {
              weaverInstance.register('ali', session: 'test-session');
              expect(weaverInstance.isRegistered<String>(), true);
              expect(weaverInstance.get<String>(), 'ali');
            },
          );

          test(
            'Should register multiple objects with the same session',
            () {
              weaverInstance.register('ali', session: 'test-session');
              weaverInstance.register(10, session: 'test-session');
              weaverInstance.register(true, session: 'test-session');

              expect(weaverInstance.get<String>(), 'ali');
              expect(weaverInstance.get<int>(), 10);
              expect(weaverInstance.get<bool>(), true);
            },
          );

          test(
            'Should register objects with different sessions',
            () {
              weaverInstance.register('ali', session: 'session-1');
              weaverInstance.register(10, session: 'session-2');
              weaverInstance.register(true, session: 'session-1');

              expect(weaverInstance.get<String>(), 'ali');
              expect(weaverInstance.get<int>(), 10);
              expect(weaverInstance.get<bool>(), true);
            },
          );

          test(
            'Should register objects with and without sessions',
            () {
              weaverInstance.register('ali', session: 'test-session');
              weaverInstance.register(10); // no session
              weaverInstance.register(true, session: 'test-session');

              expect(weaverInstance.get<String>(), 'ali');
              expect(weaverInstance.get<int>(), 10);
              expect(weaverInstance.get<bool>(), true);
            },
          );

          test(
            'Should register named objects with a session',
            () {
              weaverInstance.register('ali', name: 'user', session: 'test-session');
              expect(weaverInstance.isRegistered<String>(name: 'user'), true);
              expect(weaverInstance.get<String>(name: 'user'), 'ali');
            },
          );

          group('registerIfNot', () {
            test(
              'Should register object if not already registered',
              () {
                expect(weaverInstance.isRegistered<String>(), false);
                weaverInstance.registerIfIsNot('ali');
                expect(weaverInstance.isRegistered<String>(), true);
                expect(weaverInstance.get<String>(), 'ali');
              },
            );

            test(
              'Should not throw or change existing registration if already registered',
              () {
                weaverInstance.register('ali');
                expect(weaverInstance.get<String>(), 'ali');

                // This should do nothing and not throw
                weaverInstance.registerIfIsNot('hasan');
                expect(weaverInstance.get<String>(), 'ali');
              },
            );

            test(
              'Should work with named dependencies',
              () {
                weaverInstance.register('ali', name: 'user');
                weaverInstance.registerIfIsNot('hasan', name: 'user');
                weaverInstance.registerIfIsNot('hasan', name: 'admin');

                expect(weaverInstance.get<String>(name: 'user'), 'ali');
                expect(weaverInstance.get<String>(name: 'admin'), 'hasan');
              },
            );
          });
        });

        group('unregister', () {
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
            'Should not throw when unregistering a non-registered dependency',
            () {
              expect(() => weaverInstance.unregister<String>(), returnsNormally);
              expect(() => weaverInstance.unregister<int>(), returnsNormally);
            },
          );

          test(
            'Should be able to unregister only with name',
            () {
              weaverInstance.register('ali', name: 'user');
              expect(() => weaverInstance.unregister(name: 'user'), returnsNormally);
              expect(weaverInstance.isRegistered(name: 'user'), false);
            },
          );

          test(
            'Should be able to unregister using type parameter directly',
            () {
              weaverInstance.register('ali');
              expect(weaverInstance.isRegistered<String>(), true);
              expect(weaverInstance.get<String>(), 'ali');

              // Using type parameter: can use type parameter as alternative to generic type
              // Both generic type and type parameter should work
              weaverInstance.unregister(type: String);
              expect(weaverInstance.isRegistered<String>(), false);
              expect(() => weaverInstance.get<String>(), throwsException);
            },
          );

          test(
            'Should be able to unregister using type parameter with different types '
            'using type parameter instead of generic type parameter',
            () {
              weaverInstance.register('ali');
              weaverInstance.register(10);
              weaverInstance.register(true);

              expect(weaverInstance.isRegistered<String>(), true);
              expect(weaverInstance.isRegistered<int>(), true);
              expect(weaverInstance.isRegistered<bool>(), true);

              // Use type parameter to unregister String
              weaverInstance.unregister(type: String);
              expect(weaverInstance.isRegistered<String>(), false);
              expect(weaverInstance.isRegistered<int>(), true);
              expect(weaverInstance.isRegistered<bool>(), true);

              weaverInstance.unregister(type: int);
              expect(weaverInstance.isRegistered<int>(), false);
              expect(weaverInstance.isRegistered<bool>(), true);

              weaverInstance.unregister(type: bool);
              expect(weaverInstance.isRegistered<bool>(), false);
            },
          );

          test(
            'Should be able to unregister using type parameter with named dependencies',
            () {
              weaverInstance.register('ali', name: 'user');
              weaverInstance.register('admin', name: 'admin');

              expect(weaverInstance.isRegistered<String>(name: 'user'), true);
              expect(weaverInstance.isRegistered<String>(name: 'admin'), true);

              // Use type parameter with name
              weaverInstance.unregister(type: String, name: 'user');
              expect(weaverInstance.isRegistered<String>(name: 'user'), false);
              expect(weaverInstance.isRegistered<String>(name: 'admin'), true);

              weaverInstance.unregister(type: String, name: 'admin');
              expect(weaverInstance.isRegistered<String>(name: 'admin'), false);
            },
          );

          test(
            'Should unregister lazily registered dependency using type parameter instead of generic type parameter',
            () {
              weaverInstance.registerLazy(() => 'Ali');
              expect(weaverInstance.isRegistered<String>(), true);
              expect(weaverInstance.get<String>(), 'Ali');

              // Use type parameter to unregister String
              weaverInstance.unregister(type: String);
              expect(weaverInstance.isRegistered<String>(), false);
              expect(() => weaverInstance.get<String>(), throwsException);
            },
          );

          test(
            'Should not throw when unregistering non-registered dependency using type parameter',
            () {
              // Use type parameter - should not throw even if dependency is not registered
              expect(() => weaverInstance.unregister(type: String), returnsNormally);
              expect(() => weaverInstance.unregister(type: int), returnsNormally);
              expect(() => weaverInstance.unregister(type: bool), returnsNormally);
            },
          );

          test(
            'Should throw Exception type is defined differently in both generic argument and value argument',
            () {
              weaverInstance.register('ali');
              weaverInstance.register(10);

              expect(() => weaverInstance.unregister<String>(type: int), throwsException);
            },
          );

          test(
            'Should throw exception when unregistering with Object type and no name',
            () {
              weaverInstance.register('ali');
              expect(
                () => weaverInstance.unregister(type: Object),
                throwsA(isA<WeaverException>()),
              );
            },
          );

          test(
            'Should be able to unregister with Object type when name is provided',
            () {
              weaverInstance.register('ali', name: 'user');
              expect(() => weaverInstance.unregister<Object>(type: Object, name: 'user'), returnsNormally);
              expect(weaverInstance.isRegistered(name: 'user'), false);
            },
          );

          test(
            'Should work correctly when unregistering multiple dependencies of same type with '
            'different name, passing type using generic type arguments',
            () {
              weaverInstance.register('ali', name: 'user1');
              weaverInstance.register('hasan', name: 'user2');
              weaverInstance.register('admin', name: 'admin');

              expect(weaverInstance.isRegistered<String>(name: 'user1'), true);
              expect(weaverInstance.isRegistered<String>(name: 'user2'), true);
              expect(weaverInstance.isRegistered<String>(name: 'admin'), true);

              weaverInstance.unregister<String>(name: 'user1');
              expect(weaverInstance.isRegistered<String>(name: 'user1'), false);
              expect(weaverInstance.isRegistered<String>(name: 'user2'), true);
              expect(weaverInstance.isRegistered<String>(name: 'admin'), true);

              weaverInstance.unregister<String>(name: 'user2');
              expect(weaverInstance.isRegistered<String>(name: 'user2'), false);
              expect(weaverInstance.isRegistered<String>(name: 'admin'), true);
            },
          );

          test(
            'Should work correctly when unregistering multiple dependencies of same type with '
            'different name, passing type using value arguments',
            () {
              weaverInstance.register('ali', name: 'user1');
              weaverInstance.register('hasan', name: 'user2');
              weaverInstance.register('admin', name: 'admin');

              expect(weaverInstance.isRegistered<String>(name: 'user1'), true);
              expect(weaverInstance.isRegistered<String>(name: 'user2'), true);
              expect(weaverInstance.isRegistered<String>(name: 'admin'), true);

              weaverInstance.unregister(type: String, name: 'user1');
              expect(weaverInstance.isRegistered<String>(name: 'user1'), false);
              expect(weaverInstance.isRegistered<String>(name: 'user2'), true);
              expect(weaverInstance.isRegistered<String>(name: 'admin'), true);

              weaverInstance.unregister(type: String, name: 'user2');
              expect(weaverInstance.isRegistered<String>(name: 'user2'), false);
              expect(weaverInstance.isRegistered<String>(name: 'admin'), true);
            },
          );
        });

        group('isRegistered', () {
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
            'isRegistered method should be able to tell whether a dependency object is registered or not only by its name '
            'and without defining the type of the dependency object',
            () {
              weaverInstance.register('ali', name: 'user');
              expect(weaverInstance.isRegistered(name: 'user'), true);
              weaverInstance.unregister(name: 'user');
              expect(weaverInstance.isRegistered(name: 'user'), false);
            },
          );

          test(
            'isRegistered method should be able to tell whether a dependency object is registered or not only by its name '
            'and without defining the type of the dependency object',
            () {
              weaverInstance.register('ali', name: 'user');
              expect(weaverInstance.isRegistered(name: 'user'), true);
              weaverInstance.unregister(name: 'user');
              expect(weaverInstance.isRegistered(name: 'user'), false);
            },
          );

          test(
            'isRegistered method should throw a WeaverException when trying to unregister a dependency without specifying type or name',
            () {
              weaverInstance.register('ali', name: 'user');
              expect(weaverInstance.isRegistered(name: 'user'), true);
              expect(() => weaverInstance.unregister(), throwsA(isA<WeaverException>()));
            },
          );

          test(
            'isRegistered method should work with type parameter',
            () {
              weaverInstance.register('ali');
              expect(weaverInstance.isRegistered<String>(type: String), true);
              expect(weaverInstance.isRegistered<int>(type: int), false);
            },
          );

          test(
            'isRegistered should return true for lazy dependency before it is instantiated',
            () {
              weaverInstance.registerLazy(() => 'Ali');
              // Lazy dependencies are considered registered even before access
              expect(weaverInstance.isRegistered<String>(), true);
            },
          );

          test(
            'Should be able to check registration using type parameter directly without '
            'passing it throw generic type argument',
            () {
              weaverInstance.register('ali');
              weaverInstance.register(10);
              weaverInstance.register(true);

              // Using type parameter directly
              expect(weaverInstance.isRegistered(type: String), true);
              expect(weaverInstance.isRegistered(type: int), true);
              expect(weaverInstance.isRegistered(type: bool), true);
              expect(weaverInstance.isRegistered(type: double), false);

              weaverInstance.unregister<String>();
              expect(weaverInstance.isRegistered(type: String), false);
              expect(weaverInstance.isRegistered(type: int), true);
              expect(weaverInstance.isRegistered(type: bool), true);
            },
          );

          test(
            'Should be able to check registration using type parameter passed through '
            'value arguments instead of generic type arguments with named dependencies',
            () {
              weaverInstance.register('ali', name: 'user');
              weaverInstance.register('admin', name: 'admin');
              weaverInstance.register(10, name: 'count');

              // Using type parameter with name
              expect(weaverInstance.isRegistered(type: String, name: 'user'), true);
              expect(weaverInstance.isRegistered(type: String, name: 'admin'), true);
              expect(weaverInstance.isRegistered(type: int, name: 'count'), true);
              expect(weaverInstance.isRegistered(type: String, name: 'nonexistent'), false);
              // correct name but incorrect type
              expect(weaverInstance.isRegistered(type: int, name: 'user'), false);
            },
          );

          test(
            'Should return false when checking registration with type parameter for non-registered dependency',
            () {
              // No dependencies registered
              expect(weaverInstance.isRegistered(type: String), false);
              expect(weaverInstance.isRegistered(type: int), false);
              expect(weaverInstance.isRegistered(type: bool), false);
              expect(weaverInstance.isRegistered(type: String, name: 'user'), false);

              // Register one dependency
              weaverInstance.register('ali');
              expect(weaverInstance.isRegistered(type: String), true);
              expect(weaverInstance.isRegistered(type: int), false);
              expect(weaverInstance.isRegistered(type: bool), false);
            },
          );

          test(
            'Should work correctly with type parameter when multiple dependencies of same type have different names',
            () {
              weaverInstance.register('ali', name: 'user1');
              weaverInstance.register('hasan', name: 'user2');
              weaverInstance.register('admin', name: 'admin');

              // Using type parameter with specific names
              expect(weaverInstance.isRegistered(type: String, name: 'user1'), true);
              expect(weaverInstance.isRegistered(type: String, name: 'user2'), true);
              expect(weaverInstance.isRegistered(type: String, name: 'admin'), true);
              expect(weaverInstance.isRegistered(type: String, name: 'nonexistent'), false);

              // Without name, should return false when multiple named dependencies exist
              // (because there's no unnamed String dependency)
              expect(weaverInstance.isRegistered(type: String), false);
            },
          );

          test(
            'Should work correctly with type parameter for lazy dependencies',
            () {
              weaverInstance.registerLazy(() => 'Ali');
              weaverInstance.registerLazy(() => 10, name: 'count');

              // Lazy dependencies should be considered registered even before instantiation
              expect(weaverInstance.isRegistered(type: String), true);
              expect(weaverInstance.isRegistered(type: int, name: 'count'), true);
              expect(weaverInstance.isRegistered(type: int), false); // no unnamed int

              // After accessing, should still be registered
              expect(weaverInstance.get<String>(), 'Ali');
              expect(weaverInstance.isRegistered(type: String), true);
            },
          );
        });

        group('registerLazy', () {
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
            'Should be able to re-register lazy objects when allowReassignment is true',
            () {
              weaverInstance.allowReassignment = true;
              weaverInstance.registerLazy(() => 'Ali');
              weaverInstance.registerLazy(() => 'Hasan');
              expect(weaverInstance.get<String>(), 'Hasan');
            },
          );

          test(
            'Should be able to replace lazy registration with value registration when allowReassignment is true',
            () {
              weaverInstance.allowReassignment = true;
              weaverInstance.registerLazy(() => 'Ali');
              weaverInstance.register('Hasan');
              expect(weaverInstance.get<String>(), 'Hasan');
            },
          );

          test(
            'Should be able to replace value registration with lazy registration when allowReassignment is true',
            () {
              weaverInstance.allowReassignment = true;
              weaverInstance.register('Ali');
              weaverInstance.registerLazy(() => 'Hasan');
              expect(weaverInstance.get<String>(), 'Hasan');
              expect(weaverInstance.isRegistered<String>(), true);
            },
          );

          test(
            'Should instantiate lazy dependency only once when accessed multiple times',
            () {
              var callCount = 0;
              weaverInstance.registerLazy(() {
                callCount++;
                return 'Ali';
              });
              expect(callCount, 0);
              expect(weaverInstance.get<String>(), 'Ali');
              expect(callCount, 1);
              expect(weaverInstance.get<String>(), 'Ali');
              expect(callCount, 1); // Should not call again
            },
          );
        });

        group('allowReassignment', () {
          test(
            'Should be able to re-register objects of the same type when allowed reassignment',
            () {
              weaverInstance.allowReassignment = true;
              weaverInstance.register('ali');
              weaverInstance.register('Hasan');

              expect(weaverInstance.get<String>(), 'Hasan');
            },
          );
        });

        group('addScopeHandler', () {
          test(
            'When registered a new ScopeHandler which currently is in scope '
            'its dependencies should be registered and available to fetch',
            () async {
              final scopeHandler = TestScopeHandler(
                weaverInstance,
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
                weaverInstance,
                stringObject: 'ali',
                intObject: 9,
                scopeName: 'duplicate-scope-name',
              );

              weaverInstance.addScopeHandler(scopeHandler);

              final scopeHandler2 = TestScopeHandler(
                weaverInstance,
                intObject: 90,
                scopeName: 'duplicate-scope-name',
              );

              expect(() => weaverInstance.addScopeHandler(scopeHandler2), throwsException);
            },
          );

          test(
            'Should throw an error if scope handler registered and scope object used to enter scope '
            'have the same name but different argument types',
            () async {
              final scopeHandler = TestScopeHandler(
                weaverInstance,
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
            'Should be able to re-register ScopeHandler when allowReassignment is true',
            () async {
              weaverInstance.allowReassignment = true;

              final scopeHandler1 = TestScopeHandler(
                weaverInstance,
                stringObject: 'ali',
                intObject: 9,
                scopeName: 'test',
              );

              final scopeHandler2 = TestScopeHandler(
                weaverInstance,
                stringObject: 'Hasan',
                intObject: 90,
                scopeName: 'test',
              );

              await weaverInstance.addScopeHandler(scopeHandler1);
              // Remove the first handler before adding the second to avoid conflicts
              // sss
              await weaverInstance.addScopeHandler(scopeHandler2);
              await weaverInstance.enterScope(TestScope(args: 'test'));

              expect(weaverInstance.get<String>(), 'Hasan');
              expect(weaverInstance.get<int>(), 90);
            },
          );
        });

        group('removeScopeHandler', () {
          test(
            'When removed a ScopeHandler which currently is in scope '
            'its dependencies should not be available to fetch anymore',
            () async {
              final scopeHandler = TestScopeHandler(
                weaverInstance,
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
            'Should not throw when removing a non-existent ScopeHandler',
            () async {
              expect(
                () => weaverInstance.removeScopeHandler('non-existent'),
                returnsNormally,
              );
            },
          );
        });

        group('enterScope', () {
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
            'Should throw an exception when entering the same scope twice',
            () async {
              final scopeHandler = TestScopeHandler(
                weaverInstance,
                stringObject: 'ali',
                intObject: 9,
              );

              await weaverInstance.addScopeHandler(scopeHandler);

              final testScope = TestScope(args: 'WHAT');
              await weaverInstance.enterScope(testScope);

              expect(
                () => weaverInstance.enterScope(testScope),
                throwsA(isA<WeaverException>()),
              );
            },
          );

          test(
            'Should successfully enter scope when handler is registered',
            () async {
              final scopeHandler = TestScopeHandler(
                weaverInstance,
                stringObject: 'ali',
                intObject: 9,
              );

              await weaverInstance.addScopeHandler(scopeHandler);
              await weaverInstance.enterScope(TestScope(args: 'WHAT'));

              expect(weaverInstance.get<String>(), 'ali');
              expect(weaverInstance.get<int>(), 9);
            },
          );
        });

        group('leaveScope', () {
          test(
            'Should register the dependencies of a registered ScopeHandler after it comes in scope. '
            'And unregister after weaver leaves the scope',
            () async {
              final scopeHandler = TestScopeHandler(
                weaverInstance,
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
            'Should not throw when leaving a scope that is not entered',
            () async {
              expect(
                () => weaverInstance.leaveScope('non-existent-scope'),
                returnsNormally,
              );
            },
          );

          test(
            'Should not throw when leaving the same scope multiple times',
            () async {
              final scopeHandler = TestScopeHandler(
                weaverInstance,
                stringObject: 'ali',
                intObject: 9,
              );

              await weaverInstance.addScopeHandler(scopeHandler);
              final testScope = TestScope(args: 'WHAT');
              await weaverInstance.enterScope(testScope);

              await weaverInstance.leaveScope(testScope.name);
              expect(
                () => weaverInstance.leaveScope(testScope.name),
                returnsNormally,
              );
            },
          );
        });

        group('isInScope', () {
          test(
            'Should return false when scope is not entered',
            () {
              expect(weaverInstance.isInScope('test'), false);
            },
          );

          test(
            'Should return true when scope is entered',
            () async {
              final scopeHandler = TestScopeHandler(
                weaverInstance,
                stringObject: 'ali',
                intObject: 9,
              );

              await weaverInstance.addScopeHandler(scopeHandler);
              final testScope = TestScope(args: 'WHAT');
              await weaverInstance.enterScope(testScope);

              expect(weaverInstance.isInScope('test'), true);
            },
          );

          test(
            'Should return false after leaving scope',
            () async {
              final scopeHandler = TestScopeHandler(
                weaverInstance,
                stringObject: 'ali',
                intObject: 9,
              );

              await weaverInstance.addScopeHandler(scopeHandler);
              final testScope = TestScope(args: 'WHAT');
              await weaverInstance.enterScope(testScope);
              expect(weaverInstance.isInScope('test'), true);

              await weaverInstance.leaveScope('test');
              expect(weaverInstance.isInScope('test'), false);
            },
          );
        });

        group('scopes', () {
          test(
            'Should return empty iterable when no scopes are entered',
            () {
              expect(weaverInstance.scopes, isEmpty);
            },
          );

          test(
            'Should return all entered scopes',
            () async {
              final scopeHandler1 = TestScopeHandler(
                weaverInstance,
                stringObject: 'ali',
                intObject: 9,
                scopeName: 'test',
              );
              final scopeHandler2 = TestScopeHandler(
                weaverInstance,
                doubleObject: 90.0,
                boolObject: true,
                scopeName: 'another-scope',
              );

              await weaverInstance.addScopeHandler(scopeHandler1);
              await weaverInstance.addScopeHandler(scopeHandler2);

              final scope1 = TestScope(args: 'WHAT');
              final scope2 = AnotherTestScope(args: 'WHEN');

              await weaverInstance.enterScope(scope1);
              await weaverInstance.enterScope(scope2);

              expect(weaverInstance.scopes.length, 2);
              expect(weaverInstance.scopes.any((final s) => s.name == 'test'), true);
              expect(weaverInstance.scopes.any((final s) => s.name == 'another-scope'), true);
            },
          );
        });

        group('reset', () {
          test(
            'Should clear all registered dependencies',
            () {
              weaverInstance.register('ali');
              weaverInstance.register(10);
              weaverInstance.registerLazy(() => true);

              expect(weaverInstance.isRegistered<String>(), true);
              expect(weaverInstance.isRegistered<int>(), true);
              expect(weaverInstance.isRegistered<bool>(), true);

              weaverInstance.reset();

              expect(weaverInstance.isRegistered<String>(), false);
              expect(weaverInstance.isRegistered<int>(), false);
              expect(weaverInstance.isRegistered<bool>(), false);
            },
          );

          test(
            'Should clear all scopes',
            () async {
              final scopeHandler = TestScopeHandler(
                weaverInstance,
                stringObject: 'ali',
                intObject: 9,
              );

              await weaverInstance.addScopeHandler(scopeHandler);
              await weaverInstance.enterScope(TestScope(args: 'WHAT'));

              expect(weaverInstance.isInScope('test'), true);

              weaverInstance.reset();

              expect(weaverInstance.isInScope('test'), false);
              expect(weaverInstance.scopes, isEmpty);
            },
          );

          test(
            'Should remove and dispose all scope handlers',
            () async {
              final scopeHandler = DisposableTestScopeHandler(
                weaverInstance,
                stringObject: 'ali',
                intObject: 9,
              );

              await weaverInstance.addScopeHandler(scopeHandler);
              weaverInstance.reset();

              expect(scopeHandler.disposed, true);
            },
          );
        });

        group('clearSession', () {
          test(
            'Should remove all dependencies registered under a session',
            () {
              weaverInstance.register('ali', session: 'test-session');
              weaverInstance.register(10, session: 'test-session');
              weaverInstance.register(true, session: 'test-session');

              expect(weaverInstance.isRegistered<String>(), true);
              expect(weaverInstance.isRegistered<int>(), true);
              expect(weaverInstance.isRegistered<bool>(), true);

              weaverInstance.clearSession('test-session');

              expect(weaverInstance.isRegistered<String>(), false);
              expect(weaverInstance.isRegistered<int>(), false);
              expect(weaverInstance.isRegistered<bool>(), false);
            },
          );

          test(
            'Should only remove dependencies from the specified session',
            () {
              weaverInstance.register('ali', session: 'session-1');
              weaverInstance.register(10, session: 'session-2');
              weaverInstance.register(true, session: 'session-1');

              weaverInstance.clearSession('session-1');

              expect(weaverInstance.isRegistered<String>(), false);
              expect(weaverInstance.isRegistered<int>(), true);
              expect(weaverInstance.isRegistered<bool>(), false);
              expect(weaverInstance.get<int>(), 10);
            },
          );

          test(
            'Should not remove dependencies registered without a session',
            () {
              weaverInstance.register('ali', session: 'test-session');
              weaverInstance.register(10); // no session
              weaverInstance.register(true, session: 'test-session');

              weaverInstance.clearSession('test-session');

              expect(weaverInstance.isRegistered<String>(), false);
              expect(weaverInstance.isRegistered<int>(), true);
              expect(weaverInstance.isRegistered<bool>(), false);
              expect(weaverInstance.get<int>(), 10);
            },
          );

          test(
            'Should remove named dependencies registered under a session',
            () {
              weaverInstance.register('ali', name: 'user', session: 'test-session');
              weaverInstance.register(10, name: 'count', session: 'test-session');
              weaverInstance.register(true, session: 'test-session');

              expect(weaverInstance.isRegistered<String>(name: 'user'), true);
              expect(weaverInstance.isRegistered<int>(name: 'count'), true);
              expect(weaverInstance.isRegistered<bool>(), true);

              weaverInstance.clearSession('test-session');

              expect(weaverInstance.isRegistered<String>(name: 'user'), false);
              expect(weaverInstance.isRegistered<int>(name: 'count'), false);
              expect(weaverInstance.isRegistered<bool>(), false);
            },
          );

          test(
            'Should not throw when clearing a non-existent session',
            () {
              weaverInstance.register('ali', session: 'test-session');
              expect(() => weaverInstance.clearSession('non-existent-session'), returnsNormally);
              expect(weaverInstance.isRegistered<String>(), true);
            },
          );

          test(
            'Should not throw when clearing a session with no dependencies',
            () {
              expect(() => weaverInstance.clearSession('empty-session'), returnsNormally);
            },
          );

          test(
            'Should work correctly with multiple sessions and partial clearing',
            () {
              weaverInstance.register(10, session: 'session-1');
              weaverInstance.register(true, session: 'session-2');
              weaverInstance.register(20.0, session: 'session-2');
              weaverInstance.register('test'); // no session

              weaverInstance.clearSession('session-1');

              expect(weaverInstance.isRegistered<int>(), false);
              expect(weaverInstance.isRegistered<bool>(), true);
              expect(weaverInstance.isRegistered<double>(), true);
              expect(weaverInstance.get<bool>(), true);
              expect(weaverInstance.get<double>(), 20.0);
              expect(weaverInstance.get<String>(), 'test');
            },
          );
        });

        group('named', () {
          test(
            'Should return a WeaverNamed instance',
            () {
              expect(weaverInstance.named, isNotNull);
              expect(weaverInstance.named.weaverInstance, weaverInstance);
            },
          );
        });
      },
    );
  }
}

class WrongArgTestScope extends Scope<int> {
  WrongArgTestScope({required super.args}) : super(name: 'test');
}

class AnotherTestScope extends Scope<String> {
  AnotherTestScope({required super.args}) : super(name: 'another-scope');
}

class DisposableTestScopeHandler extends TestScopeHandler {
  DisposableTestScopeHandler(
    super.weaver, {
    super.stringObject,
    super.intObject,
    super.doubleObject,
    super.boolObject,
    super.scopeName,
  });

  var disposed = false;

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}
