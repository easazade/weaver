import 'dart:async';

class Dependency<T> {
  Dependency(this.value);

  final completer = Completer<T>();
  T? value;

  void setValue(final T instance) {
    value = instance;
    completer.complete(instance);
  }
}
