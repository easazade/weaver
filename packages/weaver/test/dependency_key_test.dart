import 'package:test/test.dart';
import 'package:weaver/src/base/dependency.dart';

void main() {
  test(
    'DependencyKey object hashCode should work correctly',
    () {
      final dependencyKey1 = const DependencyKey(type: String, name: 'name');
      final dependencyKey2 = const DependencyKey(type: String, name: 'name');
      expect(dependencyKey1.hashCode, dependencyKey2.hashCode);
    },
  );

  test(
    'DependencyKey object equals operator should work correctly',
    () {
      final dependencyKey1 = const DependencyKey(type: String, name: 'name');
      final dependencyKey2 = const DependencyKey(type: String, name: 'name');
      final dependencyKey3 = const DependencyKey(type: String);

      expect(dependencyKey1, equals(dependencyKey2));
      expect(dependencyKey1, isNot(equals(dependencyKey3)));
    },
  );
}
