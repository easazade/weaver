import 'package:example/app/app.dart';
import 'package:example/app/di/app_scopes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_weaver/flutter_weaver.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await weaver.authScope.ensureEnterScope();

    if (mounted) {
      if (weaver.authScope.isUserLoggedIn) {
        context.go(Routes.home);
      } else {
        context.go(Routes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.primary,
      child: Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }
}
