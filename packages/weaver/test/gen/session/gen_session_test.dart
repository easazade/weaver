import 'package:test/test.dart';
import 'package:weaver/weaver.dart';

part 'gen_session_test.weaver.dart';

@WeaverSession(name: 'test')
// ignore: unused_element
class _TestSession {}

@WeaverSession(name: 'shopping')
// ignore: unused_element
class _ShoppingSession {}

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
      'Weaver instance $i - Generated Session Extensions',
      () {
        tearDown(() {
          weaverInstance.reset();
          weaverInstance.allowReassignment = false;
        });

        group('testSession extension', () {
          test('Should register objects under test session', () {
            weaverInstance.testSession.register<String>('test-value');
            weaverInstance.testSession.register<int>(42);

            expect(weaverInstance.isRegistered<String>(), isTrue);
            expect(weaverInstance.isRegistered<int>(), isTrue);
            expect(weaverInstance.get<String>(), 'test-value');
            expect(weaverInstance.get<int>(), 42);
          });

          test('Should clear only test session dependencies when clear() is called', () {
            // Register in test session
            weaverInstance.testSession.register<String>('test-value');
            weaverInstance.testSession.register<int>(42);

            // Register in default session (no session)
            weaverInstance.register<double>(3.14);

            // Clear test session
            weaverInstance.testSession.clear();

            // test session dependencies should be cleared
            expect(weaverInstance.isRegistered<String>(), isFalse);
            expect(weaverInstance.isRegistered<int>(), isFalse);

            // default session dependency should still exist
            expect(weaverInstance.isRegistered<double>(), isTrue);
            expect(weaverInstance.get<double>(), 3.14);
          });

          test('Should register named dependencies under test session', () {
            weaverInstance.testSession.register<String>('value1', name: 'key1');
            weaverInstance.testSession.register<String>('value2', name: 'key2');

            expect(weaverInstance.isRegistered<String>(name: 'key1'), isTrue);
            expect(weaverInstance.isRegistered<String>(name: 'key2'), isTrue);
            expect(weaverInstance.get<String>(name: 'key1'), 'value1');
            expect(weaverInstance.get<String>(name: 'key2'), 'value2');
          });
        });

        group('shoppingSession extension', () {
          test('Should register objects under shopping session', () {
            weaverInstance.shoppingSession.register<String>('cart-item');
            weaverInstance.shoppingSession.register<int>(100);

            expect(weaverInstance.isRegistered<String>(), isTrue);
            expect(weaverInstance.isRegistered<int>(), isTrue);
            expect(weaverInstance.get<String>(), 'cart-item');
            expect(weaverInstance.get<int>(), 100);
          });

          test('Should clear only shopping session dependencies when clear() is called', () {
            // Register in shopping session
            weaverInstance.shoppingSession.register<String>('cart-item');

            // Register in test session
            weaverInstance.testSession.register<int>(42);

            // Clear shopping session
            weaverInstance.shoppingSession.clear();

            // shopping session dependency should be cleared
            expect(weaverInstance.isRegistered<String>(), isFalse);

            // test session dependency should still exist
            expect(weaverInstance.isRegistered<int>(), isTrue);
            expect(weaverInstance.get<int>(), 42);
          });
        });

        group('Multiple sessions interaction', () {
          test('Should clear sessions independently', () {
            // Register different types in different sessions
            weaverInstance.testSession.register<String>('test-value');
            weaverInstance.testSession.register<int>(42);
            weaverInstance.shoppingSession.register<double>(3.14);
            weaverInstance.shoppingSession.register<bool>(true);

            // All should be registered
            expect(weaverInstance.isRegistered<String>(), isTrue);
            expect(weaverInstance.isRegistered<int>(), isTrue);
            expect(weaverInstance.isRegistered<double>(), isTrue);
            expect(weaverInstance.isRegistered<bool>(), isTrue);

            // Clear one session
            weaverInstance.testSession.clear();

            // test session dependencies should be cleared
            expect(weaverInstance.isRegistered<String>(), isFalse);
            expect(weaverInstance.isRegistered<int>(), isFalse);

            // shopping session dependencies should still exist
            expect(weaverInstance.isRegistered<double>(), isTrue);
            expect(weaverInstance.isRegistered<bool>(), isTrue);
            expect(weaverInstance.get<double>(), 3.14);
            expect(weaverInstance.get<bool>(), true);
          });
        });
      },
    );
  }
}
