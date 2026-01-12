import 'package:test/test.dart';
import 'package:weaver/src/base/dependency.dart';
import 'package:weaver/src/base/dependency_map.dart';

void main() {
  group('DependencyMap', () {
    late DependencyMap dependencyMap;

    setUp(() {
      dependencyMap = DependencyMap();
    });

    group('set', () {
      test('should set a dependency to the map', () {
        final key = DependencyKey(type: String);
        final dependency = Dependency.value('test');

        dependencyMap.set(key, dependency);

        expect(dependencyMap.find(key), equals(dependency));
      });

      test('should overwrite existing dependency when setting with same key', () {
        final key = DependencyKey(type: String);
        final dependency1 = Dependency.value('first');
        final dependency2 = Dependency.value('second');

        dependencyMap.set(key, dependency1);
        dependencyMap.set(key, dependency2);

        expect(dependencyMap.find(key), equals(dependency2));
        expect(dependencyMap.find(key), isNot(equals(dependency1)));
      });

      test('should set multiple dependencies with different keys', () {
        final key1 = DependencyKey(type: String);
        final key2 = DependencyKey(type: int);
        final dependency1 = Dependency.value('test');
        final dependency2 = Dependency.value(42);

        dependencyMap.set(key1, dependency1);
        dependencyMap.set(key2, dependency2);

        expect(dependencyMap.find(key1), equals(dependency1));
        expect(dependencyMap.find(key2), equals(dependency2));
      });

      test('should set named dependencies correctly', () {
        final key1 = DependencyKey(type: String, name: 'first');
        final key2 = DependencyKey(type: String, name: 'second');
        final dependency1 = Dependency.value('first');
        final dependency2 = Dependency.value('second');

        dependencyMap.set(key1, dependency1);
        dependencyMap.set(key2, dependency2);

        expect(dependencyMap.find(key1), equals(dependency1));
        expect(dependencyMap.find(key2), equals(dependency2));
      });
    });

    group('find', () {
      test('should return null when dependency does not exist', () {
        final key = DependencyKey(type: String);

        expect(dependencyMap.find(key), isNull);
      });

      test('should return the correct dependency when it exists', () {
        final key = DependencyKey(type: String);
        final dependency = Dependency.value('test');

        dependencyMap.set(key, dependency);

        expect(dependencyMap.find(key), equals(dependency));
      });

      test('should return null for different key even if type matches', () {
        final key1 = DependencyKey(type: String, name: 'first');
        final key2 = DependencyKey(type: String, name: 'second');
        final dependency = Dependency.value('test');

        dependencyMap.set(key1, dependency);

        expect(dependencyMap.find(key2), isNull);
      });
    });

    group('keys', () {
      test('should return empty iterable when map is empty', () {
        expect(dependencyMap.keys, isEmpty);
      });

      test('should return all keys that were added', () {
        final key1 = DependencyKey(type: String);
        final key2 = DependencyKey(type: int);
        final key3 = DependencyKey(type: double, name: 'named');

        dependencyMap.set(key1, Dependency.value('test'));
        dependencyMap.set(key2, Dependency.value(42));
        dependencyMap.set(key3, Dependency.value(3.14));

        final keys = dependencyMap.keys.toList();
        expect(keys.length, equals(3));
        expect(keys, contains(key1));
        expect(keys, contains(key2));
        expect(keys, contains(key3));
      });

      test('should update keys when dependencies are removed', () {
        final key1 = DependencyKey(type: String);
        final key2 = DependencyKey(type: int);

        dependencyMap.set(key1, Dependency.value('test'));
        dependencyMap.set(key2, Dependency.value(42));

        expect(dependencyMap.keys.length, equals(2));

        dependencyMap.remove(key1);

        final keys = dependencyMap.keys.toList();
        expect(keys.length, equals(1));
        expect(keys, contains(key2));
        expect(keys, isNot(contains(key1)));
      });
    });

    group('remove', () {
      test('should return null when removing non-existent dependency', () {
        final key = DependencyKey(type: String);

        expect(dependencyMap.remove(key), isNull);
      });

      test('should return the removed dependency when it exists', () {
        final key = DependencyKey(type: String);
        final dependency = Dependency.value('test');

        dependencyMap.set(key, dependency);

        final removed = dependencyMap.remove(key);

        expect(removed, equals(dependency));
        expect(dependencyMap.find(key), isNull);
      });

      test('should remove dependency and make it unfindable', () {
        final key = DependencyKey(type: String);
        final dependency = Dependency.value('test');

        dependencyMap.set(key, dependency);
        expect(dependencyMap.find(key), equals(dependency));

        dependencyMap.remove(key);

        expect(dependencyMap.find(key), isNull);
      });

      test('should handle removing with null key', () {
        expect(dependencyMap.remove(null), isNull);
      });

      test('should only remove the specified dependency', () {
        final key1 = DependencyKey(type: String);
        final key2 = DependencyKey(type: int);
        final dependency1 = Dependency.value('test');
        final dependency2 = Dependency.value(42);

        dependencyMap.set(key1, dependency1);
        dependencyMap.set(key2, dependency2);

        dependencyMap.remove(key1);

        expect(dependencyMap.find(key1), isNull);
        expect(dependencyMap.find(key2), equals(dependency2));
      });
    });

    group('clear', () {
      test('should clear all dependencies', () {
        final key1 = DependencyKey(type: String);
        final key2 = DependencyKey(type: int);
        final key3 = DependencyKey(type: double, name: 'named');

        dependencyMap.set(key1, Dependency.value('test'));
        dependencyMap.set(key2, Dependency.value(42));
        dependencyMap.set(key3, Dependency.value(3.14));

        expect(dependencyMap.keys.length, equals(3));

        dependencyMap.clear();

        expect(dependencyMap.keys, isEmpty);
        expect(dependencyMap.find(key1), isNull);
        expect(dependencyMap.find(key2), isNull);
        expect(dependencyMap.find(key3), isNull);
      });

      test('should clear empty map without error', () {
        expect(() => dependencyMap.clear(), returnsNormally);
        expect(dependencyMap.keys, isEmpty);
      });

      test('should allow adding dependencies after clearing', () {
        final key1 = DependencyKey(type: String);
        final key2 = DependencyKey(type: int);

        dependencyMap.set(key1, Dependency.value('test'));
        dependencyMap.clear();
        dependencyMap.set(key2, Dependency.value(42));

        expect(dependencyMap.keys.length, equals(1));
        expect(dependencyMap.find(key1), isNull);
        expect(dependencyMap.find(key2), isNotNull);
      });
    });

    group('containsKey', () {
      test('should return false when key does not exist', () {
        final key = DependencyKey(type: String);

        expect(dependencyMap.containsKey(key), isFalse);
      });

      test('should return true when key exists', () {
        final key = DependencyKey(type: String);
        final dependency = Dependency.value('test');

        dependencyMap.set(key, dependency);

        expect(dependencyMap.containsKey(key), isTrue);
      });

      test('should return false after removing a key', () {
        final key = DependencyKey(type: String);
        final dependency = Dependency.value('test');

        dependencyMap.set(key, dependency);
        expect(dependencyMap.containsKey(key), isTrue);

        dependencyMap.remove(key);
        expect(dependencyMap.containsKey(key), isFalse);
      });

      test('should return false for different key even if type matches', () {
        final key1 = DependencyKey(type: String, name: 'first');
        final key2 = DependencyKey(type: String, name: 'second');
        final dependency = Dependency.value('test');

        dependencyMap.set(key1, dependency);

        expect(dependencyMap.containsKey(key1), isTrue);
        expect(dependencyMap.containsKey(key2), isFalse);
      });

      test('should return true for multiple existing keys', () {
        final key1 = DependencyKey(type: String);
        final key2 = DependencyKey(type: int);
        final key3 = DependencyKey(type: double, name: 'named');

        dependencyMap.set(key1, Dependency.value('test'));
        dependencyMap.set(key2, Dependency.value(42));
        dependencyMap.set(key3, Dependency.value(3.14));

        expect(dependencyMap.containsKey(key1), isTrue);
        expect(dependencyMap.containsKey(key2), isTrue);
        expect(dependencyMap.containsKey(key3), isTrue);
      });

      test('should return false after clearing', () {
        final key = DependencyKey(type: String);
        final dependency = Dependency.value('test');

        dependencyMap.set(key, dependency);
        expect(dependencyMap.containsKey(key), isTrue);

        dependencyMap.clear();
        expect(dependencyMap.containsKey(key), isFalse);
      });
    });

    group('removeWhere', () {
      test('should remove dependencies matching predicate', () {
        final key1 = DependencyKey(type: String);
        final key2 = DependencyKey(type: int);
        final key3 = DependencyKey(type: double);

        dependencyMap.set(key1, Dependency.value('test'));
        dependencyMap.set(key2, Dependency.value(42));
        dependencyMap.set(key3, Dependency.value(3.14));

        dependencyMap.removeWhere((final key) => key.type == int);

        expect(dependencyMap.containsKey(key1), isTrue);
        expect(dependencyMap.containsKey(key2), isFalse);
        expect(dependencyMap.containsKey(key3), isTrue);
      });

      test('should remove multiple dependencies matching predicate', () {
        final key1 = DependencyKey(type: String, name: 'first');
        final key2 = DependencyKey(type: String, name: 'second');
        final key3 = DependencyKey(type: int);

        dependencyMap.set(key1, Dependency.value('first'));
        dependencyMap.set(key2, Dependency.value('second'));
        dependencyMap.set(key3, Dependency.value(42));

        dependencyMap.removeWhere((final key) => key.type == String);

        expect(dependencyMap.containsKey(key1), isFalse);
        expect(dependencyMap.containsKey(key2), isFalse);
        expect(dependencyMap.containsKey(key3), isTrue);
      });

      test('should remove all dependencies when predicate always returns true', () {
        final key1 = DependencyKey(type: String);
        final key2 = DependencyKey(type: int);
        final key3 = DependencyKey(type: double);

        dependencyMap.set(key1, Dependency.value('test'));
        dependencyMap.set(key2, Dependency.value(42));
        dependencyMap.set(key3, Dependency.value(3.14));

        dependencyMap.removeWhere((final key) => true);

        expect(dependencyMap.keys, isEmpty);
      });

      test('should remove no dependencies when predicate always returns false', () {
        final key1 = DependencyKey(type: String);
        final key2 = DependencyKey(type: int);

        dependencyMap.set(key1, Dependency.value('test'));
        dependencyMap.set(key2, Dependency.value(42));

        dependencyMap.removeWhere((final key) => false);

        expect(dependencyMap.keys.length, equals(2));
        expect(dependencyMap.containsKey(key1), isTrue);
        expect(dependencyMap.containsKey(key2), isTrue);
      });

      test('should handle empty map', () {
        expect(() => dependencyMap.removeWhere((final key) => true), returnsNormally);
        expect(dependencyMap.keys, isEmpty);
      });

      test('should remove dependencies based on name', () {
        final key1 = DependencyKey(type: String, name: 'first');
        final key2 = DependencyKey(type: String, name: 'second');
        final key3 = DependencyKey(type: String);

        dependencyMap.set(key1, Dependency.value('first'));
        dependencyMap.set(key2, Dependency.value('second'));
        dependencyMap.set(key3, Dependency.value('unnamed'));

        dependencyMap.removeWhere((final key) => key.name == 'first');

        expect(dependencyMap.containsKey(key1), isFalse);
        expect(dependencyMap.containsKey(key2), isTrue);
        expect(dependencyMap.containsKey(key3), isTrue);
      });
    });

    group('hasValue', () {
      test('should return false when key does not exist', () {
        final key = DependencyKey(type: String);

        expect(dependencyMap.hasValue(key), isFalse);
      });

      test('should return true for dependency with value', () {
        final key = DependencyKey(type: String);
        final dependency = Dependency.value('test');

        dependencyMap.set(key, dependency);

        expect(dependencyMap.hasValue(key), isTrue);
      });

      test('should return true for lazy dependency', () {
        final key = DependencyKey(type: String);
        final dependency = Dependency.lazy(() => 'lazy');

        dependencyMap.set(key, dependency);

        expect(dependencyMap.hasValue(key), isTrue);
      });

      test('should return false for placeholder dependency', () {
        final key = DependencyKey(type: String);
        final dependency = Dependency.placeHolder();

        dependencyMap.set(key, dependency);

        expect(dependencyMap.hasValue(key), isFalse);
      });

      test('should return true for dependency with null value but lazy callback', () {
        final key = DependencyKey(type: String);
        final dependency = Dependency.lazy(() => 'lazy');

        dependencyMap.set(key, dependency);

        expect(dependencyMap.hasValue(key), isTrue);
      });

      test('should return false after removing dependency', () {
        final key = DependencyKey(type: String);
        final dependency = Dependency.value('test');

        dependencyMap.set(key, dependency);
        expect(dependencyMap.hasValue(key), isTrue);

        dependencyMap.remove(key);
        expect(dependencyMap.hasValue(key), isFalse);
      });

      test('should return true for multiple dependencies with values', () {
        final key1 = DependencyKey(type: String);
        final key2 = DependencyKey(type: int);
        final key3 = DependencyKey(type: double);

        dependencyMap.set(key1, Dependency.value('test'));
        dependencyMap.set(key2, Dependency.value(42));
        dependencyMap.set(key3, Dependency.lazy(() => 3.14));

        expect(dependencyMap.hasValue(key1), isTrue);
        expect(dependencyMap.hasValue(key2), isTrue);
        expect(dependencyMap.hasValue(key3), isTrue);
      });

      test('should return false after clearing', () {
        final key = DependencyKey(type: String);
        final dependency = Dependency.value('test');

        dependencyMap.set(key, dependency);
        expect(dependencyMap.hasValue(key), isTrue);

        dependencyMap.clear();
        expect(dependencyMap.hasValue(key), isFalse);
      });
    });

    group('entries', () {
      test('should return empty iterable when map is empty', () {
        expect(dependencyMap.entries, isEmpty);
      });

      test('should return all entries that were added', () {
        final key1 = DependencyKey(type: String);
        final key2 = DependencyKey(type: int);
        final key3 = DependencyKey(type: double, name: 'named');
        final dependency1 = Dependency.value('test');
        final dependency2 = Dependency.value(42);
        final dependency3 = Dependency.value(3.14);

        dependencyMap.set(key1, dependency1);
        dependencyMap.set(key2, dependency2);
        dependencyMap.set(key3, dependency3);

        final entries = dependencyMap.entries.toList();
        expect(entries.length, equals(3));

        final entryMap = Map.fromEntries(entries);
        expect(entryMap[key1], equals(dependency1));
        expect(entryMap[key2], equals(dependency2));
        expect(entryMap[key3], equals(dependency3));
      });

      test('should update entries when dependencies are removed', () {
        final key1 = DependencyKey(type: String);
        final key2 = DependencyKey(type: int);
        final dependency1 = Dependency.value('test');
        final dependency2 = Dependency.value(42);

        dependencyMap.set(key1, dependency1);
        dependencyMap.set(key2, dependency2);

        expect(dependencyMap.entries.length, equals(2));

        dependencyMap.remove(key1);

        final entries = dependencyMap.entries.toList();
        expect(entries.length, equals(1));
        final entryMap = Map.fromEntries(entries);
        expect(entryMap[key2], equals(dependency2));
        expect(entryMap.containsKey(key1), isFalse);
      });

      test('should return entries with correct keys and values', () {
        final key1 = DependencyKey(type: String);
        final key2 = DependencyKey(type: int);
        final dependency1 = Dependency.value('test');
        final dependency2 = Dependency.lazy(() => 42);

        dependencyMap.set(key1, dependency1);
        dependencyMap.set(key2, dependency2);

        final entries = dependencyMap.entries.toList();
        expect(entries.length, equals(2));

        final entry1 = entries.firstWhere((final e) => e.key == key1);
        final entry2 = entries.firstWhere((final e) => e.key == key2);

        expect(entry1.value, equals(dependency1));
        expect(entry2.value, equals(dependency2));
      });

      test('should return empty entries after clearing', () {
        final key1 = DependencyKey(type: String);
        final key2 = DependencyKey(type: int);

        dependencyMap.set(key1, Dependency.value('test'));
        dependencyMap.set(key2, Dependency.value(42));

        expect(dependencyMap.entries.length, equals(2));

        dependencyMap.clear();

        expect(dependencyMap.entries, isEmpty);
      });

      test('should reflect changes when dependencies are overwritten', () {
        final key = DependencyKey(type: String);
        final dependency1 = Dependency.value('first');
        final dependency2 = Dependency.value('second');

        dependencyMap.set(key, dependency1);
        final entries1 = dependencyMap.entries.toList();
        expect(entries1.length, equals(1));
        expect(entries1.first.value, equals(dependency1));

        dependencyMap.set(key, dependency2);
        final entries2 = dependencyMap.entries.toList();
        expect(entries2.length, equals(1));
        expect(entries2.first.value, equals(dependency2));
      });

      test('should return entries for different dependency types', () {
        final key1 = DependencyKey(type: String);
        final key2 = DependencyKey(type: int);
        final key3 = DependencyKey(type: bool);
        final dependency1 = Dependency.value('test');
        final dependency2 = Dependency.value(42);
        final dependency3 = Dependency.placeHolder();

        dependencyMap.set(key1, dependency1);
        dependencyMap.set(key2, dependency2);
        dependencyMap.set(key3, dependency3);

        final entries = dependencyMap.entries.toList();
        expect(entries.length, equals(3));

        final entryMap = Map.fromEntries(entries);
        expect(entryMap[key1], equals(dependency1));
        expect(entryMap[key2], equals(dependency2));
        expect(entryMap[key3], equals(dependency3));
      });
    });

    group('integration tests', () {
      test('should handle full lifecycle: add, find, remove, clear', () {
        final key1 = DependencyKey(type: String);
        final key2 = DependencyKey(type: int);
        final dependency1 = Dependency.value('test');
        final dependency2 = Dependency.value(42);

        // Add dependencies
        dependencyMap.set(key1, dependency1);
        dependencyMap.set(key2, dependency2);
        expect(dependencyMap.keys.length, equals(2));

        // Find dependencies
        expect(dependencyMap.find(key1), equals(dependency1));
        expect(dependencyMap.find(key2), equals(dependency2));

        // Remove one dependency
        final removed = dependencyMap.remove(key1);
        expect(removed, equals(dependency1));
        expect(dependencyMap.keys.length, equals(1));
        expect(dependencyMap.find(key1), isNull);
        expect(dependencyMap.find(key2), equals(dependency2));

        // Clear remaining
        dependencyMap.clear();
        expect(dependencyMap.keys, isEmpty);
        expect(dependencyMap.find(key2), isNull);
      });

      test('should handle different dependency types', () {
        final stringKey = DependencyKey(type: String);
        final intKey = DependencyKey(type: int);
        final doubleKey = DependencyKey(type: double);
        final boolKey = DependencyKey(type: bool);

        dependencyMap.set(stringKey, Dependency.value('test'));
        dependencyMap.set(intKey, Dependency.value(42));
        dependencyMap.set(doubleKey, Dependency.value(3.14));
        dependencyMap.set(boolKey, Dependency.value(true));

        expect(dependencyMap.keys.length, equals(4));
        expect(dependencyMap.find(stringKey)?.value, equals('test'));
        expect(dependencyMap.find(intKey)?.value, equals(42));
        expect(dependencyMap.find(doubleKey)?.value, equals(3.14));
        expect(dependencyMap.find(boolKey)?.value, equals(true));
      });

      test('should handle lazy dependencies', () {
        final key = DependencyKey(type: String);
        final dependency = Dependency.lazy(() => 'lazy');

        dependencyMap.set(key, dependency);

        expect(dependencyMap.find(key), equals(dependency));
        expect(dependencyMap.find(key)?.lazyInstantiateCallback, isNotNull);
      });

      test('should handle placeholder dependencies', () {
        final key = DependencyKey(type: String);
        final dependency = Dependency.placeHolder();

        dependencyMap.set(key, dependency);

        expect(dependencyMap.find(key), equals(dependency));
        expect(dependencyMap.find(key)?.value, isNull);
        expect(dependencyMap.find(key)?.lazyInstantiateCallback, isNull);
      });
    });
  });
}
