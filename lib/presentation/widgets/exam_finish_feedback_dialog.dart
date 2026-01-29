// exam_finish_feedback_dialog.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';

// ✅ Update this import path to wherever your service is located
import 'package:medi_exam/data/services/exam_feedback_service.dart';

// If your response class name is different, adjust accordingly.
/// Expected:
/// resp.isSuccess (bool)
/// resp.errorMessage (String?)
/// service.submitExamFeedback({required String url, required String feedback})
///
/// If your API differs, edit _submit() accordingly.

class ExamFinishFeedbackDialog extends StatefulWidget {
  const ExamFinishFeedbackDialog({
    super.key,
    required this.successMessage,
    required this.feedbackUrl,
    required this.admissionId,
    required this.examId,
    required this.examType,
    this.middleWidget,
    this.accentColor,
    this.onSuccess,
    this.service,
  });

  final String successMessage;
  final String feedbackUrl;

  // For default navigation (if onSuccess == null)
  final String admissionId;
  final String examId;
  final String examType;

  /// Optional widget shown between success message and rating
  /// (Example: CalculatingRow(accent: ...))
  final Widget? middleWidget;

  /// Optional override accent
  final Color? accentColor;

  /// If provided, it will be called after successful submit (after pop).
  /// If null, the dialog will navigate to exam result using Get.offNamed.
  final Future<void> Function()? onSuccess;

  /// Optional DI
  final ExamFeedbackService? service;

  static Future<bool?> show(
      BuildContext context, {
        required String successMessage,
        required String feedbackUrl,
        required String admissionId,
        required String examId,
        required String examType,
        Widget? middleWidget,
        Color? accentColor,
        Future<void> Function()? onSuccess,
        ExamFeedbackService? service,
      }) {
    final theme = Theme.of(context);
    final grad = AppColor.secondaryGradient;
    final Color accent = accentColor ??
        (grad is LinearGradient ? grad.colors.first : theme.colorScheme.primary);

    return showGeneralDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      barrierDismissible: false,
      barrierLabel: 'Exam Finished',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return SafeArea(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: ScaleTransition(
              scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              child: FadeTransition(
                opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
                child: Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 600,
                      // ✅ key for overflow: cap dialog height
                      maxHeight: MediaQuery.of(ctx).size.height * 0.88,
                    ),
                    child: ExamFinishFeedbackDialog(
                      successMessage: successMessage,
                      feedbackUrl: feedbackUrl,
                      admissionId: admissionId,
                      examId: examId,
                      examType: examType,
                      middleWidget: middleWidget,
                      accentColor: accent,
                      onSuccess: onSuccess,
                      service: service,
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

  @override
  State<ExamFinishFeedbackDialog> createState() => _ExamFinishFeedbackDialogState();
}

class _ExamFinishFeedbackDialogState extends State<ExamFinishFeedbackDialog> {
  final TextEditingController _feedbackCtrl = TextEditingController();

  bool _submitting = false;
  int _selectedRating = 0;

  // Modern labels (your selected set)
  static const Map<int, String> _ratingLabels = <int, String>{
    1: 'Disappointing',
    2: 'Could be better',
    3: 'Fair',
    4: 'Great',
    5: 'Outstanding',
  };

  ExamFeedbackService get _service => widget.service ?? ExamFeedbackService();

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  void _applyRatingToText(int rating) {
    final label = _ratingLabels[rating] ?? '';
    final newLine = 'Rating: $rating/5 — $label';

    final current = _feedbackCtrl.text;
    final lines = current.split('\n');
    final existingIndex =
    lines.indexWhere((l) => l.trimLeft().startsWith('Rating:'));

    if (existingIndex != -1) {
      lines[existingIndex] = newLine;
      _feedbackCtrl.text = lines.join('\n').trimRight();
    } else {
      _feedbackCtrl.text = current.trim().isEmpty ? newLine : '$newLine\n$current';
    }

    // cursor to end
    _feedbackCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: _feedbackCtrl.text.length),
    );

    setState(() => _selectedRating = rating);
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final fb = _feedbackCtrl.text.trim();

      final resp = await _service.submitExamFeedback(
        url: widget.feedbackUrl,
        feedback: fb,
      );

      if (!mounted) return;

      if (resp.isSuccess) {
        Get.snackbar(
          'Thanks!',
          'Your feedback has been submitted.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Navigator.pop(context, true);

        // After closing dialog
        if (widget.onSuccess != null) {
          await widget.onSuccess!.call();
        } else {
          final data = {
            'admissionId': widget.admissionId,
            'examId': widget.examId,
            'examType': widget.examType,
          };
          Get.offNamed(RouteNames.examResult, arguments: data);
        }
      } else {
        Get.snackbar(
          'Error',
          resp.errorMessage ?? 'Failed to submit feedback',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (_) {
      if (!mounted) return;
      Get.snackbar(
        'Error',
        'Failed to submit feedback',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = widget.accentColor ?? theme.colorScheme.primary;

    final String label = _selectedRating == 0
        ? 'Tap a star to rate'
        : '${_ratingLabels[_selectedRating]} • $_selectedRating/5';

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: CustomBlobBackground(
        backgroundColor: Colors.white,
        blobColor: accent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.white,
            child: Column(
              children: [
                // Header (fixed)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 22, 16, 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.green.withOpacity(0.18)),
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'All done 🎉',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColor.primaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'How was the experience?',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // ✅ Scrollable body (fix overflow)
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Success message
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.withOpacity(0.18)),
                          ),
                          child: Text(
                            widget.successMessage,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ),

                        if (widget.middleWidget != null) ...[
                          const SizedBox(height: 16),
                          widget.middleWidget!,
                        ],

                        const SizedBox(height: 16),

                        // Rating
                        Text(
                          'Rate this exam',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.withOpacity(0.18)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 0,
                                children: List.generate(5, (i) {
                                  final star = i + 1;
                                  final isActive = star <= _selectedRating;

                                  return InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: _submitting ? null : () => _applyRatingToText(star),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                      child: Icon(
                                        isActive
                                            ? Icons.star_rounded
                                            : Icons.star_outline_rounded,
                                        size: 34,
                                        color: isActive ? Colors.amber : Colors.grey[400],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.tips_and_updates_outlined,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      label,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Pick a star — we’ll drop the rating into your note below. Add anything you want after that.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.35,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Feedback
                        Text(
                          'Tell us more',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.withOpacity(0.18)),
                          ),
                          child: TextField(
                            controller: _feedbackCtrl,
                            maxLines: 6,
                            minLines: 4,
                            textInputAction: TextInputAction.newline,
                            enabled: !_submitting,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              hintText:
                              'What felt great? What should be smoother?\nExample: “Loved the explanations — timing felt a bit tight.”',
                              hintStyle: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                                height: 1.35,
                                fontWeight: FontWeight.w600,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                ),

                const Divider(height: 1),

                // Footer (fixed)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _submitting ? null : _submit,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: AppColor.secondaryGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.purple.withOpacity(0.28),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_submitting)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              else
                                const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              const Text(
                                'Submit feedback',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
