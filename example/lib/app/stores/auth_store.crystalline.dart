// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unnecessary_string_interpolations, unused_field, duplicate_import, unused_import

part of 'auth_store.dart';

final $$userSharedProperty = Data<User>();

class AuthStore extends _AuthStore {
  // constructor
  AuthStore(super.api);

  @override
  final user = $$userSharedProperty;

  @override
  List<Data<Object?>> get states => [user];

  @override
  String? get name => 'AuthStore';

  @override
  bool operator ==(Object other) {
    if (other is! AuthStore) return false;

    return other.runtimeType == runtimeType &&
        failureOrNull == other.failureOrNull &&
        operation == other.operation &&
        const ListEquality().equals(
          sideEffects.all.toList(),
          other.sideEffects.all.toList(),
        ) &&
        const ListEquality().equals(states, other.states);
  }

  @override
  int get hashCode =>
      (failureOrNull?.hashCode ?? 9) +
      sideEffects.all.hashCode +
      states.hashCode +
      operation.hashCode +
      runtimeType.hashCode;

  @override
  Stream<AuthStore> get stream => streamController.stream.map((e) => this);
}
