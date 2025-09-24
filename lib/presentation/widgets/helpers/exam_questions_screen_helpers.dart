// lib/presentation/screens/exam_questions_screen_helpers.dart
import 'package:flutter/material.dart';

/// Public version of the previous _ErrorCard (same design/logic).
class ErrorCardExam extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorCardExam({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 42, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Public version of the previous _CalculatingRow (same design/logic).
class CalculatingRow extends StatefulWidget {
  final Color accent;
  const CalculatingRow({super.key, required this.accent});

  @override
  State<CalculatingRow> createState() => _CalculatingRowState();
}

class _CalculatingRowState extends State<CalculatingRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _turns;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(); // continuous rotation

    _turns = CurvedAnimation(parent: _ctrl, curve: Curves.linear);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RotationTransition(
          turns: _turns,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.accent.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.autorenew_rounded,
              color: widget.accent,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Calculating your result… In the meantime, please share your feedback about the exam.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
            ),
          ),
        ),
      ],
    );
  }
}
