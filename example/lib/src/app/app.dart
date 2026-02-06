import 'package:example/src/app/pages/splash_page.dart';
import 'package:flutter/material.dart';

import 'pages/admin_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/profile_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shoes Store',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.splash,
      routes: {
        Routes.login: (context) => const LoginPage(),
        Routes.home: (context) => const HomePage(),
        Routes.profile: (context) => const ProfilePage(),
        Routes.admin: (context) => const AdminPage(),
        Routes.splash: (context) => const SplashPage(),
      },
    );
  }
}

class Routes {
  static final login = '/login';
  static final home = '/home';
  static final profile = '/profile';
  static final admin = '/admin';
  static final splash = '/splash';
}
