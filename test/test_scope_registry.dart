import 'package:flutter/src/foundation/change_notifier.dart';
import 'package:weaver/src/base/weaver.dart';
import 'package:weaver/src/base/weaver_scope.dart';

class TestScopeRegistry extends WeaverScope {
  TestScopeRegistry({
    this.stringObject,
    this.intObject,
    this.doubleObject,
    this.boolObject,
    this.name = 'test',
    this.initialIsInScopeValue = true,
  });

  final String? stringObject;
  final int? intObject;
  final double? doubleObject;
  final bool? boolObject;
  final bool initialIsInScopeValue;

  @override
  late ValueNotifier<bool> isInScope = ValueNotifier(initialIsInScopeValue);

  @override
  Future<void> register(final Weaver weaver) async {
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
  final String name;

  @override
  Future<void> unregister(final Weaver weaver) async {
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
