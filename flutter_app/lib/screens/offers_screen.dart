import '../widgets/photo_scaffold.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/currency.dart';

class OffersScreen extends StatelessWidget {
  final double requestedAmount;
  final double annualRate;
  const OffersScreen({super.key, this.requestedAmount = 25000, this.annualRate = 6.5});

  @override
  Widget build(BuildContext context) {
    final rate = annualRate / 1200;
    return PhotoScaffold(
      appBar: AppBar(title: const Text('Payment examples')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('Illustrative calculations only. These are not lender offers and no money will be transferred.'),
        const SizedBox(height: 16),
        for (final months in [24, 36, 48])
          Builder(builder: (context) {
            final emi = rate == 0 ? requestedAmount / months
                : requestedAmount * rate / (1 - math.pow(1 + rate, -months));
            return Card(child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('$months months', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Loan: ${inr(requestedAmount)} at $annualRate% annually'),
                Text('Monthly EMI: ${inr(emi)}'),
                Text('Total interest: ${inr(emi * months - requestedAmount)}'),
                const Text('Excludes fees.'),
              ]),
            ));
          }),
      ]),
    );
  }
}
