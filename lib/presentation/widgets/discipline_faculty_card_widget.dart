import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';

class DisciplineFacultyCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final List<Color> gradientColors;

  const DisciplineFacultyCard({
    Key? key,
    required this.title,
    required this.onTap,
    required this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: AppColor.secondaryGradient.withOpacity(0.1),
            border: Border.all(
              color: gradientColors[0].withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title with flexible space
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: Sizes.smallText(context),
                    fontWeight: FontWeight.w700,
                    color: AppColor.primaryTextColor,
                  ),
                ),
              ),

              const SizedBox(width: 4),

              // Animated arrow icon
 Icon(
                  Icons.arrow_forward_ios_outlined,
                  size: Sizes.veryExtraSmallIcon(context),
                  color: Colors.grey,
                ),
            ],
          ),
        ),
      ),
    );
  }
}