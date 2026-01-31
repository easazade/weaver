import 'package:example/src/scopes.dart';
import 'package:flutter/material.dart';
import 'package:weaver/weaver.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    weaver.named.userId;
    weaver.named.privateKey;

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Material(
        child: Center(
          child: const Text('Flutter Demo Home Page'),
        ),
      ),
    );
  }
}
