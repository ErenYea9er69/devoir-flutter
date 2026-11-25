import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('App loads Login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Text('Login'),
      ),
    ));
    expect(find.text('Login'), findsOneWidget);
  });
}
