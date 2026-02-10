import 'package:example/app/pages/home_page.dart';
import 'package:example/app/pages/login_page.dart';
import 'package:example/app/pages/profile_page.dart';
import 'package:example/app/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.custom(
      appBuilder: (context) => MaterialApp(
        theme: ThemeData.light(useMaterial3: true),
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.splash,
        routes: {
          Routes.splash: (context) => SplashPage(),
          Routes.home: (context) => HomePage(),
          Routes.login: (context) => LoginPage(),
          Routes.profile: (context) => ProfilePage(),
        },
        builder: (context, child) => ShadAppBuilder(child: child),
      ),
    );
  }
}

class Routes {
  static const splash = '/splash';
  static const home = '/home';
  static const profile = '/profile';
  static const login = '/login';
}
