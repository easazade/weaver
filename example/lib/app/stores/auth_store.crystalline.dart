// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unnecessary_string_interpolations, unused_field, duplicate_import, unused_import

part of 'auth_store.dart';

final $$userSharedProperty = Data<User>();

class AuthStore extends _AuthStore with _AuthStoreMixin {
  // constructor
  AuthStore(super.api);

  @override
  final user = $$userSharedProperty;
}

mixin _AuthStoreMixin on _AuthStore {
  @override
  List<Data<Object?>> get states => [user];

  @override
  String? get name => 'AuthStore';
}
