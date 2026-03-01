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

class GeneratedTestScopeHandler
    extends SingleScopeHandler<GeneratedTestScopeArgs> {
  GeneratedTestScopeHandler(super.weaver, {super.changeScopeStream});

  final _scopeHandlerDelegate = _GeneratedTestScope();

  @override
  String get scopeName => 'generated-test';

  @override
  Future<void> onEnterScope(Weaver weaver, GeneratedTestScopeArgs args) async {
    weaverInstance.register<String>(
      _scopeHandlerDelegate._namedValue1(),
      name: "named-key-1",
    );
    weaverInstance.register<String>(
      _scopeHandlerDelegate._namedValue2(),
      name: "named-key-2",
    );

    await _scopeHandlerDelegate.onEnterScope(
      weaverInstance,
      args.optionalArg,
      args.arg,
    );
  }

  @override
  Future<void> onLeaveScope(Weaver weaver) async {
    await _scopeHandlerDelegate.onLeave(weaverInstance);
    weaverInstance.unregister<String>(name: "named-key-1");
  }
}

extension GeneratedTestScopeOnWeaverAddedToWeaver on Weaver {
  GeneratedTestScopeOnWeaver get generatedTestScope =>
      GeneratedTestScopeOnWeaver(ScopeHandlerWeaverProxy(this));
}

class GeneratedTestScopeOnWeaver {
  final ScopeHandlerWeaverProxy weaverInstance;

  final _scopeHandlerDelegate = _GeneratedTestScope();

  GeneratedTestScopeOnWeaver(this.weaverInstance);

  bool get isIn => weaverInstance.scopes
      .where((scope) => scope.name == "generated-test")
      .isNotEmpty;

  String get namedKey1 => weaverInstance.get<String>(name: "named-key-1");
  String get namedKey2 => weaverInstance.get<String>(name: "named-key-2");

  Stream<Scope<GeneratedTestScopeArgs>?> get stream {
    final matches = weaverInstance.handlers
        .whereType<GeneratedTestScopeHandler>();
    if (matches.isEmpty) {
      throw WeaverException(
        'Tried to listen on stream of GeneratedTestScope without a handler class registered. '
        'Please register an instance of GeneratedTestScopeHandler first before trying to listen to its stream',
      );
    }

    final handler = matches.first;
    return handler.stream;
  }
}

class GeneratedTest2Scope extends Scope<void> {
  static const String scopeName = 'generated-test-2';

  GeneratedTest2Scope() : super(name: "generated-test-2", args: null);
}

class GeneratedTest2ScopeHandler extends SingleScopeHandler<void> {
  GeneratedTest2ScopeHandler(super.weaver, {super.changeScopeStream});

  final _scopeHandlerDelegate = _GeneratedTestScope2();

  @override
  String get scopeName => 'generated-test-2';

  @override
  Future<void> onEnterScope(Weaver weaver, void args) async {
    weaverInstance.register<String>(
      _scopeHandlerDelegate._namedValue3(),
      name: "named-key-3",
    );

    await _scopeHandlerDelegate.onEnterScope(weaverInstance);
  }

  @override
  Future<void> onLeaveScope(Weaver weaver) async {
    // no methods are annotated with @OnLeaveScope in the scope handler delegate for
    // custom disposal and unregistering of the dependencies registered for this scope
    (weaver as ScopeHandlerWeaverProxy)
        .unregisterDependenciesRegisteredByThisProxy();
    weaverInstance.unregister<String>(name: "named-key-3");
  }
}

extension GeneratedTest2ScopeOnWeaverAddedToWeaver on Weaver {
  GeneratedTest2ScopeOnWeaver get generatedTest2Scope =>
      GeneratedTest2ScopeOnWeaver(ScopeHandlerWeaverProxy(this));
}

class GeneratedTest2ScopeOnWeaver {
  final ScopeHandlerWeaverProxy weaverInstance;

  final _scopeHandlerDelegate = _GeneratedTestScope2();

  GeneratedTest2ScopeOnWeaver(this.weaverInstance);

  bool get isIn => weaverInstance.scopes
      .where((scope) => scope.name == "generated-test-2")
      .isNotEmpty;

  String get namedKey3 => weaverInstance.get<String>(name: "named-key-3");

  Stream<Scope<void>?> get stream {
    final matches = weaverInstance.handlers
        .whereType<GeneratedTest2ScopeHandler>();
    if (matches.isEmpty) {
      throw WeaverException(
        'Tried to listen on stream of GeneratedTest2Scope without a handler class registered. '
        'Please register an instance of GeneratedTest2ScopeHandler first before trying to listen to its stream',
      );
    }

    final handler = matches.first;
    return handler.stream;
  }
}
