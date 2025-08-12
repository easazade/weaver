// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unnecessary_string_interpolations

part of 'scopes.dart';

class AdminScope extends Scope<AdminScopeArgs> {
  static const String scopeName = 'admin-scope';

  AdminScope(AdminScopeArgs args) : super(name: 'admin-scope', args: args);
}

class AdminScopeArgs {
  final String? name;
  final int age;
  AdminScopeArgs({this.name, required this.age});
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
