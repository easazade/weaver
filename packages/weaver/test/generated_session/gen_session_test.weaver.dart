// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unnecessary_string_interpolations, unused_field, prefer_final_parameters

part of 'gen_session_test.dart';

class TestOnWeaver {
  final Weaver weaverInstance;
  TestOnWeaver(this.weaverInstance);

  /// Registers given [instance] of object under given [name] under session: "test"
  void register<T extends Object>(final T instance, {final String? name}) {
    weaverInstance.register<T>(instance, name: name, session: 'test');
  }

  /// Removes all dependency objects registered under given [session] name.
  void clear() {
    weaverInstance.clearSession('test');
  }
}

extension SessionTestOnWeaverX on Weaver {
  TestOnWeaver get testSession => TestOnWeaver(this);
}

class ShoppingOnWeaver {
  final Weaver weaverInstance;
  ShoppingOnWeaver(this.weaverInstance);

  /// Registers given [instance] of object under given [name] under session: "shopping"
  void register<T extends Object>(final T instance, {final String? name}) {
    weaverInstance.register<T>(instance, name: name, session: 'shopping');
  }

  /// Removes all dependency objects registered under given [session] name.
  void clear() {
    weaverInstance.clearSession('shopping');
  }
}

extension SessionShoppingOnWeaverX on Weaver {
  ShoppingOnWeaver get shoppingSession => ShoppingOnWeaver(this);
}
