// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unnecessary_string_interpolations

import 'package:weaver/weaver.dart';

class AdminScope extends Scope<AdminScopeArgs> {
  static const String scopeName = 'admin-scope';

  AdminScope(AdminScopeArgs args) : super(name: 'admin-scope', args: args);
}

class AdminScopeArgs {
  final String? name;
  final int age;
  AdminScopeArgs({this.name, required this.age});
}

class MyScope extends ScopeHandler with _MyScope {}

mixin class _MyScope {
  @override
  Future<void> onEnterScope(Weaver weaver, argument) {
    // TODO: implement onEnterScope
    throw UnimplementedError();
  }

  @override
  Future<void> onLeaveScope(Weaver weaver) {
    // TODO: implement onLeaveScope
    throw UnimplementedError();
  }

  @override
  // TODO: implement scopeName
  String get scopeName => throw UnimplementedError();
}
