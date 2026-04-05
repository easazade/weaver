import 'package:weaver/weaver.dart';

/// Customized Map for managing the dependency objects.
///
/// Creates an empty [DependencyMap].
class DependencyMap {
  final _dependencies = <DependencyKey, Dependency>{};
  final _sessions = <DependencyKey, String>{};

  Dependency? find(final DependencyKey key) => _dependencies[key];

  Iterable<DependencyKey> get keys => _dependencies.keys;

  bool hasValue(final DependencyKey key) => _dependencies[key]?.hasValue ?? false;

  Iterable<MapEntry<DependencyKey, Dependency>> get entries => _dependencies.entries;

  bool containsKey(final DependencyKey key) => _dependencies.containsKey(key);

  void set(final DependencyKey key, final Dependency dependency, {final String? session}) {
    _dependencies[key] = dependency;
    if (session != null) {
      _sessions[key] = session;
    }
  }

  Dependency? remove(final DependencyKey? key) {
    _sessions.remove(key);
    return _dependencies.remove(key);
  }

  void removeWhere(final bool Function(DependencyKey key) predicate) {
    _dependencies.removeWhere((final key, final _) => predicate(key));
    _sessions.removeWhere((final key, final _) => predicate(key));
  }

  Map<DependencyKey, Dependency> findBySession(final String sessionName) {
    final matches = _sessions.entries.where((final e) {
      final session = e.value;
      return session == sessionName;
    }).map((final e) {
      final dependencyKey = e.key;
      final dependency = _dependencies[dependencyKey];
      if (dependency != null) {
        return MapEntry(dependencyKey, dependency);
      } else {
        return null;
      }
    }).nonNulls;

    return {}..addEntries(matches);
  }

  void removeBySession(final String session) {
    final matchedKeys = _sessions.entries.toList().where((final e) => e.value == session).map((final e) => e.key);
    for (final key in matchedKeys) {
      removeWhere((final k) => k == key);
    }
  }

  void clear() {
    _dependencies.clear();
    _sessions.clear();
  }
}
