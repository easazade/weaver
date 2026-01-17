import 'package:weaver/src/base/dependency.dart';
import 'package:weaver/src/base/named.dart';
import 'package:weaver/src/base/scope.dart';
import 'package:weaver/src/base/weaver.dart';

/// Used as a proxy on weaver for generated scope handler classes. provides extra hidden functionality that is only
/// and only required by scope-handlers.
class ScopeHandlerWeaverProxy implements Weaver {
  final Weaver _realWeaver;
  ScopeHandlerWeaverProxy(this._realWeaver);

  final keys = <DependencyKey>[];

  @override
  void register<T extends Object>(final T instance, {final String? name, final String? session}) {
    keys.add(DependencyKey(type: T, name: name));
    _realWeaver.register(instance, name: name, session: session);
  }

  @override
  void registerLazy<T extends Object>(final T Function() callback, {final String? name}) {
    keys.add(DependencyKey(type: T, name: name));
    _realWeaver.registerLazy(callback, name: name);
  }

  @override
  void registerIfIsNot<T extends Object>(final T instance, {final String? name, final String? session}) {
    if (!isRegistered<T>(name: name)) {
      register<T>(instance, name: name, session: session);
    }
  }

  /// unregisters all dependency objects registered using this proxy-weaver by the scope handler
  void unregisterDependencies() {
    for (final key in keys) {
      unregister(type: key.type, name: key.name);
    }
  }

  @override
  bool get allowReassignment => _realWeaver.allowReassignment;

  @override
  set allowReassignment(final bool value) => _realWeaver.allowReassignment = value;

  @override
  void addObserver(final Function observer) {
    _realWeaver.addObserver(observer);
  }

  @override
  Future<void> addScopeHandler(final ScopeHandler<dynamic> handler) {
    return _realWeaver.addScopeHandler(handler);
  }

  @override
  void clearSession(final String session) {
    _realWeaver.clearSession(session);
  }

  @override
  Future<void> enterScope(final Scope<dynamic> scope) {
    return _realWeaver.enterScope(scope);
  }

  @override
  T get<T extends Object>({final String? name}) {
    return _realWeaver.get<T>(name: name);
  }

  @override
  Future<T> getAsync<T extends Object>({final String? name}) {
    return _realWeaver.getAsync<T>(name: name);
  }

  @override
  bool isInScope(final String scopeName) {
    return _realWeaver.isInScope(scopeName);
  }

  @override
  bool isRegistered<T extends Object>({final Type? type, final String? name}) {
    return _realWeaver.isRegistered<T>(type: type, name: name);
  }

  @override
  Future<void> leaveScope(final String scopeName) {
    return _realWeaver.leaveScope(scopeName);
  }

  @override
  WeaverNamed get named => _realWeaver.named;

  @override
  void notifyObservers() {
    _realWeaver.notifyObservers();
  }

  @override
  void removeObserver(final Function observer) {
    _realWeaver.removeObserver(observer);
  }

  @override
  Future<void> removeScopeHandler(final String scopeName) {
    return _realWeaver.removeScopeHandler(scopeName);
  }

  @override
  void reset() {
    _realWeaver.reset();
  }

  @override
  Iterable<Scope<dynamic>> get scopes => _realWeaver.scopes;

  @override
  void unregister<T extends Object>({final Type? type, final String? name}) {
    _realWeaver.unregister<T>(type: type, name: name);
  }
}
