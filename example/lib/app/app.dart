import 'package:example/app/di/app_scopes.dart';
import 'package:example/app/pages/home_page.dart';
import 'package:example/app/pages/login_page.dart';
import 'package:example/app/pages/profile_page.dart';
import 'package:example/app/pages/splash_page.dart';
import 'package:example/app/stores/auth_store.dart';
import 'package:example/app/utils/stream_listenable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_weaver/flutter_weaver.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.custom(
      appBuilder: (context) => MaterialApp.router(
        theme: ThemeData.light(useMaterial3: true),
        debugShowCheckedModeBanner: false,
        builder: (context, child) => ShadAppBuilder(child: child),
        routerConfig: router,
      ),
    );
  }
}

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
  refreshListenable: GoRouterRefreshStream(weaver.authScope.stream),
  redirect: (context, state) {
    final route = state.uri.toString();

    if (publicRoutes.contains(route)) {
      return route;
    } else {
      if (weaver.authScope.isUserLoggedIn) {
        return route;
      } else {
        return Routes.login;
      }
    }
  },
  routes: [
    GoRoute(path: Routes.splash, builder: (context, state) => SplashPage()),
    GoRoute(path: Routes.home, builder: (context, state) => HomePage()),
    GoRoute(path: Routes.login, builder: (context, state) => LoginPage()),
    GoRoute(path: Routes.profile, builder: (context, state) => ProfilePage()),
  ],
);
