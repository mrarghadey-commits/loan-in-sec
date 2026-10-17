import '../widgets/photo_scaffold.dart';
import 'package:flutter/material.dart';
import '../models/loan_data.dart';
import '../utils/currency.dart';
import 'offers_screen.dart';
import 'demo_lenders_screen.dart';

class AffordabilityScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  final LoanData loanData;
  const AffordabilityScreen({super.key, required this.result, required this.loanData});

  @override
  Widget build(BuildContext context) {
    final assessment = Map<String, dynamic>.from(result['affordability'] as Map);
    final withinLimit = assessment['within_demo_limit'] == true;
    final color = withinLimit ? const Color(0xFF059669) : const Color(0xFFDC2626);
    Widget line(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: LayoutBuilder(builder: (context, size) {
        final caption = Text(label, style: const TextStyle(color: Color(0xFF607582)));
        final amount = Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16));
        if (size.maxWidth < 430) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [caption, const SizedBox(height: 4), amount]);
        }
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: caption), const SizedBox(width: 24), Flexible(child: amount),
        ]);
      }),
    );
    return PhotoScaffold(
      appBar: AppBar(title: const Text('Loan in Sec | Affordability')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const SizedBox(height: 12),
              const Text('YOUR FINANCIAL OVERVIEW', style: TextStyle(color: Color(0xFF087F75),
                letterSpacing: 1.8, fontSize: 11, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Your numbers. A clearer next step.', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Review your payment plan before exploring fictional lenders.', style: TextStyle(color: Color(0xFF607582))),
              const SizedBox(height: 24),
              Card(child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(withinLimit ? Icons.check_circle_outline : Icons.info_outline, color: color, size: 40),
                  const SizedBox(height: 12),
                  Text(withinLimit ? 'Within demo affordability limit' : 'Above demo affordability limit',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 12),
                  Text('Existing debt plus the new EMI is ${assessment['total_dti_percent']}% of monthly income. '
                    'The configured demo limit is ${assessment['limit_percent']}%.'),
                  const SizedBox(height: 18),
                  ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(
                    value: ((assessment['total_dti_percent'] as num) / 100).clamp(0.0, 1.0).toDouble(),
                    minHeight: 8, color: color, backgroundColor: const Color(0xFFE8EFF1),
                    semanticsLabel: 'Total monthly debt as a share of income',
                  )),
                  const SizedBox(height: 8),
                  Text(assessment['policy_note'] as String),
                ]),
              )),
              Card(child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Monthly payment breakdown', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  line('Annual income', inr(loanData.annualIncome)),
                  line('Monthly income', inr(assessment['monthly_income'] as num)),
                  line('Existing monthly debt (estimated from DTI)', inr(assessment['existing_monthly_debt'] as num)),
                  line('New loan EMI', inr(assessment['monthly_emi'] as num)),
                  line('Total monthly debt payments', inr(assessment['total_monthly_debt'] as num)),
                  line('Income remaining before living expenses', inr(assessment['remaining_monthly_income'] as num)),
                  const Divider(),
                  line('Requested loan', inr(loanData.loanAmount)),
                  line('Duration', '${assessment['loan_term_months']} months'),
                  line('Annual interest rate', '${loanData.interestRate}%'),
                  line('Total repayment', inr(assessment['total_repayment'] as num)),
                  line('Total interest (excluding fees)', inr(assessment['total_interest'] as num)),
                  line('Estimated maximum loan under demo rule', inr(assessment['estimated_max_principal'] as num)),
                ]),
              )),
              Card(child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Synthetic INR demo model', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  if (result['model_available'] == true && result['probability'] is num) ...[
                    const SizedBox(height: 12),
                    Text('Demo score: ${((result['probability'] as num) * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('Predicted simulated label: ${result['demo_prediction']}'),
                    const SizedBox(height: 12),
                    ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(
                      value: (result['probability'] as num).toDouble().clamp(0.0, 1.0),
                      minHeight: 8, backgroundColor: const Color(0xFFE8EFF1),
                      semanticsLabel: 'Synthetic model score',
                    )),
                  ],
                  const SizedBox(height: 8),
                  Text(result['model_note'] as String),
                  const SizedBox(height: 8),
                  const Text('The affordability result is a calculation, not an AI probability or a loan approval.'),
                ]),
              )),
              const SizedBox(height: 16),
              if (withinLimit && result['assessment_id'] is int)
                FilledButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => DemoLendersScreen(assessmentId: result['assessment_id'] as int),
                  )),
                  icon: const Icon(Icons.account_balance),
                  label: const Text('Choose a demo lender'),
                ),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.edit),
                label: const Text('Change details and recalculate'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => OffersScreen(requestedAmount: loanData.loanAmount, annualRate: loanData.interestRate),
                )),
                child: const Text('Compare repayment durations'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
