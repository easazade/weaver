import 'dart:async';

import 'package:example/src/app/app.dart';
import 'package:example/src/app/di/scopes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_weaver/flutter_weaver.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    unawaited(_init());
  }

  Future<void> _init() async {
    await weaver.authScope.awaitEnterScope();
    if (mounted) {
      if (weaver.authScope.isLoggedIn) {
        Navigator.of(context).pushNamed(Routes.home);
      } else {
        Navigator.of(context).pushNamed(Routes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).primaryColor,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
