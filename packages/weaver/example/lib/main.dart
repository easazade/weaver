import 'package:example/app/app.dart';
import 'package:example/app/di/setup_di.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  await bootstrapDependencies();
  runApp(App());
}
