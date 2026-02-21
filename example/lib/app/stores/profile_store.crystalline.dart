// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unnecessary_string_interpolations, unused_field, duplicate_import, unused_import

part of 'profile_store.dart';

class ProfileStore extends _ProfileStore {
  // constructor
  ProfileStore(super.api);

  @override
  List<Data<Object?>> get states => [profile];

  @override
  String? get name => 'ProfileStore';

  @override
  bool operator ==(Object other) {
    if (other is! ProfileStore) return false;

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
  Stream<ProfileStore> get stream => streamController.stream.map((e) => this);
}
