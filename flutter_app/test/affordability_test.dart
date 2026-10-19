import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/models/loan_data.dart';
import 'package:flutter_app/utils/currency.dart';
import 'package:flutter_app/widgets/loan_form.dart';

void main() {
  test('INR uses Indian digit grouping', () {
    expect(inr(1234567.5), '\u20b912,34,567.50');
    expect(inr(-1234), '-\u20b91,234.00');
    expect(inr(0), '\u20b90.00');
  });

  testWidgets('form submits current income and duration in INR', (tester) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    LoanData? submitted;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(
      child: LoanForm(onSubmit: (data) => submitted = data, isLoading: false),
    ))));
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '9400');
    await tester.enterText(fields.at(5), '12');
    await tester.tap(find.text('Check Affordability'));
    await tester.pump();
    expect(submitted!.annualIncome, 9400);
    expect(submitted!.loanTermMonths, 12);
    expect(submitted!.toJson()['currency'], 'INR');
    expect(LoanData.fromJson(submitted!.toJson()).loanTermMonths, 12);
    expect(submitted!.copyWith(loanTermMonths: 24).loanTermMonths, 24);
    await tester.enterText(fields.at(0), '94000');
    await tester.tap(find.text('Check Affordability'));
    await tester.pump();
    expect(submitted!.annualIncome, 94000);
    submitted = null;
    await tester.enterText(fields.at(5), '0');
    await tester.tap(find.text('Check Affordability'));
    await tester.pump();
    expect(submitted, isNull);
    expect(find.text('Enter whole months from 1 to 600'), findsOneWidget);
  });
}
