// exam_list_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/models/doctor_schedule_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';

import 'exam_solve_links_section.dart';

// NEW: model, service, and dialog imports (adjust paths if needed)
import 'package:medi_exam/data/models/exam_property_model.dart';
import 'package:medi_exam/data/services/exam_property_service.dart';
import 'package:medi_exam/presentation/widgets/exam_overview_dialog.dart';

class ExamListSection extends StatelessWidget {
  const ExamListSection({
    super.key,
    required this.date,
    required this.admissionId,
    this.padding = EdgeInsets.zero,
    this.showSolveChildren = true,
  });

  final ScheduleDate date;
  final String admissionId;
  final EdgeInsetsGeometry padding;
  final bool showSolveChildren;

  @override
  Widget build(BuildContext context) {
    final contents = date.safeContents;
    if (contents.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(contents.length, (index) {
          final c = contents[index];
          return _ExamCard(
            content: c,
            admissionId: admissionId, // pass down for fetching/navigating
            // Child list of solve/video links (only shows if allowed + has items)
            child: showSolveChildren
                ? ExamSolveLinksSection(content: c, admissionId: admissionId)
                : null,
          );
        }),
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({
    required this.content,
    required this.admissionId,
    this.child,
  });

  final Content content;
  final String admissionId;
  final Widget? child;

  bool get _isLocked => content.isLocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleText = _computeSubtitle(content);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColor.whiteColor.withOpacity(0.4),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            if (_isLocked) {
              final msg = content.safeStatusMessage.isNotEmpty
                  ? content.safeStatusMessage
                  : "This exam is locked.";
              Get.snackbar("Locked", msg, snackPosition: SnackPosition.BOTTOM);
              return;
            }

            final status = content.safeExamStatus.toLowerCase().trim();
            final shouldOpenDialog =
                status == 'not completed' || status == 'running';

            if (shouldOpenDialog) {
              await _openExamOverview(context);
            } else {
              // fallback: keep your previous behavior
              Get.snackbar(
                content.safeTopicName,
                "Status: ${content.safeExamStatus}",
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Leading icon with gradient
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        gradient: AppColor.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.quiz_outlined,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            content.safeTopicName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          if (subtitleText != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitleText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Status indicator
                    const SizedBox(width: 8),
                    _StatusIndicator(content: content),
                  ],
                ),

                // Child content (solve links)
                if (child != null) ...[
                  const SizedBox(height: 12),
                  child!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _computeSubtitle(Content c) {
    // Prefer API status_message if present
    final apiMessage = c.safeStatusMessage.trim();
    if (apiMessage.isNotEmpty) return apiMessage;

    // Fallbacks per requirements
    if (c.isLocked) return "Locked";
    if (c.isUnlocked) {
      final status = c.safeExamStatus.toLowerCase();
      if (status == "completed") return "View Result";
      if (status == "running") return "Continue Exam";
      if (status == "not completed") return "Not Completed";
    }
    return null;
  }

  Future<void> _openExamOverview(BuildContext context) async {
    // 1) tiny loader overlay
    Get.dialog(
      const Center(child: LoadingWidget()),
      barrierDismissible: false,
    );

    try {
      // 2) fetch the full model using your service
      final model = await _loadExamPropertyForContent(
        admissionId: admissionId,
        content: content,
      );

      // close loader
      if (Get.isDialogOpen == true) Get.back();

      // 3) show the dialog
      final started = await showExamOverviewDialog(
        context,
        model: model,
        admissionId: admissionId,
      );

      // 4) user tapped "Start exam"
      if (started == true) {
        // TODO: navigate into your exam flow (adjust to your routes)
        // Get.toNamed('/exam', arguments: {
        //   'admissionId': admissionId,
        //   'examId': model.exam?.id,
        //   'topic': content.safeTopicName,
        // });
      }
    } catch (e) {
      // close loader if still open
      if (Get.isDialogOpen == true) Get.back();
      Get.snackbar(
        'Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
      print('Error loading exam property: $e');
    }
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({required this.content});

  final Content content;

  @override
  Widget build(BuildContext context) {
    final status = content.safeExamStatus.toLowerCase();
    final theme = Theme.of(context);

    if (content.isLocked) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration:
        BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
        child: const Icon(Icons.lock_outline, size: 14, color: Colors.red),
      );
    }

    if (content.isUnlocked) {
      if (status == "completed") {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration:
          BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle_rounded, size: 14, color: Colors.green),
        );
      }
      if (status == "running") {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration:
          BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.incomplete_circle_rounded, size: 14, color: Colors.orange),
        );
      }
      if (status == "not completed") {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration:
          BoxDecoration(color: AppColor.indigo.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(Icons.lock_open_rounded, size: 14, color: AppColor.indigo),
        );
      }
    }

    // Default neutral indicator
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "View",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// ----------------------------------------------------------------------
/// Service-backed fetch using your ExamPropertyService
/// ----------------------------------------------------------------------
Future<ExamPropertyModel> _loadExamPropertyForContent({
  required String admissionId,
  required Content content,
}) async {
  final examId = content.examId;
  if (examId == null || examId.isEmpty) {
    throw Exception('Unable to determine exam id for this content.');
  }

  final service = ExamPropertyService();
  final res = await service.fetchExamProperty(admissionId, examId);

  if (!res.isSuccess) {
    throw Exception(res.errorMessage ?? 'Failed to load exam property.');
  }

  final data = res.responseData;
  if (data is ExamPropertyModel) {
    return data;
  }
  if (data is Map<String, dynamic>) {
    return ExamPropertyModel.fromJson(data);
  }
  throw Exception('Unexpected response data type: ${data.runtimeType}');
}

