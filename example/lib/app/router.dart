import 'package:example/app/di/app_scopes.dart';
import 'package:example/app/pages/home_page.dart';
import 'package:example/app/pages/login_page.dart';
import 'package:example/app/pages/profile_page.dart';
import 'package:example/app/pages/splash_page.dart';
import 'package:example/app/stores/auth_store.dart';
import 'package:example/app/utils/stream_listenable.dart';
import 'package:flutter_weaver/flutter_weaver.dart';
import 'package:go_router/go_router.dart';

const publicRoutes = [
  Routes.splash,
  Routes.login,
];

class Routes {
  static const splash = '/splash';
  static const home = '/home';
  static const profile = '/profile';
  static const login = '/login';
}

final router = GoRouter(
  initialLocation: Routes.splash,
  // currently there is bug on store stream.
  refreshListenable: GoRouterRefreshStream(weaver.authScope.stream),
  redirect: (context, state) async {
    final scope = await weaver.authScope.ensureEnterScope();
    print('current auth scope is ${scope.name}');
    
    var route = state.uri.toString();
    print('route: route is $route');

    if (!publicRoutes.contains(route)) {
      if (!weaver.authScope.isUserLoggedIn) {
        route = Routes.login;
      }
    }

    print('route: redirect to $route');
    return route;
  },

  routes: [
    GoRoute(path: Routes.splash, builder: (context, state) => SplashPage()),
    GoRoute(path: Routes.home, builder: (context, state) => HomePage()),
    GoRoute(path: Routes.login, builder: (context, state) => LoginPage()),
    GoRoute(path: Routes.profile, builder: (context, state) => ProfilePage()),
  ],
);
