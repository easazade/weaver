import 'package:weaver/weaver.dart';

part 'scopes.weaver.dart';

@WeaverScope(name: 'admin-scope')
class _AdminScope {
  @OnEnterScope()
  Future<void> onEnterScope(Weaver weaver, String? name, int age) async {
    weaver.register<String>('Hello I am $name, $age years old');
  }

  @OnLeaveScope()
  Future<void> onLeave(Weaver weaverInstance) async {
    weaver.unregister<String>();
  }
}
