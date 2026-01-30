import 'package:weaver/weaver.dart';

part 'switch_scopes.weaver.dart';

@WeaverSwitchScope(name: 'access')
class _AccessScope {
  @OnEnterScope(name: 'admin')
  Future<void> adminAccess(final Weaver weaver, final String adminKey, final int? id) async {
    weaver.register('string');
    weaver.register(AdminAPI(adminKey: adminKey, id: id));
  }

  @OnEnterScope(name: 'user')
  Future<void> userAccess(final Weaver weaver, final int userId) async {
    weaver.register(UserAPI(userId: userId));
  }

  @OnEnterScope(name: 'public')
  Future<void> publicAccess(final Weaver weaver, final bool flag) async {
    weaver.register(PublicAPI(flag: flag));
  }

  @OnEnterScope(name: 'dev')
  Future<void> devAccess(final Weaver weaver) async {
    weaver.register(DevAPI());
  }

  @OnLeaveScope(name: 'admin')
  Future<void> adminCleanUp(final Weaver weaver) async {
    weaver.unregister<AdminAPI>();
    weaver.unregister<String>();
  }
}

class AdminAPI {
  final String adminKey;
  final int? id;

  AdminAPI({required this.adminKey, required this.id});
}

class UserAPI {
  final int userId;

  UserAPI({required this.userId});
}

class PublicAPI {
  final bool flag;

  PublicAPI({required this.flag});
}

class DevAPI {}
