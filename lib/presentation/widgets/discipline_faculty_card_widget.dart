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
    // Remove fixed height; allow it to grow with content.
    // Keep a small floor so very short titles still look tidy.
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 84), // <= was hard 72
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              // Use a subtle background; keep your gradient border vibe.
              gradient: AppColor.secondaryGradient.withOpacity(0.08),
              border: Border.all(
                color: gradientColors.first.withOpacity(0.22),
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title — allow up to 2 lines and wrap as needed.
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,                // <= ensure two lines show
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: Sizes.verySmallText(context),
                      fontWeight: FontWeight.w700,
                      color: AppColor.primaryTextColor,
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                // Arrow
                Icon(
                  Icons.arrow_forward_ios_outlined,
                  size: Sizes.veryExtraSmallIcon(context),
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
