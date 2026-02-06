import 'package:flutter/material.dart';

import '../cubits/login_cubit.dart';
import '../di/di_setup.dart';
import '../widgets/login_text_field.dart';
import '../widgets/primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  late LoginCubit _loginCubit;

  @override
  void initState() {
    super.initState();
    _loginCubit = weaver.get<LoginCubit>();
  }

  Future<void> _handleLogin() async {
    final success = await _loginCubit.login(
      _usernameController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_loginCubit.error ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shopping_bag,
                size: 80,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 32),
              LoginTextField(
                label: 'Username',
                hint: 'Enter your username',
                controller: _usernameController,
              ),
              const SizedBox(height: 16),
              LoginTextField(
                label: 'Password',
                hint: 'Enter your password',
                obscureText: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Login',
                isLoading: _loginCubit.isLoading,
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 16),
              Text(
                'Tip: Use "admin" as username for admin access',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
