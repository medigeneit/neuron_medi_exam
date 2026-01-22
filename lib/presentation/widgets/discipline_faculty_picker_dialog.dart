import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:medi_exam/data/models/courses_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/discipline_faculty_card_widget.dart';

class DisciplineFacultyPickerDialog extends StatelessWidget {
  final String courseTitle;
  final String subtitle;
  final IconData icon;
  final bool isBatch;
  final List<Package> packages;
  final ValueChanged<Package> onSelected;

  const DisciplineFacultyPickerDialog({
    Key? key,
    required this.courseTitle,
    required this.subtitle,
    required this.packages,
    required this.isBatch,
    required this.icon,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gradientColors = isBatch
        ? [AppColor.primaryColor, AppColor.secondaryColor]
        : [AppColor.indigo, AppColor.purple];

    return Dialog(
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 720),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1D21) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              blurRadius: 40,
              spreadRadius: -10,
              color: Colors.black.withOpacity(0.35),
              offset: const Offset(0, 25),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
              decoration: BoxDecoration(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _Header(
                      courseTitle: courseTitle,
                      subtitle: subtitle,
                      icon: icon,
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount =
                  (constraints.maxWidth / 300).floor().clamp(2, 4);

                  const mainSpacing = 16.0;
                  const crossSpacing = 16.0;

                  final gridWidth = constraints.maxWidth;
                  final itemWidth = (gridWidth -
                      (crossAxisCount - 1) * crossSpacing) /
                      crossAxisCount;

                  final textScale = MediaQuery.of(context).textScaleFactor;
                  final baseMinHeight = 84.0;
                  final minTileHeight = baseMinHeight * textScale.clamp(0.9, 1.3);

                  final childAspectRatio = itemWidth / minTileHeight;

                  final itemCount = packages.length;
                  final rows = (itemCount / crossAxisCount).ceil();
                  final totalHeight = rows > 0
                      ? rows * (itemWidth / childAspectRatio) +
                      (rows - 1) * mainSpacing
                      : 0.0;

                  final maxHeight = MediaQuery.of(context).size.height * 0.6;
                  final effectiveHeight = math.min(totalHeight, maxHeight);
                  final shouldScroll = totalHeight > maxHeight;

                  return AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    child: SizedBox(
                      height: effectiveHeight,
                      child: GridView.builder(
                        padding: const EdgeInsets.only(bottom: 8),
                        physics: shouldScroll
                            ? const BouncingScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
                        itemCount: packages.length,
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: mainSpacing,
                          crossAxisSpacing: crossSpacing,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemBuilder: (context, index) {
                          final package = packages[index];
                          return DisciplineFacultyCard(
                            title: package.packageName ?? 'Unknown Package',
                            onTap: () {
                              Navigator.of(context).pop();
                              onSelected(package); // ✅ ONLY return selection
                            },
                            gradientColors: gradientColors,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String courseTitle;
  final String subtitle;
  final IconData icon;

  const _Header({
    required this.courseTitle,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: Sizes.smallIcon(context), color: Colors.white),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                courseTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: Sizes.bodyText(context),
                  fontWeight: FontWeight.w700,
                  color: AppColor.whiteColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.85),
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

/// Helper to open the dialog
Future<void> showDisciplineFacultyPickerDialog(
    BuildContext context, {
      required String title,
      required String subtitle,
      required IconData icon,
      required bool isBatch,
      required List<Package> packages,
      required ValueChanged<Package> onSelected,
    }) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (_) => DisciplineFacultyPickerDialog(
      courseTitle: title,
      subtitle: subtitle,
      packages: packages,
      icon: icon,
      isBatch: isBatch,
      onSelected: onSelected,
    ),
  );
}
