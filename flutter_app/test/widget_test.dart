import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Basic Flutter test',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('LendIQ'),
          ),
        ),
      );

      expect(
        find.text('LendIQ'),
        findsOneWidget,
      );
    },
  );
}