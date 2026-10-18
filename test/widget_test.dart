// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nyxproject/features/cart/presentation/bloc/cart_service.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:nyxproject/main.dart';

void main() {
  testWidgets('app displays the splash screen on startup', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final sessionService = SessionService();
    await sessionService.init();

    await tester.pumpWidget(
      MyApp(sessionService: sessionService, cartService: CartService()),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
