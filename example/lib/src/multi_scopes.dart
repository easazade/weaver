import 'package:weaver/weaver.dart';

part 'multi_scopes.weaver.dart';

@WeaverScope(name: 'access')
class _AccessScope {
  @OnEnterScope(name: 'admin')
  Future<void> adminAccess(Weaver weaver, String adminKey) async {}

  @OnEnterScope(name: 'user')
  Future<void> userAccess(Weaver weaver, int userId) async {}

  @OnEnterScope(name: 'public')
  Future<void> publicAccess(Weaver weaver, bool flag) async {}

  @OnEnterScope(name: 'dev')
  Future<void> devAccess(Weaver weaver) async {}

  @OnLeaveScope(name: 'admin')
  Future<void> adminCleanUp(Weaver weaver) async {}
}

rt() {
  weaver.enterScope(AccessUserScope(userId: 1));
}
