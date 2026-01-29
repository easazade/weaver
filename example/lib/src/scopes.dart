import 'package:example/src/models.dart';
import 'package:weaver/weaver.dart';

part 'scopes.weaver.dart';

@WeaverScope(name: 'admin-scope')
class _AdminScope {
  @OnEnterScope()
  Future<void> onEnterScope(Weaver weaver, String? name, int age) async {
    weaver.register<String>('Hello I am $name, $age years old');
  }

  @NamedDependency(name: 'admin-key')
  String _adminKey() => 'key-of-admin-jhu8';

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

@WeaverScope(name: 'edit')
class _EditScope {
  @OnEnterScope()
  Future<void> onEnterScope(Weaver weaver) async {
    weaver.register('Ali');
    weaver.register('Reza', name: 'admin');
    weaver.register<int>(2);
    weaver.register<double>(3.14);
  }
}

@WeaverScope(name: 'access')
class _AccessScope {
  @OnEnterScope(name: 'admin')
  Future<void> adminAccess(Weaver weaver, String adminKey) async {}

  @OnEnterScope(name: 'user')
  Future<void> userAccess(Weaver weaver, int userId) async {}

  @OnEnterScope(name: 'public')
  Future<void> publicAccess(Weaver weaver, bool flag) async {}
}

@NamedDependency(name: 'user-id')
String _userId() => '123677283';

@NamedDependency(name: 'private-key')
String _privateKey() => 'iuigauywgdiuaw9-a8whdaio-aihwudi7wt7t72ueyfkmnvap';

@NamedDependency(name: 'public-key')
String _publicKey() => '-aihwudi7wt7t72ueyfkmnvap-gf6taw8-uydtgfghj-8689-a-a2b';
