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
    print('PROFILE: inside observer');
    final user = SharedState.instance.user;
    if (user.hasValue && profile.hasNoValue) {
      print('PROFILE: setting profile');
      profile.failure = null;
      profile.operation = Operation.read;
      publish();

      profile.value = await api.getProfileByUserId(user.value.id);
      print('PROFILE: set profile to ${profile.valueOrNull}');
      profile.operation = Operation.none;
      publish();
    } else if (user.hasNoValue && profile.hasValue) {
      print('PROFILE: user has no value setting null on profile value');

      profile.value = null;
      publish();
    }
  });

  @override
  Future<void> init() async {
    print('PROFILE: init and added observer');
    SharedState.instance.user.observers.add(userObserver);

    userObserver.callback();
  }

  @override
  void clear() {
    print('PROFILE: clear and removed observer');
    SharedState.instance.user.observers.remove(userObserver);
    super.clear();
  }
}
