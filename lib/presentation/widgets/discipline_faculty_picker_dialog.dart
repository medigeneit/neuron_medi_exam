import 'package:flutter/material.dart';
import 'package:medi_exam/data/models/discipline_faculty.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/discipline_faculty_card_widget.dart';

class DisciplineFacultyPickerDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isBatch;
  final List<DisciplineFaculty> faculties;
  final ValueChanged<DisciplineFaculty> onSelected;

  const DisciplineFacultyPickerDialog({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.faculties,
    required this.isBatch,
    required this.icon,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gradientColors = isBatch ? [AppColor.primaryColor, AppColor.secondaryColor] : [AppColor.indigo, AppColor.purple];

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
            // Modern Header with Gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                    child: _header(title: title, subtitle: subtitle, icon: icon),
                  ),
                  SizedBox(width: 6,),
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

            // Content Area
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                padding: const EdgeInsets.all(20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = (constraints.maxWidth / 300).floor().clamp(2, 4);
                    return GridView.builder(
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount: faculties.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 2.0,
                      ),
                      itemBuilder: (context, index) {
                        final item = faculties[index];
                        return DisciplineFacultyCard(
                          title: item.title,
                          onTap: () {
                            Navigator.of(context).pop();
                            onSelected(item);
                          },
                          gradientColors: gradientColors,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _header extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _header({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment:  CrossAxisAlignment.start,
          children: [
            Icon(icon, size: Sizes.verySmallIcon(context), color: Colors.white),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
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
      required List<DisciplineFaculty> faculties,
      required ValueChanged<DisciplineFaculty> onSelected,
    }) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (_) => DisciplineFacultyPickerDialog(
      title: title,
      subtitle: subtitle,
      faculties: faculties,
      icon: icon,
      isBatch: isBatch,
      onSelected: onSelected,
    ),
  );
}