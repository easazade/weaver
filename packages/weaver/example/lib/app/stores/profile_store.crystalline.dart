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

  @override
  Stream<ProfileStore> streamWith({bool skipUntilInitialized = false}) {
    if (!skipUntilInitialized) {
      return streamController.stream.map((e) => this);
    }
    return _streamWithSkipUntilInitialized();
  }

  Stream<ProfileStore> _streamWithSkipUntilInitialized() {
    var hadSkippedEmission = false;
    final sc = StreamController<ProfileStore>(sync: true);
    StreamSubscription<bool>? streamSub;

    sc.onListen = () {
      streamSub = streamController.stream.listen((_) {
        if (isInitialized) {
          if (!sc.isClosed) sc.add(this);
        } else {
          hadSkippedEmission = true;
        }
      });

      ensureInitialized().then((_) {
        if (hadSkippedEmission && !sc.isClosed) {
          sc.add(this);
        }
      });
    };

    sc.onCancel = () => streamSub?.cancel();

    return sc.stream;
  }
}
