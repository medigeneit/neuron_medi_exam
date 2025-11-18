// exam_overview_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/models/exam_property_model.dart';
import 'package:medi_exam/presentation/screens/dashboard_screens/exam_questions_screen.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';

/// Show the dialog. Returns `true` if the user tapped "Start exam".
Future<bool?> showExamOverviewDialog(
    BuildContext context, {
      required ExamPropertyModel model,
      required String url,
      required String admissionId,
      required bool isFreeExam,
    }) {
  return showGeneralDialog<bool>(
    context: context,
    barrierLabel: 'Exam Overview',
    barrierColor: Colors.black.withOpacity(0.6),
    barrierDismissible: true,
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, animation, secondaryAnimation) {
      final child = Dialog(
        backgroundColor: Colors.transparent,
        // Top/bottom margin + horizontal padding
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ExamOverviewDialog(
            model: model,
            url: url,
            admissionId: admissionId,
            isFreeExam: isFreeExam,
          ),
        ),
      );

      return SafeArea(
        child: ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      );
    },
  );
}

/// The dialog content (scrollable, responsive)
class ExamOverviewDialog extends StatelessWidget {
  const ExamOverviewDialog({
    super.key,
    required this.model,
    required this.url,
    required this.admissionId,
    required this.isFreeExam,
  });

  final ExamPropertyModel model;
  final String url;
  final String admissionId;
  final bool isFreeExam;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exam = model.exam;
    final isPublished = exam?.isPublished ?? false;

    return CustomBlobBackground(
      backgroundColor: Colors.white,
      blobColor: AppColor.indigo,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColor.purple.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.assignment_rounded,
                          color: AppColor.purple, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        exam?.safeTitle.isNotEmpty == true
                            ? exam!.safeTitle
                            : 'Exam',
                        // allow more lines; wrap naturally
                        maxLines: 3,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context, false),
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Content (scrollable)
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: isPublished
                      ? _PublishedContent(model: model, theme: theme)
                      : _UnpublishedContent(theme: theme),
                ),
              ),

              // Footer actions
              if (isPublished) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: AppColor.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.play_arrow_rounded, color: AppColor.whiteColor,),
                          label: const Text(
                            'Start exam',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(true);

                            final data = {
                              'url': url,
                              'examId': (exam!.id ?? '').toString(),
                              'admissionId': admissionId,
                              'isFreeExam': isFreeExam,
                            };
                            Get.toNamed(
                              RouteNames.examQuestion,
                              arguments: data,
                              preventDuplicates: true,
                            );

                          },
                        ),
                      ),
                    ],

                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _UnpublishedContent extends StatelessWidget {
  const _UnpublishedContent({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This exam is not published yet.',
              softWrap: true,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PublishedContent extends StatelessWidget {
  const _PublishedContent({
    required this.model,
    required this.theme,
  });

  final ExamPropertyModel model;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final qp = model.questionProperty;
    final types = model.safeQuestionTypes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Metrics
        _SectionCard(
          title: 'Overview',
          leadingIcon: Icons.dashboard_customize_rounded,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _metricChip(
                  context,
                  icon: Icons.timer_rounded,
                  label: 'Duration',
                  value: _minsText(model.safeExamDurationMinutes),
                ),
                _metricChip(
                  context,
                  icon: Icons.format_list_numbered_rounded,
                  label: 'Total Qs',
                  value: (qp?.totalQuestion ?? model.safeExamQuestionCount)
                      .toString(),
                ),
                _metricChip(
                  context,
                  icon: Icons.checklist_rounded,
                  label: 'Total Mark',
                  value: _dashIfNull(qp?.perQuestionMark),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Question types (new layout)
        _SectionCard(
          title: 'Question types',
          leadingIcon: Icons.category_rounded,
          children: [
            if (types.isEmpty)
              Text(
                'No question types provided.',
                softWrap: true,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              Column(
                children: types.map((t) {
                  final name = (t.name ?? '').trim().isEmpty
                      ? 'Type'
                      : t.name!.trim();
                  final count = t.numberOfQuestion ?? 0;
                  final neg = t.perQuestionNegative;

                  return _QuestionTypeTile(
                    name: name,
                    questionCountText: '$count questions',
                    negativeText:
                    (neg == null) ? 'Neg —' : 'Neg ${_formatNumber(neg)}',
                  );
                }).toList(),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // Policy
        _SectionCard(
          title: 'Policy',
          leadingIcon: Icons.policy_rounded,
          children: [
            if (model.safePolicyText.isEmpty)
              Text(
                'No policy provided.',
                softWrap: true,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              _policyBullets(model.policyParagraphs, theme),
          ],
        ),
      ],
    );
  }

  Widget _policyBullets(List<String> bullets, ThemeData theme) {
    if (bullets.isEmpty) {
      return Text(
        (model.safePolicyText),
        softWrap: true,
        style: theme.textTheme.bodyMedium,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: bullets.map((p) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // using Expanded to avoid overflow
              Expanded(
                child: Text(
                  p,
                  softWrap: true,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _metricChip(BuildContext context,
      {required IconData icon, required String label, required String value}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            softWrap: false,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            softWrap: false,
            style:
            theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _QuestionTypeTile extends StatelessWidget {
  const _QuestionTypeTile({
    required this.name,
    required this.questionCountText,
    required this.negativeText,
  });

  final String name;
  final String questionCountText;
  final String negativeText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Icon + Name (wrap if needed)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColor.indigo.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.quiz_rounded,
                        size: 18, color: Color(0xFF5B6CFF)),
                  ),
                  const SizedBox(width: 12),
                  // Wrap long names
                  Expanded(
                    child: Text(
                      name,
                      softWrap: true,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Row 2: Question count + Negative mark (wrap on small widths)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _inlinePill(
                    icon: Icons.format_list_bulleted_rounded,
                    text: questionCountText,
                  ),
                  _inlinePill(
                    icon: Icons.remove_circle_outline,
                    text: negativeText,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Left accent stripe (gradient) for an eye-catchy touch
        Positioned(
          top: 0,
          bottom: 10, // align with card's bottom margin
          left: 0,
          child: Container(
            width: 4,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              gradient: LinearGradient(
                colors: [AppColor.indigo, AppColor.purple],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.leadingIcon,
    required this.children,
  });

  final String title;
  final IconData leadingIcon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomBlobBackground(
      backgroundColor: Colors.white,
      blobColor: AppColor.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(leadingIcon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    softWrap: true,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}

Widget _inlinePill({required IconData icon, required String text}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: Colors.grey.withOpacity(0.2)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF5B6CFF)),
        const SizedBox(width: 6),
        // Let pill text wrap if absolutely necessary across lines in tiny widths
        Flexible(
          child: Text(
            text,
            softWrap: true,
            overflow: TextOverflow.visible,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

// ----------- tiny helpers -----------

String _minsText(int minutes) {
  if (minutes <= 0) return '—';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '$m min';
  if (m == 0) return '${h}h';
  return '${h}h ${m}m';
}

String _dashIfNull(num? v) {
  if (v == null) return '—';
  final s = _formatNumber(v.toDouble());
  return s;
}

String _formatNumber(double v) {
  if (v == v.roundToDouble()) return v.toStringAsFixed(0);
  return v.toString();
}
