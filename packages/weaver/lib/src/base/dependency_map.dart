import 'package:weaver/weaver.dart';

class DependencyMap {
  final _dependencies = <DependencyKey, Dependency>{};
  final _sessions = <DependencyKey, String>{};

  void set(final DependencyKey key, final Dependency dependency) {
    _dependencies[key] = dependency;
  }

  Dependency? find(final DependencyKey key) {
    return _dependencies[key];
  }

  Iterable<DependencyKey> get keys => _dependencies.keys;

  Dependency? remove(final DependencyKey? key) => _dependencies.remove(key);

  void clear() {
    _dependencies.clear();
    _sessions.clear();
  }

  bool containsKey(final DependencyKey key) => _dependencies.containsKey(key);

  void removeWhere(final bool Function(DependencyKey key) predicate) {
    _dependencies.removeWhere((final key, final value) => predicate(key));
  }

  bool hasValue(final DependencyKey key) => _dependencies[key]?.hasValue ?? false;

  Iterable<MapEntry<DependencyKey, Dependency>> get entries => _dependencies.entries;
}
