import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/models/doctor_schedule_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';

/// Child list under each exam content to show solve links (videos).
/// Only shown when [content.is_show_solve == 1] and [solve_links] has items.
class ExamSolveLinksSection extends StatelessWidget {
  const ExamSolveLinksSection(
      {super.key, required this.content, required this.admissionId});

  final Content content;
  final String admissionId;

  bool get _shouldShow => content.canShowSolve && content.hasSolveLinks;

  @override
  Widget build(BuildContext context) {
    if (!_shouldShow) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final links = content.safeSolveLinks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Text(
                "Solutions",
                style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColor.purple, fontSize: Sizes.smallText(context)),
              ),
            ],
          ),
        ),

        // Links list with dividers
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
          ),
          child: Column(
            children: List.generate(links.length, (i) {
              final link = links[i];
              final isLast = i == links.length - 1;

              return Column(
                children: [
                  _SolveLinkTile(
                    title: link.safeName,
                    subtitle: content.safeSolveStatusMessage.isNotEmpty
                        ? content.safeSolveStatusMessage
                        : null,
                    unlocked: content.safeIsUnlockedSolve,
                    onTap: () {
                      if (!content.safeIsUnlockedSolve) {
                        final msg = content.safeSolveStatusMessage.isNotEmpty
                            ? content.safeSolveStatusMessage
                            : "Solve content is locked.";
                        Get.snackbar("Locked", msg,
                            snackPosition: SnackPosition.BOTTOM);
                      } else {
                        final data = {
                          'admissionId': admissionId ?? '', // safe pass-through
                          'solveVideoId': link.id ?? '',
                          'videoTitle': link.safeName,
                        };
                        Get.toNamed(
                          RouteNames.solveVideo,
                          arguments: data,
                          preventDuplicates: true,
                        );
                        print(
                            'admissionId: $admissionId & solveVideoId: ${link.id}');
                      }
                    },
                  ),

                  // Divider between items (except after the last one)
                  if (!isLast)
                    const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: Colors.black12,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _SolveLinkTile extends StatelessWidget {
  const _SolveLinkTile({
    required this.title,
    required this.subtitle,
    required this.unlocked,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final bool unlocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Play icon with gradient
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: unlocked
                        ? [AppColor.secondaryColor, AppColor.primaryColor]
                        : [
                            theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                            theme.colorScheme.onSurfaceVariant.withOpacity(0.2),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 14,
                  color: unlocked
                      ? Colors.white
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(width: 12),

              // Content
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
                        fontSize: 14,
                        color: unlocked
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
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Lock status
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: unlocked
                      ? AppColor.indigo.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  unlocked
                      ? Icons.lock_open_rounded
                      : Icons.lock_outline_rounded,
                  size: 16,
                  color: unlocked ? AppColor.indigo : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
