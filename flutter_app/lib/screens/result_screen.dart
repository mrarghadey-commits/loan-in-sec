import '../widgets/photo_scaffold.dart';
import 'package:flutter/material.dart';
import '../models/loan_data.dart';
import 'offers_screen.dart';
import 'affordability_screen.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> predictionResult;
  final LoanData loanData;

  const ResultScreen({
    super.key,
    required this.predictionResult,
    required this.loanData,
  });

  @override
  Widget build(BuildContext context) {
    if (predictionResult['affordability'] is Map) {
      return AffordabilityScreen(result: predictionResult, loanData: loanData);
    }
    // 1. Determine decision status (prediction_code == 1 or explicit boolean flags)
    final bool isApproved = predictionResult['prediction_code'] == 1 ||
        predictionResult['is_approved'] == true;

    // 2. Extract probability percentage
    final double rawProb = (predictionResult['probability'] as num?)?.toDouble() ??
        (isApproved ? 0.85 : 0.25);
    final String probPct = (rawProb * 100).toStringAsFixed(1);

    // 3. Extract dynamic metric badges
    final int creditIntegrity = predictionResult['credit_integrity'] ??
        ((loanData.creditScore - 300) / 5.5).clamp(10, 99).round();
    final int industryRisk = predictionResult['industry_risk'] ?? 75;

    // 4. Extract or dynamically fallback explainable AI insights
    final List dynamicInsights = (predictionResult['insights'] as List?) ?? [];
    final List<Map<String, dynamic>> displayInsights = dynamicInsights.isNotEmpty
        ? dynamicInsights.map((e) => Map<String, dynamic>.from(e)).toList()
        : _generateFallbackInsights(loanData);

    return PhotoScaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Loan in Sec | Repayment Prediction',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Verdict Banner
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isApproved ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isApproved ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isApproved ? Icons.verified_rounded : Icons.highlight_off_rounded,
                          size: 42,
                          color: isApproved ? const Color(0xFF059669) : const Color(0xFFDC2626),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isApproved ? 'Model Prediction: Likely to Repay' : 'Model Prediction: Unlikely to Repay',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isApproved ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isApproved
                            ? 'The model predicts repayment, not loan approval. Affordability and lender eligibility have not been verified.'
                            : 'The model predicts non-repayment, not a lender decision. Affordability and lender eligibility have not been verified.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Top Metrics Row
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        'Model Repayment Score',
                        '$probPct%',
                        isApproved ? const Color(0xFF059669) : const Color(0xFFDC2626),
                        isApproved ? '• Repayment Predicted' : '• Non-repayment Predicted',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        'Credit Integrity',
                        '$creditIntegrity/100',
                        creditIntegrity >= 70 ? const Color(0xFF059669) : Colors.orange,
                        creditIntegrity >= 70 ? '• Clean Profile' : '• Caution Marks',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        'Industry Risk',
                        '$industryRisk/100',
                        industryRisk >= 70 ? const Color(0xFF059669) : Colors.orange,
                        '• Stability Assessment',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Explainable AI Insights Section
                const Text(
                  'Application Indicators',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Rule-based checks of your inputs. Green indicators do not establish affordability; points are not model contributions.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),

                // List of Attribution Drivers
                ...displayInsights.map((item) {
                  final bool isPos = item['positive'] ?? (item['is_positive'] ?? true);
                  final String name = item['name'] ?? item['title'] ?? 'Risk Factor';
                  final String value = item['value'] ?? '';
                  final String subtitle = item['subtitle'] ?? '';
                  final String pts = item['pts'] ?? item['points'] ?? '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPos ? Icons.trending_up : Icons.trending_down,
                          color: isPos ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                value.isNotEmpty ? '$name: $value' : name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              if (subtitle.isNotEmpty)
                                Text(
                                  subtitle,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                            ],
                          ),
                        ),
                        if (pts.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isPos ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              pts,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isPos ? const Color(0xFF059669) : const Color(0xFFDC2626),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // Action Button
                if (isApproved)
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF087F75),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OffersScreen(
                              requestedAmount: loanData.loanAmount,
                            ),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'View Personalized Offers (3)',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                        ],
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Back to Application Form',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // AI Insights index
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF087F75),
        unselectedItemColor: const Color(0xFF94A3B8),
        onTap: (index) {
          if (index == 1) {
            Navigator.pop(context); // Go back to Loan Form
          } else if (index == 3 && isApproved) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OffersScreen(
                  requestedAmount: loanData.loanAmount,
                ),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Pre-Check'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Application'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'AI Insights'),
          BottomNavigationBarItem(icon: Icon(Icons.local_offer_outlined), label: 'Offers'),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  static List<Map<String, dynamic>> _generateFallbackInsights(LoanData data) {
    final List<Map<String, dynamic>> list = [];

    // DTI Driver
    if (data.debtToIncomeRatio <= 25) {
      list.add({
        'name': 'Debt-to-Income (DTI)',
        'value': '${data.debtToIncomeRatio.toStringAsFixed(1)}%',
        'subtitle': 'Top low-risk bracket nationwide',
        'pts': '+38 pts',
        'positive': true,
      });
    } else if (data.debtToIncomeRatio <= 40) {
      list.add({
        'name': 'Debt-to-Income (DTI)',
        'value': '${data.debtToIncomeRatio.toStringAsFixed(1)}%',
        'subtitle': 'Moderate risk balance',
        'pts': '+12 pts',
        'positive': true,
      });
    } else {
      list.add({
        'name': 'High Debt Burden (DTI)',
        'value': '${data.debtToIncomeRatio.toStringAsFixed(1)}%',
        'subtitle': 'Exceeds standard 40% threshold',
        'pts': '-42 pts',
        'positive': false,
      });
    }

    // Credit Score Driver
    if (data.creditScore >= 700) {
      list.add({
        'name': 'Credit Score',
        'value': '${data.creditScore} FICO',
        'subtitle': 'Clean repayment track record',
        'pts': '+30 pts',
        'positive': true,
      });
    } else if (data.creditScore >= 620) {
      list.add({
        'name': 'Credit Score',
        'value': '${data.creditScore} FICO',
        'subtitle': 'Standard repayment profile',
        'pts': '+10 pts',
        'positive': true,
      });
    } else {
      list.add({
        'name': 'Credit Delinquency Risk',
        'value': '${data.creditScore} FICO',
        'subtitle': 'Elevated subprime risk tier',
        'pts': '-35 pts',
        'positive': false,
      });
    }

    // Leverage Driver
    final double leverage = data.loanAmount / (data.annualIncome > 0 ? data.annualIncome : 1);
    if (leverage <= 0.35) {
      list.add({
        'name': 'Income Coverage',
        'value': '${(1 / (leverage > 0 ? leverage : 1)).toStringAsFixed(1)}x',
        'subtitle': 'Income comfortably absorbs requested principal',
        'pts': '+20 pts',
        'positive': true,
      });
    } else {
      list.add({
        'name': 'Capital Exposure',
        'value': '${leverage.toStringAsFixed(1)}x Income',
        'subtitle': 'Requested loan is high relative to annual earnings',
        'pts': '-25 pts',
        'positive': false,
      });
    }

    return list;
  }
}
