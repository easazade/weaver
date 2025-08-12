import 'package:weaver/weaver.dart';

@WeaverScope(name: 'admin-scope')
class AuthScope {
  @OnEnterScope()
  Future<void> onEnterScope(Weaver weaver, ScopeState state, String? name, int age) async {
    weaver.register<String>('Hello I am $name, $age years old');
  }

  @OnLeaveScope()
  Future<void> onLeaveScope(Weaver weaver, ScopeState state) async {
    weaver.unregister<String>();
  }
}
