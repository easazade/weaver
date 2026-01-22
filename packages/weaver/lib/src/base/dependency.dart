import 'dart:async';

/// Represents a registered dependency within the [Weaver] container.
///
/// A [Dependency] can either hold a direct value, a lazy instantiation callback,
/// or act as a placeholder for a dependency that will be registered in the future.
/// It uses a [Completer] to allow asynchronous waiting for the dependency to become available.
class Dependency<T> {
  /// Creates a lazy [Dependency] that will be instantiated when first accessed.
  factory Dependency.lazy(final T Function() callback) => Dependency._(null, callback);

  /// Creates a [Dependency] with a pre-existing value.
  factory Dependency.value(final T value) => Dependency._(value, null);

  /// Creates a placeholder [Dependency] that can be awaited before the actual
  /// value is registered.
  factory Dependency.placeHolder() => Dependency._(null, null);

  Dependency._(this._value, this._lazyInstantiateCallback);

  /// A [Completer] that completes when the dependency value is set.
  final completer = Completer<T>();
  T? _value;
  T Function()? _lazyInstantiateCallback;

  /// Sets the value of the dependency and completes the [completer] if the value is not null.
  set value(final T? instance) {
    _value = instance;

    if (instance != null) {
      completer.complete(instance);
    }
  }

  /// The current value of the dependency, if available.
  T? get value => _value;

  /// The callback used for lazy instantiation of the dependency.
  // ignore: unnecessary_getters_setters
  T Function()? get lazyInstantiateCallback => _lazyInstantiateCallback;

  set lazyInstantiateCallback(final T Function()? callback) {
    _lazyInstantiateCallback = callback;
  }

  /// Returns true if the dependency has a value or a lazy instantiation callback.
  bool get hasValue => _value != null || _lazyInstantiateCallback != null;
}

/// A unique identifier for a dependency, combining its [Type] and an optional name.
///
/// This key is used by [Weaver] to store and retrieve dependencies.
class DependencyKey {
  /// The [Type] of the dependency.
  final Type type;

  /// An optional name to distinguish between multiple dependencies of the same [Type].
  final String? name;

  /// Creates a [DependencyKey] with the given [type] and optional [name].
  DependencyKey({required this.type, this.name});

  @override
  String toString() {
    final buffer = StringBuffer();

    buffer.write('{Type: $type');
    if (name != null) {
      buffer.write(', name: $name');
    }
    buffer.write('}');

    return buffer.toString();
  }

  @override
  bool operator ==(final Object other) {
    if (other is! DependencyKey) {
      return false;
    }

    return name == other.name && type == other.type;
  }

  @override
  int get hashCode => name.hashCode + type.hashCode + 97;
}
