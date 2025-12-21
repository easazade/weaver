import 'package:weaver/src/base/scope.dart';
import 'package:weaver/src/base/weaver.dart';

class TestScope extends Scope<String> {
  TestScope({required super.args}) : super(name: 'test');
}

class TestScopeHandler extends ScopeHandler<String> {
  TestScopeHandler({
    this.stringObject,
    this.intObject,
    this.doubleObject,
    this.boolObject,
    this.scopeName = 'test',
  });

  final String? stringObject;
  final int? intObject;
  final double? doubleObject;
  final bool? boolObject;

  @override
  final String scopeName;

  @override
  Future<void> onEnterScope(final Weaver weaver, final argument) async {
    if (stringObject != null) {
      weaver.register(stringObject!);
    }
    if (intObject != null) {
      weaver.register(intObject!);
    }
    if (doubleObject != null) {
      weaver.register(doubleObject!);
    }
    if (boolObject != null) {
      weaver.register(boolObject!);
    }
  }

  @override
  Future<void> onLeaveScope(final Weaver weaver) async {
    if (stringObject != null) {
      weaver.unregister<String>();
    }
    if (intObject != null) {
      weaver.unregister<int>();
    }
    if (doubleObject != null) {
      weaver.unregister<double>();
    }
    if (boolObject != null) {
      weaver.unregister<bool>();
    }
  }
}
