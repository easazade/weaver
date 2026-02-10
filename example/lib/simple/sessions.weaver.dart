// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unnecessary_string_interpolations, unused_field, prefer_final_parameters

part of 'sessions.dart';

class CartOnWeaver {
  final Weaver weaverInstance;
  CartOnWeaver(this.weaverInstance);

  /// Registers given [instance] of object under given [name] under session: "cart"
  void register<T extends Object>(final T instance, {final String? name}) {
    weaverInstance.register<T>(instance, name: name, session: 'cart');
  }

  /// Removes all dependency objects registered under given [session] name.
  void clear() {
    weaverInstance.clearSession('cart');
  }
}

extension SessionCartOnWeaverX on Weaver {
  CartOnWeaver get cartSession => CartOnWeaver(this);
}

class EditOnWeaver {
  final Weaver weaverInstance;
  EditOnWeaver(this.weaverInstance);

  /// Registers given [instance] of object under given [name] under session: "edit"
  void register<T extends Object>(final T instance, {final String? name}) {
    weaverInstance.register<T>(instance, name: name, session: 'edit');
  }

  /// Removes all dependency objects registered under given [session] name.
  void clear() {
    weaverInstance.clearSession('edit');
  }
}

extension SessionEditOnWeaverX on Weaver {
  EditOnWeaver get editSession => EditOnWeaver(this);
}
