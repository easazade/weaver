// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unnecessary_string_interpolations, unused_field, prefer_final_parameters

part of 'switch_scopes.dart';

class BaseAccessScopeArgs {}

class AccessAdminScope extends Scope<AccessScopeAdminArgs> {
  static const String scopeName = 'access-admin';

  AccessAdminScope({required String adminKey, int? id})
    : super(name: "access-admin", args: AccessScopeAdminArgs(adminKey, id));
}

class AccessScopeAdminArgs extends BaseAccessScopeArgs {
  // properties
  final String adminKey;

  final int? id;

  // constructor
  AccessScopeAdminArgs(this.adminKey, this.id);
}

class AccessUserScope extends Scope<AccessScopeUserArgs> {
  static const String scopeName = 'access-user';

  AccessUserScope({required int userId})
    : super(name: "access-user", args: AccessScopeUserArgs(userId));
}

class AccessScopeUserArgs extends BaseAccessScopeArgs {
  // properties
  final int userId;

  // constructor
  AccessScopeUserArgs(this.userId);
}

class AccessPublicScope extends Scope<AccessScopePublicArgs> {
  static const String scopeName = 'access-public';

  AccessPublicScope({required bool flag})
    : super(name: "access-public", args: AccessScopePublicArgs(flag));
}

class AccessScopePublicArgs extends BaseAccessScopeArgs {
  // properties
  final bool flag;

  // constructor
  AccessScopePublicArgs(this.flag);
}

class AccessDevScope extends Scope<BaseAccessScopeArgs> {
  static const String scopeName = 'access-dev';

  AccessDevScope() : super(name: "access-dev", args: BaseAccessScopeArgs());
}

class AccessScope {
  AccessScope._();

  static AccessAdminScope admin({required String adminKey, int? id}) =>
      AccessAdminScope(adminKey: adminKey, id: id);

  static AccessUserScope user({required int userId}) =>
      AccessUserScope(userId: userId);

  static AccessPublicScope public({required bool flag}) =>
      AccessPublicScope(flag: flag);

  static AccessDevScope dev() => AccessDevScope();
}

class AccessScopeHandler extends SwitchScopeHandler<BaseAccessScopeArgs> {
  AccessScopeHandler(super.weaver);

  final _scopeHandlerDelegate = _AccessScope();
  final _allScopeNames = [
    'access-admin',
    'access-user',
    'access-public',
    'access-dev',
  ];

  @override
  String get scopeName => 'access';

  @override
  bool canHandleScope(String scopeName) => _allScopeNames.contains(scopeName);

  @override
  Future<void> onEnterScopeByScope(Scope<dynamic> scope) async {
    if (scope.name == 'access-admin') {
      final args = scope.args as AccessScopeAdminArgs;
      await _scopeHandlerDelegate.adminAccess(
        this.weaver,
        args.adminKey,
        args.id,
      );
    }

    if (scope.name == 'access-user') {
      final args = scope.args as AccessScopeUserArgs;
      await _scopeHandlerDelegate.userAccess(this.weaver, args.userId);
    }

    if (scope.name == 'access-public') {
      final args = scope.args as AccessScopePublicArgs;
      await _scopeHandlerDelegate.publicAccess(this.weaver, args.flag);
    }

    if (scope.name == 'access-dev') {
      await _scopeHandlerDelegate.devAccess(this.weaver);
    }
  }

  @override
  Future<void> onLeaveScopeByName(String scopeName) async {
    if (scopeName == 'access-admin') {
      await _scopeHandlerDelegate.adminCleanUp(this.weaver);
    } else {
      this.weaver.unregisterDependenciesRegisteredByThisProxy();
    }
  }
}

extension AccessScopeOnWeaverAddedToWeaver on Weaver {
  AccessScopeOnWeaver get accessScope =>
      AccessScopeOnWeaver(ScopeHandlerWeaverProxy(this));
}

class AccessScopeOnWeaver {
  final ScopeHandlerWeaverProxy weaverInstance;

  final _scopeHandlerDelegate = _AccessScope();

  AccessScopeOnWeaver(this.weaverInstance);

  bool get isAdmin => weaverInstance.isInScope("access-admin");
  bool get isUser => weaverInstance.isInScope("access-user");
  bool get isPublic => weaverInstance.isInScope("access-public");
  bool get isDev => weaverInstance.isInScope("access-dev");
}
