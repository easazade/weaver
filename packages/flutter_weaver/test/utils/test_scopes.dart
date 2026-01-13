import 'package:weaver/weaver.dart';

part 'test_scopes.weaver.dart';

/// A test scope that registers objects from a list
@WeaverScope(name: 'test-scope-1')
class _TestScope1 {
  final List<dynamic> _objects = [];

  @OnEnterScope()
  Future<void> onEnterScope(final Weaver weaver, final List<dynamic> objects) async {
    _objects.clear();
    _objects.addAll(objects);
    for (final obj in objects) {
      _registerObject(weaver, obj);
    }
  }

  @OnLeaveScope()
  Future<void> onLeaveScope(final Weaver weaver) async {
    for (final obj in _objects) {
      _unregisterObject(weaver, obj);
    }
    _objects.clear();
  }

  void _registerObject(final Weaver weaver, final dynamic obj) {
    switch (obj.runtimeType) {
      case String:
        weaver.register<String>(obj as String);
        break;
      case int:
        weaver.register<int>(obj as int);
        break;
      case bool:
        weaver.register<bool>(obj as bool);
        break;
      case double:
        weaver.register<double>(obj as double);
        break;
      default:
        // For custom types, use dynamic registration
        if (obj is String) {
          weaver.register<String>(obj);
        } else if (obj is int) {
          weaver.register<int>(obj);
        } else if (obj is bool) {
          weaver.register<bool>(obj);
        } else if (obj is double) {
          weaver.register<double>(obj);
        }
    }
  }

  void _unregisterObject(final Weaver weaver, final dynamic obj) {
    switch (obj.runtimeType) {
      case String:
        weaver.unregister<String>();
        break;
      case int:
        weaver.unregister<int>();
        break;
      case bool:
        weaver.unregister<bool>();
        break;
      case double:
        weaver.unregister<double>();
        break;
      default:
        if (obj is String) {
          weaver.unregister<String>();
        } else if (obj is int) {
          weaver.unregister<int>();
        } else if (obj is bool) {
          weaver.unregister<bool>();
        } else if (obj is double) {
          weaver.unregister<double>();
        }
    }
  }
}

/// A test scope that registers objects from a list (second scope for testing nested scopes)
@WeaverScope(name: 'test-scope-2')
class _TestScope2 {
  final List<dynamic> _objects = [];

  @OnEnterScope()
  Future<void> onEnterScope(final Weaver weaver, final List<dynamic> objects) async {
    _objects.clear();
    _objects.addAll(objects);
    for (final obj in objects) {
      _registerObject(weaver, obj);
    }
  }

  @OnLeaveScope()
  Future<void> onLeaveScope(final Weaver weaver) async {
    for (final obj in _objects) {
      _unregisterObject(weaver, obj);
    }
    _objects.clear();
  }

  void _registerObject(final Weaver weaver, final dynamic obj) {
    switch (obj.runtimeType) {
      case String:
        weaver.register<String>(obj as String);
        break;
      case int:
        weaver.register<int>(obj as int);
        break;
      case bool:
        weaver.register<bool>(obj as bool);
        break;
      case double:
        weaver.register<double>(obj as double);
        break;
      default:
        if (obj is String) {
          weaver.register<String>(obj);
        } else if (obj is int) {
          weaver.register<int>(obj);
        } else if (obj is bool) {
          weaver.register<bool>(obj);
        } else if (obj is double) {
          weaver.register<double>(obj);
        }
    }
  }

  void _unregisterObject(final Weaver weaver, final dynamic obj) {
    switch (obj.runtimeType) {
      case String:
        weaver.unregister<String>();
        break;
      case int:
        weaver.unregister<int>();
        break;
      case bool:
        weaver.unregister<bool>();
        break;
      case double:
        weaver.unregister<double>();
        break;
      default:
        if (obj is String) {
          weaver.unregister<String>();
        } else if (obj is int) {
          weaver.unregister<int>();
        } else if (obj is bool) {
          weaver.unregister<bool>();
        } else if (obj is double) {
          weaver.unregister<double>();
        }
    }
  }
}
