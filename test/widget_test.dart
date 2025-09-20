// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manganku_app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ManganKuApp());

    // Verify that our app starts with the home page.
    expect(find.text('ManganKu'), findsOneWidget);
    expect(find.text('Choose how to add your image'), findsOneWidget);
    // Tap the camera button and trigger a frame (test UI elements).
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    expect(find.byIcon(Icons.photo_library), findsOneWidget);
  });
}
