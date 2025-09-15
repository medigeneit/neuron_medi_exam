// schedule_date_section.dart
import 'package:flutter/material.dart';
import 'package:medi_exam/data/models/batch_schedule_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'schedule_content_tile.dart';

/// Renders a single "date section" with its list of contents.
/// Modern, clean card. View-only: no tap/click handlers in the list.
class ScheduleDateSection extends StatelessWidget {
  final ScheduleDate scheduleDate;

  const ScheduleDateSection({
    Key? key,
    required this.scheduleDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final contents = scheduleDate.safeContents;
    final dateText = scheduleDate.safeDateFormatted;
    final timeText = scheduleDate.safeTime;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // subtle gradient border frame
        gradient: AppColor.primaryGradient
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0D0E11) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.45)
                  : Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row (date left, time right)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // date + calendar chip
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isDark
                                ? Colors.white.withOpacity(0.06)
                                : Colors.black.withOpacity(0.05),
                          ),
                          child: Icon(
                            Icons.calendar_month_rounded,
                            size: Sizes.extraSmallIcon(context),
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            dateText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: Sizes.normalText(context),
                              fontWeight: FontWeight.w900,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (timeText.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.10)
                              : Colors.black.withOpacity(0.06),
                        ),
                      ),
                      child: Text(
                        timeText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: Sizes.smallText(context),
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),

              // accent divider
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      (isDark ? Colors.white : Colors.black)
                          .withOpacity(0.10),
                      (isDark ? Colors.white : Colors.black)
                          .withOpacity(0.02),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // List of contents for this date
              if (contents.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    'No items for this date',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: (isDark ? Colors.white : Colors.black)
                          .withOpacity(0.55),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: contents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final content = contents[index];
                    return ScheduleContentTile(content: content);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
