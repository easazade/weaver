// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unnecessary_string_interpolations, unused_field, prefer_final_parameters

part of 'test_scopes.dart';

class Test1Scope extends Scope<Test1ScopeArgs> {
  static const String scopeName = 'test-scope-1';

  Test1Scope({required List objects})
    : super(name: "test-scope-1", args: Test1ScopeArgs(objects));
}

class Test1ScopeArgs {
  final List objects;

  Test1ScopeArgs(this.objects);
}

class Test1ScopeHandler extends SingleScopeHandler<Test1ScopeArgs> {
  Test1ScopeHandler(super.weaver, {super.changeScopeStream});

  final _scopeHandlerDelegate = _TestScope1();

  @override
  String get scopeName => 'test-scope-1';

  @override
  Future<void> onEnterScope(Weaver weaver, Test1ScopeArgs args) async {
    await _scopeHandlerDelegate.onEnterScope(weaverInstance, args.objects);
  }

  @override
  Future<void> onLeaveScope(Weaver weaver) async {
    await _scopeHandlerDelegate.onLeaveScope(weaverInstance);
  }
}

extension Test1ScopeOnWeaverAddedToWeaver on Weaver {
  Test1ScopeOnWeaver get test1Scope =>
      Test1ScopeOnWeaver(ScopeHandlerWeaverProxy(this));
}

class Test1ScopeOnWeaver {
  final ScopeHandlerWeaverProxy weaverInstance;

  final _scopeHandlerDelegate = _TestScope1();

  Test1ScopeOnWeaver(this.weaverInstance);

  bool get isIn => weaverInstance.scopes
      .where((scope) => scope.name == "test-scope-1")
      .isNotEmpty;

  Stream<Scope<Test1ScopeArgs>?> get stream {
    final matches = weaverInstance.handlers.whereType<Test1ScopeHandler>();
    if (matches.isEmpty) {
      throw WeaverException(
        'Tried to listen on stream of Test1Scope without a handler class registered. '
        'Please register an instance of Test1ScopeHandler first before trying to listen to its stream',
      );
    }

    final handler = matches.first;
    return handler.stream;
  }
}

class Test2Scope extends Scope<Test2ScopeArgs> {
  static const String scopeName = 'test-scope-2';

  Test2Scope({required List objects})
    : super(name: "test-scope-2", args: Test2ScopeArgs(objects));
}

class Test2ScopeArgs {
  final List objects;

  Test2ScopeArgs(this.objects);
}

class Test2ScopeHandler extends SingleScopeHandler<Test2ScopeArgs> {
  Test2ScopeHandler(super.weaver, {super.changeScopeStream});

  final _scopeHandlerDelegate = _TestScope2();

  @override
  String get scopeName => 'test-scope-2';

  @override
  Future<void> onEnterScope(Weaver weaver, Test2ScopeArgs args) async {
    await _scopeHandlerDelegate.onEnterScope(weaverInstance, args.objects);
  }

  @override
  Future<void> onLeaveScope(Weaver weaver) async {
    await _scopeHandlerDelegate.onLeaveScope(weaverInstance);
  }
}

extension Test2ScopeOnWeaverAddedToWeaver on Weaver {
  Test2ScopeOnWeaver get test2Scope =>
      Test2ScopeOnWeaver(ScopeHandlerWeaverProxy(this));
}

class Test2ScopeOnWeaver {
  final ScopeHandlerWeaverProxy weaverInstance;

  final _scopeHandlerDelegate = _TestScope2();

  Test2ScopeOnWeaver(this.weaverInstance);

  bool get isIn => weaverInstance.scopes
      .where((scope) => scope.name == "test-scope-2")
      .isNotEmpty;

  Stream<Scope<Test2ScopeArgs>?> get stream {
    final matches = weaverInstance.handlers.whereType<Test2ScopeHandler>();
    if (matches.isEmpty) {
      throw WeaverException(
        'Tried to listen on stream of Test2Scope without a handler class registered. '
        'Please register an instance of Test2ScopeHandler first before trying to listen to its stream',
      );
    }

    final handler = matches.first;
    return handler.stream;
  }
}
