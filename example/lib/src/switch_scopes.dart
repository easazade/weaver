import 'package:weaver/weaver.dart';

part 'switch_scopes.weaver.dart';

@WeaverSwitchScope(name: 'access')
class _AccessScope {
  @OnEnterScope(name: 'admin')
  Future<void> adminAccess(Weaver weaver, String adminKey, int? id) async {}

  @OnEnterScope(name: 'user')
  Future<void> userAccess(Weaver weaver, int userId) async {}

  @OnEnterScope(name: 'public')
  Future<void> publicAccess(Weaver weaver, bool flag) async {}

  @OnEnterScope(name: 'dev')
  Future<void> devAccess(Weaver weaver) async {}

  @OnLeaveScope(name: 'admin')
  Future<void> adminCleanUp(Weaver weaver) async {}
}
