// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unnecessary_string_interpolations, unused_field, prefer_final_parameters

part of 'scopes.dart';

class AdminScope extends Scope<AdminScopeArgs> {
  static const String scopeName = 'admin-scope';

  AdminScope({String? name, required int age}) : super(name: "admin-scope", args: AdminScopeArgs(name, age));
}

class AdminScopeArgs {
  final String? name;
  final int age;

  AdminScopeArgs(this.name, this.age);
}

class AdminScopeHandler extends ScopeHandler<AdminScopeArgs> {
  AdminScopeHandler(super.weaver);

  final _scopeHandlerDelegate = _AdminScope();

  @override
  String get scopeName => 'admin-scope';

  @override
  Future<void> onEnterScope(Weaver weaver, AdminScopeArgs args) async {
    weaver.register<String>(
      _scopeHandlerDelegate._adminKey(),
      name: "admin-key",
    );

    await _scopeHandlerDelegate.onEnterScope(weaver, args.name, args.age);
  }

  @override
  Future<void> onLeaveScope(Weaver weaver) async {
    await _scopeHandlerDelegate.onLeave(weaver);
    weaver.unregister<String>(name: "admin-key");
  }
}

extension AdminScopeOnWeaverAddedToWeaver on Weaver {
  AdminScopeOnWeaver get adminScope => AdminScopeOnWeaver(ScopeHandlerWeaverProxy(this));
}

class AdminScopeOnWeaver {
  final ScopeHandlerWeaverProxy weaverInstance;

  final _scopeHandlerDelegate = _AdminScope();

  AdminScopeOnWeaver(this.weaverInstance);

  bool get isIn => weaverInstance.scopes.where((scope) => scope.name == "admin-scope").isNotEmpty;

  String get adminKey => weaverInstance.get<String>(name: "admin-key");
}

class AuthScope extends Scope<AuthScopeArgs> {
  static const String scopeName = 'auth-scope';

  AuthScope({required User user}) : super(name: "auth-scope", args: AuthScopeArgs(user));
}

class AuthScopeArgs {
  final User user;

  AuthScopeArgs(this.user);
}

class AuthScopeHandler extends ScopeHandler<AuthScopeArgs> {
  AuthScopeHandler(super.weaver);

  final _scopeHandlerDelegate = _AuthScope();

  @override
  String get scopeName => 'auth-scope';

  @override
  Future<void> onEnterScope(Weaver weaver, AuthScopeArgs args) async {
    await _scopeHandlerDelegate.onEnter(weaver, args.user);
  }

  @override
  Future<void> onLeaveScope(Weaver weaver) async {
    await _scopeHandlerDelegate.onLeaveScope(weaver);
  }
}

extension AuthScopeOnWeaverAddedToWeaver on Weaver {
  AuthScopeOnWeaver get authScope => AuthScopeOnWeaver(ScopeHandlerWeaverProxy(this));
}

class AuthScopeOnWeaver {
  final ScopeHandlerWeaverProxy weaverInstance;

  final _scopeHandlerDelegate = _AuthScope();

  AuthScopeOnWeaver(this.weaverInstance);

  bool get isIn => weaverInstance.scopes.where((scope) => scope.name == "auth-scope").isNotEmpty;
}

class ShoppingScope extends Scope<void> {
  static const String scopeName = 'shopping';

  ShoppingScope() : super(name: "shopping", args: null);
}

class ShoppingScopeHandler extends ScopeHandler<void> {
  ShoppingScopeHandler(super.weaver);

  final _scopeHandlerDelegate = _ShoppingScope();

  @override
  String get scopeName => 'shopping';

  @override
  Future<void> onEnterScope(Weaver weaver, void args) async {
    await _scopeHandlerDelegate.onEnterScope(weaver);
  }

  @override
  Future<void> onLeaveScope(Weaver weaver) async {
    await _scopeHandlerDelegate.onLeaveScope(weaver);
  }
}

extension ShoppingScopeOnWeaverAddedToWeaver on Weaver {
  ShoppingScopeOnWeaver get shopping => ShoppingScopeOnWeaver(ScopeHandlerWeaverProxy(this));
}

class ShoppingScopeOnWeaver {
  final ScopeHandlerWeaverProxy weaverInstance;

  final _scopeHandlerDelegate = _ShoppingScope();

  ShoppingScopeOnWeaver(this.weaverInstance);

  bool get isIn => weaverInstance.scopes.where((scope) => scope.name == "shopping").isNotEmpty;
}

class EditScope extends Scope<void> {
  static const String scopeName = 'edit';

  EditScope() : super(name: "edit", args: null);
}

class EditScopeHandler extends ScopeHandler<void> {
  EditScopeHandler(super.weaver);

  final _scopeHandlerDelegate = _EditScope();

  @override
  String get scopeName => 'edit';

  @override
  Future<void> onEnterScope(Weaver weaver, void args) async {
    await _scopeHandlerDelegate.onEnterScope(weaver);
  }

  @override
  Future<void> onLeaveScope(Weaver weaver) async {
    // no methods are annotated with @OnLeaveScope in the scope handler delegate for
    // custom disposal and unregistering of the dependencies registered for this scope
    (weaver as ScopeHandlerWeaverProxy).unregisterDependencies();
  }
}

extension EditScopeOnWeaverAddedToWeaver on Weaver {
  EditScopeOnWeaver get edit => EditScopeOnWeaver(ScopeHandlerWeaverProxy(this));
}

class EditScopeOnWeaver {
  final ScopeHandlerWeaverProxy weaverInstance;

  final _scopeHandlerDelegate = _EditScope();

  EditScopeOnWeaver(this.weaverInstance);

  bool get isIn => weaverInstance.scopes.where((scope) => scope.name == "edit").isNotEmpty;
}

extension NamedDependencyUserIdX on WeaverNamed {
  String get userId {
    if (!weaverInstance.isRegistered<String>(name: "user-id")) {
      weaverInstance.register<String>(_userId(), name: "user-id");
    }
    return weaverInstance.get<String>(name: "user-id");
  }
}

extension NamedDependencyPrivateKeyX on WeaverNamed {
  String get privateKey {
    if (!weaverInstance.isRegistered<String>(name: "private-key")) {
      weaverInstance.register<String>(_privateKey(), name: "private-key");
    }
    return weaverInstance.get<String>(name: "private-key");
  }
}

extension NamedDependencyPublicKeyX on WeaverNamed {
  String get publicKey {
    if (!weaverInstance.isRegistered<String>(name: "public-key")) {
      weaverInstance.register<String>(_publicKey(), name: "public-key");
    }
    return weaverInstance.get<String>(name: "public-key");
  }
}
