import 'package:flutter/foundation.dart';
import 'package:weaver/di/base/weaver.dart';

abstract class WeaverScope {
  String get name;

  ValueNotifier<bool> get isInScope;

  Future<void> register(final Weaver weaver);

  Future<void> unregister(final Weaver weaver);

  void dispose() {}
}
