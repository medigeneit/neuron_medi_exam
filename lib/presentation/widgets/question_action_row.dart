// lib/presentation/widgets/question_action_row.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/question_explaination_button.dart';

/// Compact 3-action row:
/// 1) Bookmark (UI-only)
/// 2) Stats (animated pie chart dialog; UI-only)
/// 3) Explanation (lazy API)
class QuestionActionRow extends StatefulWidget {
  final int? questionId;
  final bool initiallyBookmarked;
  final DifficultyStats? stats;

  const QuestionActionRow({
    super.key,
    required this.questionId,
    this.initiallyBookmarked = false,
    this.stats,
  });

  @override
  State<QuestionActionRow> createState() => _QuestionActionRowState();
}

class _QuestionActionRowState extends State<QuestionActionRow> {
  late bool _bookmarked;

  @override
  void initState() {
    super.initState();
    _bookmarked = widget.initiallyBookmarked;
  }

  DifficultyStats get _stats =>
      widget.stats ?? const DifficultyStats.happyDefault();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
/*
        // 1) Bookmark
        _ActionPillButton(
          icon: _bookmarked
              ? Icons.bookmark_rounded
              : Icons.bookmark_border_rounded,
          label: 'Favorite',
          selected: _bookmarked,
          onTap: () => setState(() => _bookmarked = !_bookmarked),
        ),
        const SizedBox(width: 10),

        // 2) Stats
        _ActionPillButton(
          icon: Icons.pie_chart_outline_rounded,
          label: 'Stats',
          selected: false,
          onTap: () => _openStatsDialog(context),
        ),
*/

        const Spacer(),

        // 3) Explanation
        QuestionExplainationButton(
          questionId: widget.questionId,
          compact: true,
        ),
      ],
    );
  }

  void _openStatsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: CustomBlobBackground(
            backgroundColor: Colors.white,
            blobColor: AppColor.indigo,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(Icons.pie_chart_rounded,
                          size: 20, color: AppColor.indigo),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Question Difficulty',
                          style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColor.primaryTextColor,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Animated Pie + legend
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.60,
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: SizedBox(
                              width: 180,
                              height: 180,
                              child: AnimatedPieChart(
                                sections: _stats.sections,
                                strokeWidth: 26,
                                duration: const Duration(milliseconds: 900),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _Legend(sections: _stats.sections),
                          const SizedBox(height: 6),


                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// ------------------------------
/// Data models (UI-only)
/// ------------------------------

class DifficultyStats {
  final List<PieSection> sections;

  const DifficultyStats({required this.sections});

  /// 3 unique labels (recommended)
  const DifficultyStats.happyDefault()
      : sections = const [
    PieSection(
      label: 'Challenging',
      percent: 28,
      color: Colors.red,
      icon: Icons.local_fire_department_rounded,
    ),
    PieSection(
      label: 'Moderate',
      percent: 42,
      color: Colors.orange,
      icon: Icons.bolt_rounded,
    ),
    PieSection(
      label: 'Easy',
      percent: 30,
      color: Colors.green,
      icon: Icons.verified_rounded,
    ),
  ];
}

class PieSection {
  final String label;
  final double percent; // 0..100
  final Color color;
  final IconData icon;

  const PieSection({
    required this.label,
    required this.percent,
    required this.color,
    required this.icon,
  });
}

/// ------------------------------
/// Compact pill button
/// ------------------------------
class _ActionPillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ActionPillButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = AppColor.indigo;
    final Color border = selected ? accent.withOpacity(0.55) : Colors.black12;
    final Color bg = selected ? accent.withOpacity(0.08) : Colors.white;
    final Color iconColor = selected ? accent : Colors.black87;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style:  TextStyle(
                fontSize: Sizes.verySmallText(context),
                fontWeight: FontWeight.w900,
                color: AppColor.primaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------
/// Animated Pie Chart (no external libs)
/// ------------------------------

class AnimatedPieChart extends StatefulWidget {
  final List<PieSection> sections;
  final double strokeWidth;
  final Duration duration;

  const AnimatedPieChart({
    super.key,
    required this.sections,
    required this.strokeWidth,
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  State<AnimatedPieChart> createState() => _AnimatedPieChartState();
}

class _AnimatedPieChartState extends State<AnimatedPieChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _t = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If data changes, replay the animation
    if (oldWidget.sections != widget.sections ||
        oldWidget.strokeWidth != widget.strokeWidth ||
        oldWidget.duration != widget.duration) {
      _ctrl.duration = widget.duration;
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (_, __) {
        return CustomPaint(
          painter: _AnimatedPiePainter(
            sections: widget.sections,
            strokeWidth: widget.strokeWidth,
            t: _t.value, // 0..1
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '100%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColor.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Distribution',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColor.primaryTextColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedPiePainter extends CustomPainter {
  final List<PieSection> sections;
  final double strokeWidth;
  final double t; // 0..1

  _AnimatedPiePainter({
    required this.sections,
    required this.strokeWidth,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;

    // background ring (subtle)
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = Colors.black.withOpacity(0.05);
    canvas.drawCircle(center, radius, bg);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // total to normalize to 100
    final total = sections.fold<double>(0, (s, e) => s + e.percent);
    if (total <= 0) return;

    // We animate by limiting the total sweep we are allowed to draw:
    // allowedSweep = 2π * t
    final allowed = (2 * math.pi) * t;

    double startAngle = -math.pi / 2;

    for (final sec in sections) {
      final fullSweep = (sec.percent / total) * (2 * math.pi);
      final alreadyUsed = (startAngle - (-math.pi / 2));
      final remainingAllowed = allowed - alreadyUsed;

      if (remainingAllowed <= 0) break;

      final sweep = math.min(fullSweep, remainingAllowed);

      paint.color = sec.color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        paint,
      );

      startAngle += fullSweep; // advance start regardless, keeps proportions
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedPiePainter oldDelegate) {
    return oldDelegate.sections != sections ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.t != t;
  }
}

/// ------------------------------
/// Legend
/// ------------------------------
class _Legend extends StatelessWidget {
  final List<PieSection> sections;

  const _Legend({required this.sections});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: sections.map((s) => _legendRow(context, s)).toList(),
    );
  }

  Widget _legendRow(BuildContext context, PieSection s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: s.color.withOpacity(0.06),
          border: Border.all(color: s.color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: s.color.withOpacity(0.12),
                border: Border.all(color: s.color.withOpacity(0.35)),
              ),
              child: Icon(s.icon, size: 16, color: s.color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                s.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColor.primaryTextColor,
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              '${s.percent.toStringAsFixed(0)}%',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColor.primaryTextColor.withOpacity(0.85),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
