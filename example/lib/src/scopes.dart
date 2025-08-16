import 'package:example/src/models.dart';
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

@WeaverScope(name: 'auth-scope')
class _AuthScope {
  @OnEnterScope()
  Future<void> onEnter(Weaver weaver, User user) async {
    weaver.register(user);
  }

  @OnLeaveScope()
  Future<void> onLeaveScope(Weaver weaver) async {
    weaver.unregister<User>();
  }
}

@WeaverScope(name: 'shopping')
class _ShoppingScope {
  @OnEnterScope()
  Future<void> onEnterScope(Weaver weaver) async {
    // do nothing
  }

  @OnLeaveScope()
  Future<void> onLeaveScope(Weaver weaver) async {
    // do nothing
  }
}

@NamedDependency(name: 'user-id')
String userId() => '123677283';
