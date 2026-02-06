import 'package:example/src/app/api/user_api.dart';
import 'package:example/src/app/cubits/user_cubit.dart';
import 'package:flutter_weaver/flutter_weaver.dart';

part 'scopes.weaver.dart';

@WeaverSwitchScope(name: 'auth')
class _AuthScope {
  @OnEnterScope(name: 'logged-in')
  Future<void> _loggedIn(Weaver weaver) async {
    weaver.register(UserCubit(weaver.get()));
    weaver.register(UserApi(weaver.get()));
  }

  @OnEnterScope(name: 'logged-out')
  Future<void> _loggedOut(Weaver weaver) async {
    // nothing to register here
  }
}
