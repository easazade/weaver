import 'package:weaver/src/base/dependency.dart';
import 'package:weaver/src/base/weaver.dart';

/// Used as a proxy on weaver for generated scope handler classes. provides extra hidden functionality that is only
/// and only required by scope-handlers.
class ScopeHandlerWeaverProxy extends Weaver {
  final keys = <DependencyKey>[];

  @override
  void register<T extends Object>(final T instance, {final String? name, final String? session}) {
    keys.add(DependencyKey(type: T, name: name));
    super.register(instance, name: name, session: session);
  }

  @override
  void registerLazy<T extends Object>(final T Function() callback, {final String? name}) {
    keys.add(DependencyKey(type: T, name: name));
    super.registerLazy(callback, name: name);
  }

  /// unregisters all dependency objects registered using this proxy-weaver by the scope handler
  void unregisterDependencies() {
    for (final key in keys) {
      unregister(type: key.type, name: key.name);
    }
  }
}
