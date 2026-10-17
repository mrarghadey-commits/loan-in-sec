import 'package:flutter/material.dart';

class ResultCard extends StatelessWidget {
  final bool isApproved;
  final double probability; // e.g. 0.946 for 94.6%
  final double dti;
  final double creditScore;

  const ResultCard({
    super.key,
    required this.isApproved,
    required this.probability,
    this.dti = 10.8,
    this.creditScore = 780,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isApproved ? const Color(0xFF0D9488) : const Color(0xFFE11D48);
    final statusText = isApproved ? 'Pre-Approved' : 'Application Flagged';
    final percentageText = '${(probability * 100).toStringAsFixed(1)}%';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F9F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isApproved ? Icons.verified_outlined : Icons.info_outline,
                      size: 16,
                      color: const Color(0xFF059669),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'INSTANT MATCH',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: Color(0xFF7C3AED)),
                    SizedBox(width: 6),
                    Text(
                      'Tier-1 Algorithm',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Subtitle
          const Text(
            'UNDERWRITING MODEL OUTPUT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),

          // Output Headline
          Row(
            children: [
              Text(
                '$statusText ',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                percentageText,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'High computational confidence across institutional lending matrices.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),

          // Progress indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: probability,
              minHeight: 8,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(
                isApproved ? const Color(0xFF059669) : const Color(0xFFEF4444),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Progress Labels
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Min. Clearance (70%)',
                style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
              ),
              Text(
                'Optimal Range',
                style: TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
