import 'package:flutter/material.dart';

import 'cubits/user_cubit.dart';
import 'di.dart';
import 'pages/admin_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/profile_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final userCubit = weaver.get<UserCubit>();

    return MaterialApp(
      title: 'Shoes Store',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: userCubit.isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/admin': (context) => const AdminPage(),
      },
    );
  }
}
