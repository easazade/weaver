import 'package:test/test.dart';
import 'package:weaver/src/base/dependency.dart';

void main() {
  test(
    'DependencyKey object hashCode should work correctly',
    () {
      final dependencyKey1 = DependencyKey(type: String, name: 'name', session: 'session-name');
      final dependencyKey2 = DependencyKey(type: String, name: 'name', session: 'session-name');
      expect(dependencyKey1.hashCode, dependencyKey2.hashCode);
    },
  );

  test(
    'DependencyKey object equals operator should work correctly',
    () {
      final dependencyKey1 = DependencyKey(type: String, name: 'name', session: 'session-name');
      final dependencyKey2 = DependencyKey(type: String, name: 'name', session: 'session-name');
      final dependencyKey3 = DependencyKey(type: String, name: 'name');
      final dependencyKey4 = DependencyKey(type: String);

      expect(dependencyKey1, equals(dependencyKey2));
      expect(dependencyKey1, isNot(equals(dependencyKey3)));
      expect(dependencyKey3, isNot(equals(dependencyKey4)));
    },
  );
}
