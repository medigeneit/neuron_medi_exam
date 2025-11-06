// free_exam_item_widget.dart
import 'package:flutter/material.dart';
import 'package:medi_exam/data/models/free_exam_list_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';

/// High-level status the UI needs to show.
enum FreeExamStatus {
  available,   // doctor_open_exam == null
  continueExam,// doctor_open_exam.status == "Running"
  checkResult, // doctor_open_exam.status == "Finish"
}

class FreeExamItemWidget extends StatelessWidget {
  final FreeExamModel exam;
  final void Function(FreeExamModel exam, FreeExamStatus status)? onTap;

  const FreeExamItemWidget({
    Key? key,
    required this.exam,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = _deriveStatus(exam);
    final statusMeta = _statusUi(status);

    // Card styling: subtle gradient border + soft surface + hover splash
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          // faint colorful border
          colors: [
            statusMeta.accent.withOpacity(0.4),
            statusMeta.accent.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        // inner white/foreground container
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E2125)
              : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: statusMeta.accent.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: onTap == null ? null : () => onTap!(exam, status),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Leading icon badge
                  Container(
                    width: Sizes.mediumBigIcon(context),
                    height: Sizes.mediumBigIcon(context),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          statusMeta.accent,
                          statusMeta.accent.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: statusMeta.accent.withOpacity(0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      statusMeta.icon,
                      color: Colors.white,
                      size: Sizes.extraSmallIcon(context),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title + Course + Status Pill + Action hint
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          exam.safeTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Sizes.normalText(context),
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
         /*               const SizedBox(height: 6),

                        // Course name (muted)
                        if (exam.course?.hasName == true)
                          Text(
                            exam.course!.safeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: Sizes.verySmallText(context),
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),*/

                        const SizedBox(height: 12),

                        // Status + CTA-like chip row
                        Row(
                          children: [
                            _StatusPill(
                              label: statusMeta.label,
                              color: statusMeta.accent,
                              foregroundOnLight: statusMeta.foregroundOnLight,
                            ),
                            const Spacer(),
                            // Subtle CTA text
                            Row(
                              children: [
                                Text(
                                  statusMeta.action,
                                  style: TextStyle(
                                    fontSize: Sizes.verySmallText(context),
                                    fontWeight: FontWeight.w800,
                                    color: statusMeta.accent,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: Sizes.verySmallIcon(context),
                                  color: statusMeta.accent,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  FreeExamStatus _deriveStatus(FreeExamModel e) {
    // doctor_open_exam == null  => Available
    if (e.doctorOpenExam == null) return FreeExamStatus.available;

    // If list provided, look at the first (typical API shape)
    final item = e.doctorOpenExam!.isNotEmpty ? e.doctorOpenExam!.first : null;
    final s = item?.status?.toLowerCase().trim();

    if (s == 'running') return FreeExamStatus.continueExam;
    if (s == 'finish' || s == 'finished' || s == 'completed') {
      return FreeExamStatus.checkResult;
    }
    // Unknown status -> treat as available to allow taking it
    return FreeExamStatus.available;
  }

  _StatusUi _statusUi(FreeExamStatus status) {
    switch (status) {
      case FreeExamStatus.available:
        return _StatusUi(
          label: 'Available',
          action: 'Start now',
          icon: Icons.bolt_rounded,
          accent: AppColor.primaryColor, // aqua
          foregroundOnLight: Colors.white,
        );
      case FreeExamStatus.continueExam:
        return _StatusUi(
          label: 'Running',
          action: 'Continue',
          icon: Icons.timelapse_rounded,
          accent: AppColor.orange, // purple
          foregroundOnLight: Colors.white,
        );
      case FreeExamStatus.checkResult:
        return _StatusUi(
          label: 'Finished',
          action: 'View result',
          icon: Icons.verified_rounded,
          accent: AppColor.green, // coral
          foregroundOnLight: Colors.white,
        );
    }
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color foregroundOnLight;

  const _StatusPill({
    Key? key,
    required this.label,
    required this.color,
    required this.foregroundOnLight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? color.withOpacity(0.2) : color.withOpacity(0.12);
    final textColor = isDark ? color : color.darken(0.15);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25), width: 0.75),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: 0.5,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: Sizes.verySmallText(context),
              fontWeight: FontWeight.w800,
              color: textColor,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusUi {
  final String label;
  final String action;
  final IconData icon;
  final Color accent;
  final Color foregroundOnLight;

  _StatusUi({
    required this.label,
    required this.action,
    required this.icon,
    required this.accent,
    required this.foregroundOnLight,
  });
}

extension _ColorX on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final h = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return h.toColor();
  }
}
