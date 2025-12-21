// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unnecessary_string_interpolations, unused_field, prefer_final_parameters

part of 'gen_scope_test.dart';

class GeneratedTestScope extends Scope<GeneratedTestScopeArgs> {
  static const String scopeName = 'generated-test';

  GeneratedTestScope({double? optionalArg, required int arg})
    : super(
        name: "generated-test",
        args: GeneratedTestScopeArgs(optionalArg, arg),
      );
}

class GeneratedTestScopeArgs {
  final double? optionalArg;
  final int arg;

  GeneratedTestScopeArgs(this.optionalArg, this.arg);
}

class GeneratedTestScopeHandler extends ScopeHandler<GeneratedTestScopeArgs> {
  final _scopeHandlerDelegate = _GeneratedTestScope();

  @override
  String get scopeName => 'generated-test';

  @override
  Future<void> onEnterScope(Weaver weaver, GeneratedTestScopeArgs args) async {
    weaver.register<String>(
      _scopeHandlerDelegate._namedValue1(),
      name: "named-key-1",
    );
    weaver.register<String>(
      _scopeHandlerDelegate._namedValue2(),
      name: "named-key-2",
    );

    await _scopeHandlerDelegate.onEnterScope(
      weaver,
      args.optionalArg,
      args.arg,
    );
  }

  @override
  Future<void> onLeaveScope(Weaver weaver) async {
    await _scopeHandlerDelegate.onLeave(weaver);
    weaver.unregister<String>(name: "named-key-1");
  }
}

extension GeneratedTestScopeOnWeaverAddedToWeaver on Weaver {
  GeneratedTestScopeOnWeaver get generatedTest =>
      GeneratedTestScopeOnWeaver(this);
}

class GeneratedTestScopeOnWeaver {
  final Weaver weaverInstance;

  final _scopeHandlerDelegate = _GeneratedTestScope();

  GeneratedTestScopeOnWeaver(this.weaverInstance);

  bool get isIn => weaverInstance.scopes
      .where((scope) => scope.name == "generated-test")
      .isNotEmpty;

  String get namedKey1 => weaverInstance.get<String>(name: "named-key-1");
  String get namedKey2 => weaverInstance.get<String>(name: "named-key-2");
}
