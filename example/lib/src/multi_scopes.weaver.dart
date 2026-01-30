// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unnecessary_string_interpolations, unused_field, prefer_final_parameters

part of 'multi_scopes.dart';

class BaseAccessScopeArgs {}

class AccessAdminScope extends Scope<AccessScopeAdminArgs> {
  static const String scopeName = 'access-admin';

  AccessAdminScope({required String adminKey})
    : super(name: "access-admin", args: AccessScopeAdminArgs(adminKey));
}

class AccessScopeAdminArgs extends BaseAccessScopeArgs {
  // properties
  final String adminKey;

  // constructor
  AccessScopeAdminArgs(this.adminKey);
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

class AccessScopeHandler extends MultiScopeHandler<BaseAccessScopeArgs> {
  AccessScopeHandler(super.weaver);

  final _scopeHandlerDelegate = _AccessScope();

  @override
  String get scopeName => 'access';

  @override
  Future<void> onEnterScope(Weaver weaver, BaseAccessScopeArgs args) async {
    //TODO ?????
  }

  @override
  Future<void> onLeaveScope(Weaver weaver) async {
    // no methods are annotated with @OnLeaveScope in the scope handler delegate for
    // custom disposal and unregistering of the dependencies registered for this scope
    (weaver as ScopeHandlerWeaverProxy)
        .unregisterDependenciesRegisteredByThisProxy();
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

  bool get isIn =>
      weaverInstance.scopes.where((scope) => scope.name == "access").isNotEmpty;
}
