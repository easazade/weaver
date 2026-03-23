// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unnecessary_string_interpolations, unused_field, prefer_final_parameters

part of 'switch_scopes.dart';

class BaseAccessScopeArgs {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseAccessScopeArgs && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class AccessAdminScope extends Scope<AccessScopeAdminArgs> {
  static const String scopeName = 'access-admin';

  AccessAdminScope({required String adminKey, int? id})
    : super(name: "access-admin", args: AccessScopeAdminArgs(adminKey, id));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccessAdminScope && name == other.name && args == other.args;

  @override
  int get hashCode => Object.hashAll([name, args]);
}

class AccessScopeAdminArgs extends BaseAccessScopeArgs {
  // properties
  final String adminKey;

  final int? id;

  // constructor
  AccessScopeAdminArgs(this.adminKey, this.id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccessScopeAdminArgs &&
          adminKey == other.adminKey &&
          id == other.id;

  @override
  int get hashCode => Object.hashAll([adminKey, id]);
}

class AccessUserScope extends Scope<AccessScopeUserArgs> {
  static const String scopeName = 'access-user';

  AccessUserScope({required int userId})
    : super(name: "access-user", args: AccessScopeUserArgs(userId));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccessUserScope && name == other.name && args == other.args;

  @override
  int get hashCode => Object.hashAll([name, args]);
}

class AccessScopeUserArgs extends BaseAccessScopeArgs {
  // properties
  final int userId;

  // constructor
  AccessScopeUserArgs(this.userId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccessScopeUserArgs && userId == other.userId;

  @override
  int get hashCode => Object.hashAll([userId]);
}

class AccessPublicScope extends Scope<AccessScopePublicArgs> {
  static const String scopeName = 'access-public';

  AccessPublicScope({required bool flag})
    : super(name: "access-public", args: AccessScopePublicArgs(flag));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccessPublicScope && name == other.name && args == other.args;

  @override
  int get hashCode => Object.hashAll([name, args]);
}

class AccessScopePublicArgs extends BaseAccessScopeArgs {
  // properties
  final bool flag;

  // constructor
  AccessScopePublicArgs(this.flag);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccessScopePublicArgs && flag == other.flag;

  @override
  int get hashCode => Object.hashAll([flag]);
}

class AccessDevScope extends Scope<BaseAccessScopeArgs> {
  static const String scopeName = 'access-dev';

  AccessDevScope() : super(name: "access-dev", args: BaseAccessScopeArgs());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccessDevScope && name == other.name && args == other.args;

  @override
  int get hashCode => Object.hashAll([name, args]);
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

  static String get adminScopeName => "access-admin";
  static String get userScopeName => "access-user";
  static String get publicScopeName => "access-public";
  static String get devScopeName => "access-dev";
}

class AccessScopeHandler extends SwitchScopeHandler<BaseAccessScopeArgs> {
  AccessScopeHandler(
    super.weaver, {
    super.changeScopeStream,
    super.defaultScope,
  });

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
        weaverInstance,
        args.adminKey,
        args.id,
      );
    }

    if (scope.name == 'access-user') {
      final args = scope.args as AccessScopeUserArgs;
      await _scopeHandlerDelegate.userAccess(weaverInstance, args.userId);
    }

    if (scope.name == 'access-public') {
      final args = scope.args as AccessScopePublicArgs;
      await _scopeHandlerDelegate.publicAccess(weaverInstance, args.flag);
    }

    if (scope.name == 'access-dev') {
      await _scopeHandlerDelegate.devAccess(weaverInstance);
    }
  }

  @override
  Future<void> onLeaveScopeByName(String scopeName) async {
    if (scopeName == 'access-admin') {
      await _scopeHandlerDelegate.adminCleanUp(weaverInstance);
    } else {
      weaverInstance.unregisterDependenciesRegisteredByThisProxy();
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

  Scope<BaseAccessScopeArgs>? get currentScope {
    final matches = weaverInstance.scopes
        .whereType<Scope<BaseAccessScopeArgs>>();
    return matches.firstOrNull;
  }

  @Deprecated('Use ensureEnterScope() method instead')
  Future<Scope<BaseAccessScopeArgs>> awaitEnterScope() => ensureEnterScope();

  /// This method can be used to wait and ensure for enter scope.
  /// If scope has already entered Returns current scope.
  Future<Scope<BaseAccessScopeArgs>> ensureEnterScope() async {
    final matches = weaverInstance.handlers.whereType<AccessScopeHandler>();
    if (matches.isEmpty) {
      throw WeaverException(
        'Tried to await entering a scope without a handler class registered. '
        'Please register an instance of AccessScopeHandler first before calling awaitEnterScope()',
      );
    }

    final handler = matches.first;
    return handler.ensureEnterScope();
  }

  Stream<Scope<BaseAccessScopeArgs>?> get stream {
    final matches = weaverInstance.handlers.whereType<AccessScopeHandler>();
    if (matches.isEmpty) {
      throw WeaverException(
        'Tried to listen on stream of access switch-scope without a handler class registered. '
        'Please register an instance of AccessScopeHandler first before trying to listen to its stream',
      );
    }

    final handler = matches.first;
    return handler.stream;
  }
}
