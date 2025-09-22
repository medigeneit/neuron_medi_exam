import 'package:flutter/material.dart';
import 'package:medi_exam/data/models/doctor_schedule_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';

import 'exam_list_section.dart';

/// DateSection is the main item of the schedule list.
/// It shows the date/time header for a ScheduleDate and lists exams inside
/// via [ExamListSection]. Each exam may expand with [ExamSolveLinksSection].
class DateSection extends StatelessWidget {
  final ScheduleDate scheduleDate;
  final String admissionId;

  const DateSection({
    Key? key,
    required this.scheduleDate,
    required this.admissionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final contents = scheduleDate.safeContents;
    final dateText = scheduleDate.dateFormatted;
    final timeText = scheduleDate.time;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CustomBlobBackground(
      backgroundColor: Colors.white,
      blobColor: AppColor.purple,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade300),
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
                            dateText!,
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
                  if (timeText!.isNotEmpty)
                    Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

              // Accent divider
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      (isDark ? Colors.white : Colors.black).withOpacity(0.10),
                      (isDark ? Colors.white : Colors.black).withOpacity(0.02),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Exam list for this date (no header inside)
              if (contents.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    'No items for this date',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.55),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                ExamListSection(
                  date: scheduleDate,
                  admissionId: admissionId,
                  showSolveChildren: true,
                  // keep layout tight, we already have outer padding
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
