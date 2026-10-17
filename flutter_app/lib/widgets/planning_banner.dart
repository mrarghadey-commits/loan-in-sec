import 'package:flutter/material.dart';

class PlanningBanner extends StatelessWidget {
  final bool compact;
  const PlanningBanner({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: LayoutBuilder(builder: (context, constraints) {
      final narrow = constraints.maxWidth < 520;
      return SizedBox(
        height: compact ? 190 : (narrow ? 300 : 280),
        child: Stack(fit: StackFit.expand, children: [
          Image.asset('assets/images/planning.png', fit: BoxFit.cover,
            alignment: Alignment.centerRight, excludeFromSemantics: true),
          DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
            colors: [const Color(0xFF102C35).withValues(alpha: .96),
              const Color(0xFF102C35).withValues(alpha: narrow ? .60 : .12)],
          ))),
          Padding(padding: EdgeInsets.all(compact ? 22 : 28),
            child: Align(alignment: Alignment.centerLeft, child: SizedBox(
              width: compact ? 260 : 340,
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('LOAN IN SEC  /  PLAN WITH CLARITY', style: TextStyle(
                  color: Color(0xFF9DE4D5), fontSize: 11, letterSpacing: 1.8, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                Text(compact ? 'Your next chapter,\nthoughtfully planned.' : 'A clearer picture of\nyour financial future.',
                  style: TextStyle(color: Colors.white, fontSize: compact ? 24 : 32,
                    height: 1.15, fontWeight: FontWeight.w700)),
                if (!compact) ...[
                  const SizedBox(height: 16),
                  const Text('Explore monthly payments, understand affordability, and compare demo lenders.',
                    style: TextStyle(color: Color(0xFFDCEAE8), fontSize: 14, height: 1.6)),
                ],
              ]),
            )),
          ),
        ]),
      );
    }),
  );
}
