import 'package:example/app/router.dart';
import 'package:flutter/material.dart';
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
