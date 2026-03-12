// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unnecessary_string_interpolations, unused_field, duplicate_import, unused_import

part of 'home_store.dart';

class HomeStore extends _HomeStore {
  // constructor
  HomeStore(super.api);

  @override
  List<Data<Object?>> get states => [shoes];

  @override
  String? get name => 'HomeStore';

  @override
  bool operator ==(Object other) {
    if (other is! HomeStore) return false;

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
  Stream<HomeStore> get stream => streamController.stream.map((e) => this);

  @override
  Stream<HomeStore> streamWith({bool skipUntilInitialized = false}) {
    if (!skipUntilInitialized) {
      return streamController.stream.map((e) => this);
    }
    return _streamWithSkipUntilInitialized();
  }

  Stream<HomeStore> _streamWithSkipUntilInitialized() {
    var hadSkippedEmission = false;
    final sc = StreamController<HomeStore>(sync: true);
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
