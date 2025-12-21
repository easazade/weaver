// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unnecessary_string_interpolations, unused_field, prefer_final_parameters

part of 'fake_scopes.dart';

class AdminScope extends Scope<AdminScopeArgs> {
  static const String scopeName = 'admin-scope';

  AdminScope({String? name, required int age})
    : super(name: "admin-scope", args: AdminScopeArgs(name, age));
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
  }
}

extension AdminScopeOnWeaverAddedToWeaver on Weaver {
  AdminScopeOnWeaver get adminScope => AdminScopeOnWeaver(this);
}

class AdminScopeOnWeaver {
  final Weaver weaverInstance;

  final _scopeHandlerDelegate = _AdminScope();

  AdminScopeOnWeaver(this.weaverInstance);

  bool get isIn => weaverInstance.scopes
      .where((scope) => scope.name == "admin-scope")
      .isNotEmpty;

  String get adminKey => weaverInstance.get<String>(name: "admin-key");
}
