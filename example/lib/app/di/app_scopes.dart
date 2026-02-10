import 'package:example/app/stores/home_store.dart';
import 'package:example/app/stores/profile_store.dart';
import 'package:flutter_weaver/flutter_weaver.dart';

part 'app_scopes.weaver.dart';

@WeaverSwitchScope(name: 'auth')
class _AuthScope {
  @OnEnterScope(name: 'user-logged-in')
  Future<void> onEnter(Weaver weaver) async {
    weaver.register(HomeStore(weaver.get()));
    weaver.register(ProfileStore(weaver.get()));
  }

  @OnEnterScope(name: 'logged-out')
  Future<void> onLogout(Weaver weaver) async {}
}
