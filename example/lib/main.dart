import 'package:flutter/material.dart';

import 'src/app/app.dart';
import 'src/app/di.dart';

void main() {
  // Setup all app dependencies using Weaver
  setupAppDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const App();
  }
}
