import 'package:weaver/weaver.dart';

part 'fake_scopes.weaver.dart';

@WeaverScope(name: 'admin-scope')
class _AdminScope {
  @OnEnterScope()
  Future<void> onEnterScope(final Weaver weaver, final String? name, final int age) async {
    weaver.register<String>('Hello I am $name, $age years old');
  }

  @NamedDependency(name: 'admin-key', autoDispose: false)
  String _adminKey() => 'key-of-admin-jhu8';

  @OnLeaveScope()
  Future<void> onLeave(final Weaver weaverInstance) async {
    weaver.unregister<String>();
  }
}
