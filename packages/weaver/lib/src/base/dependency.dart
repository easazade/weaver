import 'dart:async';

class Dependency<T> {
  factory Dependency.lazy(final T Function() callback) => Dependency._(null, callback);

  factory Dependency.value(final T value) => Dependency._(value, null);

  factory Dependency.placeHolder() => Dependency._(null, null);

  Dependency._(this._value, this._lazyInstantiateCallback);

  final completer = Completer<T>();
  T? _value;
  T Function()? _lazyInstantiateCallback;

  set value(final T? instance) {
    _value = instance;

    completer.complete(instance);
  }

  T? get value => _value;

  // ignore: unnecessary_getters_setters
  T Function()? get lazyInstantiateCallback => _lazyInstantiateCallback;

  set lazyInstantiateCallback(final T Function()? callback) {
    _lazyInstantiateCallback = callback;
  }

  bool get hasValue => _value != null || _lazyInstantiateCallback != null;
}

class DependencyKey {
  final Type type;
  final String? name;
  final String? session;

  DependencyKey({required this.type, this.name, this.session});

  @override
  String toString() {
    final buffer = StringBuffer();

    buffer.write('{Type: $type');
    if (name != null) {
      buffer.write(', name: $name');
    }
    if (session != null) {
      buffer.write(', session: $session');
    }
    buffer.write('}');

    return buffer.toString();
  }

  @override
  bool operator ==(final Object other) {
    if (other is! DependencyKey) {
      return false;
    }

    return name == other.name && type == other.type && session == other.session;
  }

  @override
  int get hashCode => name.hashCode + type.hashCode + session.hashCode + 97;
}
