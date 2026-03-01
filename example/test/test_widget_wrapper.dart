import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class TestWidgetWrapper extends StatelessWidget {
  const TestWidgetWrapper(this.widget, {super.key});

  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return ShadApp.custom(
      appBuilder: (context) => MaterialApp(
        theme: ThemeData.light(useMaterial3: true),
        debugShowCheckedModeBanner: false,
        builder: (context, child) => ShadAppBuilder(child: child),
        home: widget,
      ),
    );
  }
}
