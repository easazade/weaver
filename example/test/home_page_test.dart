import 'package:example/app/api/shoe_api.dart';
import 'package:example/app/pages/home_page.dart';
import 'package:example/app/stores/home_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weaver/flutter_weaver.dart';

import 'test_widget_wrapper.dart';

Future<void> main() async {
  setUp(() {
    weaver.register(ShoeApi());
    weaver.register(HomeStore(weaver.get()));
  });

  tearDown(() {
    weaver.reset();
  });

  testWidgets(
    'Should load page without any errors',
    (tester) async {
      await tester.pumpWidget(TestWidgetWrapper(HomePage()));
      await tester.pumpAndSettle();

      expect(find.byType(ShoeCard), findsAtLeast(1));
    },
  );

  testWidgets(
    'Should show profile button',
    (tester) async {
      await tester.pumpWidget(TestWidgetWrapper(HomePage()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person), findsOneWidget);
    },
  );
}
