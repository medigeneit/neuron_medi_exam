import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:medi_exam/data/models/wrong_skipped_qus_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';

// ✅ Tip dialog (reusable + CustomBlobBackground)
import 'package:medi_exam/presentation/widgets/units_vs_questions_dialog.dart';

/// ------------------------------
/// Header stats widget (NOT tappable)
/// ------------------------------
class WrongSkippedTypeHeaderCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final WrongSkippedExamTypeSummary? summary;

  const WrongSkippedTypeHeaderCard({
    super.key,
    required this.title,
    required this.icon,
    required this.summary,
  });

  void _openTip(BuildContext context) {
    UnitsVsQuestionsDialog.show(
      context,
      blobColor: AppColor.primaryColor,
      backgroundColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    // -------------------- Units-based (primary) --------------------
    final answeredUnits =
        summary?.totalAnsweredQuestionUnits ?? summary?.totalAnsweredQuestions ?? 0;
    final wrongUnits =
        summary?.totalWrongAnswerUnits ?? summary?.totalWrongAnswers ?? 0;
    final skippedUnits =
        summary?.totalUnansweredQuestionUnits ?? summary?.totalUnansweredQuestions ?? 0;

    final providedTotalUnits = summary?.totalQuestionUnits ?? 0;
    final computedTotalUnits = answeredUnits + skippedUnits;
    final totalUnits = providedTotalUnits > 0 ? providedTotalUnits : computedTotalUnits;

    final correctUnits = math.max(0, answeredUnits - wrongUnits);

    // -------------------- Question-based (secondary) --------------------
    final answeredQ = summary?.totalAnsweredQuestions ?? 0;
    final skippedQ = summary?.totalUnansweredQuestions ?? 0;
    final providedTotalQ = summary?.totalQuestions ?? 0;
    final computedTotalQ = answeredQ + skippedQ;
    final totalQ = providedTotalQ > 0 ? providedTotalQ : computedTotalQ;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Icon bubble
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColor.primaryColor.withOpacity(0.18)),
              ),
              child: Icon(icon, color: AppColor.primaryColor, size: 22),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title (NO tip icon here)
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: Sizes.bodyText(context),
                      fontWeight: FontWeight.w900,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Total Question row + tip icon (✅ here)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'Total Question: $totalQ',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Sizes.verySmallText(context),
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => _openTip(context),
                        borderRadius: BorderRadius.circular(999),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Stats row (Units)
                  Row(
                    children: [
                      _MiniStat(
                        label: 'Correct\nUnites',
                        value: correctUnits,
                        color: Colors.green,
                      ),
                      _vDivider(),
                      _MiniStat(
                        label: 'Wrong\nUnites',
                        value: wrongUnits,
                        color: Colors.red,
                      ),
                      _vDivider(),
                      _MiniStat(
                        label: 'Skipped\nUnites',
                        value: skippedUnits,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Donut (Units-based)
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 74,
                  height: 74,
                  child: CustomPaint(
                    painter: _ModernDonutPainter(
                      correct: correctUnits,
                      wrong: wrongUnits,
                      skipped: skippedUnits,
                      total: totalUnits == 0 ? 1 : totalUnits,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$totalUnits',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: Sizes.smallText(context),
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'TOTAL\nUnites',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: Sizes.extraSmallText(context),
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _vDivider() => Container(
    height: 16,
    width: 1,
    color: Colors.grey.shade200,
    margin: const EdgeInsets.symmetric(horizontal: 10),
  );
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: Sizes.smallText(context),
            color: color,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: Sizes.verySmallText(context),
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

/// ------------------------------
/// List item widget (tappable)
/// ------------------------------
class WrongSkippedExamListItem extends StatelessWidget {
  final WrongSkippedExamSummaryItem item;
  final VoidCallback onTap;

  const WrongSkippedExamListItem({
    super.key,
    required this.item,
    required this.onTap,
  });

  void _openTip(BuildContext context) {
    UnitsVsQuestionsDialog.show(
      context,
      blobColor: AppColor.primaryColor,
      backgroundColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = (item.examTitle ?? 'Exam').trim();

    // -------------------- Units-based (primary) --------------------
    final answeredUnits =
        item.totalAnsweredQuestionUnits ?? item.totalAnsweredQuestions ?? 0;
    final wrongUnits =
        item.totalWrongAnswerUnits ?? item.totalWrongAnswers ?? 0;
    final skippedUnits =
        item.totalUnansweredQuestionUnits ?? item.totalUnansweredQuestions ?? 0;

    final providedTotalUnits = item.totalQuestionUnits ?? 0;
    final totalUnits =
    providedTotalUnits > 0 ? providedTotalUnits : (answeredUnits + skippedUnits);

    final correctUnits = math.max(0, answeredUnits - wrongUnits);

    // -------------------- Question-based (secondary) --------------------
    final answeredQ = item.totalAnsweredQuestions ?? 0;
    final skippedQ = item.totalUnansweredQuestions ?? 0;
    final providedTotalQ = item.totalQuestions ?? 0;
    final computedTotalQ = answeredQ + skippedQ;
    final totalQ = providedTotalQ > 0 ? providedTotalQ : computedTotalQ;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.withOpacity(0.20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              // left indicator bar
              Container(
                width: 6,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Title + (Total Question + tip) in a Column, side-by-side with Pie Chart
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title.isEmpty ? 'Exam' : title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: Sizes.normalText(context),
                                  fontWeight: FontWeight.w900,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Total Question: $totalQ',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: Sizes.verySmallText(context),
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black54,
                                        height: 1.1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () => _openTip(context),
                                    borderRadius: BorderRadius.circular(999),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: Icon(
                                        Icons.info_outline_rounded,
                                        size: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // ✅ Pie chart on the right
                        _StatsPieChart(
                          correct: correctUnits,
                          wrong: wrongUnits,
                          skipped: skippedUnits,
                          size: 34,
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // mini counts row (Units-based)
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        _CountChip(
                          icon: Icons.check_circle_rounded,
                          label: 'Correct Units',
                          value: correctUnits,
                          color: Colors.green,
                        ),
                        _CountChip(
                          icon: Icons.cancel_rounded,
                          label: 'Wrong Units',
                          value: wrongUnits,
                          color: Colors.red,
                        ),
                        _CountChip(
                          icon: Icons.do_not_disturb_on_rounded,
                          label: 'Skipped Units',
                          value: skippedUnits,
                          color: Colors.orange,
                        ),
                        _CountChip(
                          icon: Icons.all_inclusive_rounded,
                          label: 'Total Units',
                          value: totalUnits,
                          color: AppColor.primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsPieChart extends StatelessWidget {
  final int correct;
  final int wrong;
  final int skipped;
  final double size;

  const _StatsPieChart({
    required this.correct,
    required this.wrong,
    required this.skipped,
    this.size = 34,
  });

  @override
  Widget build(BuildContext context) {
    final total = (correct + wrong + skipped);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StatsPiePainter(
          correct: correct,
          wrong: wrong,
          skipped: skipped,
          total: total,
        ),
      ),
    );
  }
}

class _StatsPiePainter extends CustomPainter {
  final int correct;
  final int wrong;
  final int skipped;
  final int total;

  _StatsPiePainter({
    required this.correct,
    required this.wrong,
    required this.skipped,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = math.min(size.width, size.height) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.30;

    canvas.drawCircle(center, radius * 0.85, bgPaint);

    if (total <= 0) return;

    final stroke = radius * 0.30;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    double start = -math.pi / 2; // start at top

    void drawSlice(int value, Color color) {
      if (value <= 0) return;
      final sweep = (value / total) * (2 * math.pi);
      paint.color = color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.85),
        start,
        sweep,
        false,
        paint,
      );
      start += sweep;
    }

    drawSlice(correct, Colors.green);
    drawSlice(wrong, Colors.red);
    drawSlice(skipped, Colors.orange);
  }

  @override
  bool shouldRepaint(covariant _StatsPiePainter oldDelegate) {
    return oldDelegate.correct != correct ||
        oldDelegate.wrong != wrong ||
        oldDelegate.skipped != skipped ||
        oldDelegate.total != total;
  }
}

class _CountChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _CountChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: Sizes.verySmallText(context), color: color),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: Sizes.verySmallText(context),
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.trim().toLowerCase();
    Color color;
    if (s == 'completed') {
      color = Colors.lightGreen;
    } else if (s == 'running' || s == 'started') {
      color = Colors.blueAccent;
    } else {
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}

/// ------------------------------
/// Hero card for the exam stat screen
/// ------------------------------
class WrongSkippedExamHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final String updatedAt;
  final int total;
  final int correct;
  final int wrong;
  final int skipped;

  const WrongSkippedExamHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.updatedAt,
    required this.total,
    required this.correct,
    required this.wrong,
    required this.skipped,
  });

  void _openTip(BuildContext context) {
    UnitsVsQuestionsDialog.show(
      context,
      blobColor: AppColor.primaryColor,
      backgroundColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 86,
                  height: 86,
                  child: CustomPaint(
                    painter: _ModernDonutPainter(
                      correct: correct,
                      wrong: wrong,
                      skipped: skipped,
                      total: total == 0 ? 1 : total,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$total',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title (NO tip icon here)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Sizes.bodyText(context),
                            fontWeight: FontWeight.w900,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      if (status.trim().isNotEmpty) _StatusPill(status: status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: Sizes.smallText(context),
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  // Tip icon beside total question text (✅ here)
                  if (subtitle.trim().isNotEmpty) const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'Total Question: ',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Sizes.verySmallText(context),
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => _openTip(context),
                        borderRadius: BorderRadius.circular(999),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (updatedAt.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.update_rounded, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            updatedAt,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: Sizes.smallText(context),
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _MiniStat(label: 'Correct', value: correct, color: Colors.green),
                      _vDivider(),
                      _MiniStat(label: 'Wrong', value: wrong, color: Colors.red),
                      _vDivider(),
                      _MiniStat(label: 'Skipped', value: skipped, color: Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vDivider() => Container(
    height: 18,
    width: 1,
    color: Colors.grey.shade200,
    margin: const EdgeInsets.symmetric(horizontal: 12),
  );
}

/// ------------------------------
/// Donut painter (same style as your dashboard, polished)
/// ------------------------------
class _ModernDonutPainter extends CustomPainter {
  final int correct, wrong, skipped, total;

  _ModernDonutPainter({
    required this.correct,
    required this.wrong,
    required this.skipped,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final strokeWidth = 8.5;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - (strokeWidth / 2),
    );

    final bgPaint = Paint()
      ..color = Colors.grey.shade100
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - (strokeWidth / 2), bgPaint);

    final safeTotal = total <= 0 ? 1 : total;

    double startAngle = -math.pi / 2;

    _drawSegment(canvas, rect, startAngle, (correct / safeTotal), Colors.green, strokeWidth);
    startAngle += (correct / safeTotal) * 2 * math.pi;

    _drawSegment(canvas, rect, startAngle, (wrong / safeTotal), Colors.red, strokeWidth);
    startAngle += (wrong / safeTotal) * 2 * math.pi;

    _drawSegment(canvas, rect, startAngle, (skipped / safeTotal), Colors.orange, strokeWidth);
  }

  void _drawSegment(
      Canvas canvas,
      Rect rect,
      double start,
      double sweepPerc,
      Color color,
      double width,
      ) {
    if (sweepPerc <= 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    final sweep = (sweepPerc * 2 * math.pi);
    final safeSweep = sweep <= 0.12 ? sweep : (sweep - 0.12);
    canvas.drawArc(rect, start + 0.06, safeSweep, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
