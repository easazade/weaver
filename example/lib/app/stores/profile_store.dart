import 'package:example/app/api/profile_api.dart';
import 'package:example/app/models/profile.dart';
import 'package:example/crystalline_generated.dart';
import 'package:flutter_crystalline/flutter_crystalline.dart';

part 'profile_store.crystalline.dart';

@StoreClass()
abstract class _ProfileStore extends Store {
  _ProfileStore(this.api);
  final ProfileApi api;

  final profile = Data<Profile>();

  late final userObserver = Observer(() async {
    final user = SharedState.instance.user;
    if (user.hasValue && profile.hasNoValue) {
      profile.failure = null;
      profile.operation = Operation.read;
      publish();

      profile.value = await api.getProfileByUserId(user.value.id);
      profile.operation = Operation.none;
      publish();
    } else if (user.hasNoValue && profile.hasValue) {
      profile.value = null;
      publish();
    }
  });

  @override
  Future<void> init() async {
    SharedState.instance.user.observers.add(userObserver);
  }

  @override
  void clear() {
    SharedState.instance.user.observers.remove(userObserver);
    super.clear();
  }
}
