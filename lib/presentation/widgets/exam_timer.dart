// lib/presentation/widgets/exam/exam_timer.dart
import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';

class ExamTimer extends StatelessWidget {
  final int secondsLeft;
  final bool isTimeUp;

  const ExamTimer({
    super.key,
    required this.secondsLeft,
    required this.isTimeUp,
  });

  @override
  Widget build(BuildContext context) {
    final mm = (secondsLeft ~/ 60).toString().padLeft(2, '0');
    final ss = (secondsLeft % 60).toString().padLeft(2, '0');
    final label = isTimeUp ? 'Time Up' : '$mm:$ss';

    final color = isTimeUp
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.timer_outlined, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
