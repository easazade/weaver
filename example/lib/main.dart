import 'package:example/src/simple/scopes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_weaver/flutter_weaver.dart';

void main() {
  weaver.register('Weaver is the best DI package');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    weaver.named.userId;
    weaver.named.privateKey;

    return MaterialApp(
      title: 'Weaver Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: RequireDependencies(
        weaver: weaver,
        dependencies: [DependencyKey(type: String)],
        builder: (context, child, isReady) {
          return Material(
            child: isReady
                ? Center(child: Text(inject<String>()))
                : CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
