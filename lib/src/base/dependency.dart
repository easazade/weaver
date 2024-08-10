import 'dart:async';

class Dependency<T> {
  factory Dependency.lazy(final T Function() callback) =>
      Dependency._(null, callback);

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

  T Function()? get lazyInstantiateCallback => _lazyInstantiateCallback;

  set lazyInstantiateCallback(final T Function()? callback) {
    _lazyInstantiateCallback = callback;
  }

  bool get hasValue => _value != null || _lazyInstantiateCallback != null;
}
