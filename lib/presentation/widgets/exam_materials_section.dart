import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/models/doctor_schedule_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows "Exam Materials" (PDF) under an exam.
///
/// Rules:
/// - show only if show_pdf == true
/// - disabled until exam_status == "Completed"
/// - tap opens pdf_url in external app
class ExamMaterialsSection extends StatelessWidget {
  const ExamMaterialsSection({
    super.key,
    required this.content,
  });

  final Content content;

  bool get _shouldShow => content.hasPdfMaterials;

  bool get _isEnabled => content.isExamCompleted; // enable only when completed

  @override
  Widget build(BuildContext context) {
    if (!_shouldShow) return const SizedBox.shrink();

    final theme = Theme.of(context);

    final subtitle = _isEnabled
        ? null
        : (content.safeSolveStatusMessage.isNotEmpty
        ? content.safeSolveStatusMessage
        : 'Unlocks after exam completion');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
/*        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Text(
                "Exam Materials",
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColor.purple,
                  fontSize: Sizes.smallText(context),
                ),
              ),
            ],
          ),
        ),*/

        // Single tile (like solve links list)
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
          ),
          child: _MaterialTile(
            title: 'Exam Materials',
            subtitle: subtitle,
            enabled: _isEnabled,
            onTap: () async {
              if (!_isEnabled) {
                Get.snackbar(
                  "Locked",
                  subtitle ?? "Exam material is locked.",
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }
              final url = content.safePdf;

              Get.toNamed(
                RouteNames.pdfScreen,
                arguments: {
                  'url': content.safePdf,
                  'title': 'Exam Materials',
                  'fileName': content.safeTopicName,
                },
              );

              //await _launchFileUrl(url, context);
            },
          ),
        ),
      ],
    );
  }

  Future<void> _launchFileUrl(String url, BuildContext context) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
}

/// A tile that looks similar to your solve link tile.
class _MaterialTile extends StatelessWidget {
  const _MaterialTile({
    required this.title,
    required this.subtitle,
    required this.enabled,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1.0 : 0.55,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Leading icon (PDF)
                Container(
                  width: Sizes.veryExtraSmallIcon(context)+10,
                  height: Sizes.veryExtraSmallIcon(context)+10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: enabled
                          ? [AppColor.secondaryColor, AppColor.primaryColor]
                          : [
                        theme.colorScheme.onSurfaceVariant
                            .withOpacity(0.3),
                        theme.colorScheme.onSurfaceVariant
                            .withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf_outlined,
                    size: Sizes.veryExtraSmallIcon(context),
                    color:
                    enabled ? Colors.white : theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(width: 12),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: Sizes.smallText(context),
                          color: enabled
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: Sizes.verySmallText(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Lock / open icon
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: enabled
                        ? AppColor.indigo.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    enabled
                        ? Icons.open_in_new_rounded
                        : Icons.lock_outline_rounded,
                    size: 16,
                    color: enabled ? AppColor.indigo : Colors.red,
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
