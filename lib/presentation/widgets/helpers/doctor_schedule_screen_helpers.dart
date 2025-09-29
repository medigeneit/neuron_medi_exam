import 'package:flutter/material.dart';
import 'package:medi_exam/data/models/doctor_schedule_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/date_section.dart';
import 'package:medi_exam/presentation/widgets/fancy_card_background.dart';
import '../../utils/sizes.dart';

/// --------------------------------------------------------
/// Compact batch info card (no navigation button)
/// --------------------------------------------------------
class BatchInfoCardCompact extends StatelessWidget {
  const BatchInfoCardCompact({super.key, required this.batch});
  final Batch batch;

  double get _progress {
    final p = (batch.progressCount ?? 0).toDouble();
    return (p.clamp(0, 100)) / 100.0;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = AppColor.whiteColor;
    final gradient = AppColor.secondaryGradient; // Completed look

    return FancyBackground(
      gradient: gradient,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with info icon that opens details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  (batch.batchName?.isNotEmpty ?? false)
                      ? batch.batchName!
                      : (batch.courseName?.isNotEmpty ?? false)
                      ? batch.courseName!
                      : 'Unnamed Batch',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(Icons.info_outline_rounded, color: textColor, size: 20),
                onPressed: () => _showCourseDetails(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 6),


          // Progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Progress',
                      style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500)),
                  Text('${(_progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: _progress,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: textColor,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: textColor.withOpacity(0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCourseDetails(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      barrierDismissible: true,
      barrierLabel: 'Course Details',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        final color = AppColor.purple;
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: CustomBlobBackground(
                  backgroundColor: Colors.white,
                  blobColor: AppColor.indigo,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.school_rounded, color: color, size: 22),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Batch Details',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _detailRow(Icons.class_rounded, 'Course', batch.courseName ?? '—', color),
                        const SizedBox(height: 12),
                        _detailRow(Icons.layers_rounded, 'Discipline/Faculty', batch.coursePackageName ?? '—', color),
                        const SizedBox(height: 12),
                        _detailRow(Icons.calendar_today_rounded, 'Session', batch.year ?? '—', color),
                        const SizedBox(height: 12),
                        _detailRow(Icons.confirmation_number_rounded, 'Reg No', batch.regNo ?? '—', color),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 16, color: Colors.grey[800], fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      ),
    );
  }
}


/// --------------------------------------------------------
/// "Today" section card
/// --------------------------------------------------------
class TodaySectionCard extends StatelessWidget {
  const TodaySectionCard({
    super.key,
    required this.todayDate,
    required this.admissionId,
  });

  final ScheduleDate? todayDate;
  final String admissionId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasTodayItems = todayDate != null && todayDate!.safeContents.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(Icons.today_rounded, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Today',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Content
        if (hasTodayItems)
        // reuse the existing date renderer for consistency
          DateSection(scheduleDate: todayDate!, admissionId: admissionId)
        else
        // friendly empty state for today
          CustomBlobBackground(
            backgroundColor: Colors.grey.shade200,
            blobColor: Colors.grey.shade700,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: theme.colorScheme.onSurfaceVariant, size: 18,),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "You don't have any exam today.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}


/// --------------------------------------------------------
/// Search + calendar + print row
/// --------------------------------------------------------
class SearchActionsRow extends StatelessWidget {
  const SearchActionsRow({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onTapCalendar,
    required this.onTapClearDate,
    required this.onTapPrint,
    required this.pickedDate,
    required this.isCalendarLoading,
    required this.isPrintLoading,
  });

  final TextEditingController controller;
  final void Function(String) onChanged;
  final VoidCallback onTapCalendar;
  final VoidCallback onTapClearDate;
  final VoidCallback onTapPrint;
  final DateTime? pickedDate;

  // NEW
  final bool isCalendarLoading;
  final bool isPrintLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dateBadge = pickedDate != null
        ? Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${pickedDate!.day.toString().padLeft(2, '0')}-'
                '${pickedDate!.month.toString().padLeft(2, '0')}-'
                '${pickedDate!.year}',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onTapClearDate,
            child: Icon(Icons.close, size: 14, color: theme.colorScheme.primary),
          ),
        ],
      ),
    )
        : const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            // Search field
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: 'Search by topic',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: Sizes.smallText(context),
                    ),
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Calendar button (gradient round)
            Tooltip(
              message: 'Pick a date',
              child: GradientCircleButton(
                icon: Icons.calendar_today_rounded,
                onPressed: onTapCalendar,
                isLoading: isCalendarLoading,
                isDark: isDark,
                colorA: AppColor.indigo,
                colorB: AppColor.purple,
              ),
            ),

            const SizedBox(width: 10),

            // Print button (gradient round)
            Tooltip(
              message: 'Print',
              child: GradientCircleButton(
                icon: Icons.print_rounded,
                onPressed: onTapPrint,
                isLoading: isPrintLoading,
                isDark: isDark,
                colorA: AppColor.purple,
                colorB: AppColor.indigo,
              ),
            ),
          ],
        ),

        // Date chip
        if (pickedDate != null) ...[
          const SizedBox(height: 8),
          dateBadge,
        ]
      ],
    );
  }
}

/// -------------------- Reused views -----------------------
class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.onRetry});
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy, size: 42, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text('No schedule available', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Pull to refresh or try again.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
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

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 42, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text('Failed to load', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
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

class NoMatchesView extends StatelessWidget {
  const NoMatchesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 42, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text('No matches found', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Try a different search or clear the date filter.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// --------------------------------------------------------
/// Gradient circular action button
/// --------------------------------------------------------
class GradientCircleButton extends StatelessWidget {
  const GradientCircleButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.colorA,
    required this.colorB,
    this.isLoading = false,
    this.isDark = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color colorA;
  final Color colorB;
  final bool isLoading;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [colorA, colorB],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: isLoading ? null : onPressed, // disable while loading
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isLoading
                  ? const SizedBox(
                key: ValueKey('loading-fab'),
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Icon(
                icon,
                key: const ValueKey('content-fab'),
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
