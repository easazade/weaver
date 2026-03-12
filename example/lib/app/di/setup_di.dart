import 'package:example/app/api/cart_api.dart';
import 'package:example/app/api/order_api.dart';
import 'package:example/app/api/profile_api.dart';
import 'package:example/app/api/shoe_api.dart';
import 'package:example/app/api/user_api.dart';
import 'package:example/app/di/app_scopes.dart';
import 'package:example/app/stores/auth_store.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_weaver/flutter_weaver.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> bootstrapDependencies() async {
  WidgetsFlutterBinding.ensureInitialized();
  weaver.register(await SharedPreferences.getInstance());
  weaver.register(UserApi(preferences: weaver.get()));
  weaver.register(ShoeApi());
  weaver.register(CartApi());
  weaver.register(OrderApi());
  weaver.register(ProfileApi());

  final authStore = AuthStore(weaver.get());
  weaver.register(authStore);

  weaver.addScopeHandler(
    AuthScopeHandler(
      weaver,
      changeScopeStream: authStore.streamWith(skipUntilInitialized: true).map((store) {
        print('SSSSSS emitted');
        if (store.isLoggedIn) {
          return AuthScope.userLoggedIn();
        } else {
          return AuthScope.loggedOut();
        }
      }),
    ),
  );

  authStore.initialize();
}
