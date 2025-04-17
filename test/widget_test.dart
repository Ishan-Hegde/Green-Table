// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:green_table/main.dart';
import 'package:green_table/pages/login_page.dart';
import 'package:green_table/pages/consumer_dash.dart';
import 'package:green_table/pages/restaurant_dash.dart';

void main() {
  group('Login Page Widget Tests', () {
    testWidgets('Login page shows all required UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Verify the title is present
      expect(find.text('Log In or Sign Up'), findsOneWidget);

      // Verify input fields are present
      expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);

      // Verify toggle buttons are present
      expect(find.text('Consumer'), findsOneWidget);
      expect(find.text('Restaurant'), findsOneWidget);

      // Verify continue button is present
      expect(find.widgetWithText(ElevatedButton, 'Continue'), findsOneWidget);
    });

    testWidgets('Toggle buttons switch between Consumer and Restaurant', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Initially Consumer should be selected
      final toggleButtons = find.byType(ToggleButtons);
      expect(toggleButtons, findsOneWidget);

      // Tap Restaurant toggle
      await tester.tap(find.text('Restaurant'));
      await tester.pump();

      // Verify Restaurant is now selected
      final toggleButtonsWidget = tester.widget<ToggleButtons>(toggleButtons);
      expect(toggleButtonsWidget.isSelected, equals([false, true]));
    });

    testWidgets('Shows error dialog when fields are empty', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Tap continue button without filling fields
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pumpAndSettle();

      // Verify error dialog appears
      expect(find.text('Login Failed'), findsOneWidget);
      expect(find.text('Please fill out all fields.'), findsOneWidget);
    });

    testWidgets('Can enter text in email and password fields', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Enter text in email field
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'test@example.com');
      expect(find.text('test@example.com'), findsOneWidget);

      // Enter text in password field
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');
      expect(find.text('password123'), findsOneWidget);
    });
  });
}
