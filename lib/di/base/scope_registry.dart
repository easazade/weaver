import 'package:flutter/foundation.dart';
import 'package:weaver/di/base/weaver.dart';

abstract class ScopeRegistry {
  String get name;

  ValueNotifier<bool> get isInScope;

  Future<void> register(final Weaver di);

  Future<void> unregister(final Weaver di);

  void dispose() {}
}
