// schedule_content_tile.dart
import 'package:flutter/material.dart';
import 'package:medi_exam/data/models/batch_schedule_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';

/// Compact content item (lecture/solve or exam) for a schedule date.
/// View-only; optimized for long lists and safe in unbounded list constraints.
class ScheduleContentTile extends StatelessWidget {
  final Content content;

  const ScheduleContentTile({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isExam = content.isExam;
    final IconData leadingIcon =
    isExam ? Icons.article_outlined : Icons.ondemand_video_rounded;
    final Color primary = isExam ? AppColor.purple : AppColor.indigo;

    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color surface = isDark ? const Color(0xFF0F1115) : Colors.white;
    final Color border = (isDark ? Colors.white : Colors.black).withOpacity(0.08);
    final Color titleColor = isDark ? Colors.white : Colors.black;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      // A fixed minimum height keeps the row from collapsing and avoids stretch issues.
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // ← no stretch
          children: [
            // Slim type stripe (safe height by using margins, not stretch)
            Container(
              width: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [primary.withOpacity(0.95), primary.withOpacity(0.55)],
                ),
              ),
            ),

            // Card body
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.28)
                          : Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    // Compact leading icon (no stretch)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            primary.withOpacity(isDark ? 0.22 : 0.16),
                            primary.withOpacity(isDark ? 0.38 : 0.26),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.18),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        leadingIcon,
                        size: 18,
                        color: isDark ? Colors.white : primary,
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Title + inline chip (kept dense)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            content.safeTopicName,
                            maxLines: 1, // keep lists tight; bump to 2 if needed
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              color: titleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

