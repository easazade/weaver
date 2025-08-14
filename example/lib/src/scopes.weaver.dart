// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unnecessary_string_interpolations

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
  final _scopeHandlerDelegate = _AdminScope();

  @override
  String get scopeName => 'admin-scope';

  @override
  Future<void> onLeaveScope(Weaver weaver) async {
    await _scopeHandlerDelegate.onLeave(weaver);
  }

  @override
  Future<void> onEnterScope(Weaver weaver, AdminScopeArgs args) async {
    await _scopeHandlerDelegate.onEnterScope(weaver, args.name, args.age);
  }
}

extension AdminScopeX on Weaver {
  bool get isInAdminScope => scopes.where((scope) => scope.name == "admin-scope").isNotEmpty;
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
  final _scopeHandlerDelegate = _AuthScope();

  @override
  String get scopeName => 'auth-scope';

  @override
  Future<void> onLeaveScope(Weaver weaver) async {
    await _scopeHandlerDelegate.onLeaveScope(weaver);
  }

  @override
  Future<void> onEnterScope(Weaver weaver, AuthScopeArgs args) async {
    await _scopeHandlerDelegate.onEnter(weaver, args.user);
  }
}

extension AuthScopeX on Weaver {
  bool get isInAuthScope => scopes.where((scope) => scope.name == "auth-scope").isNotEmpty;
}

class ShoppingScope extends Scope<void> {
  static const String scopeName = 'shopping';

  ShoppingScope() : super(name: "shopping", args: null);
}

class ShoppingHandler extends ScopeHandler<void> {
  final _scopeHandlerDelegate = _ShoppingScope();

  @override
  String get scopeName => 'shopping';

  @override
  Future<void> onLeaveScope(Weaver weaver) async {
    await _scopeHandlerDelegate.onLeaveScope(weaver);
  }

  @override
  Future<void> onEnterScope(Weaver weaver, void args) async {
    await _scopeHandlerDelegate.onEnterScope(weaver);
  }
}

extension ShoppingX on Weaver {
  bool get isInShoppingScope => scopes.where((scope) => scope.name == "shopping").isNotEmpty;
}
