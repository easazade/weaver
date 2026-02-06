import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    //TODO: weaver.authScope.getOrWaitForScope();
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
