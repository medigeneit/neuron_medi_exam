import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';

class CoursesCardWidget extends StatelessWidget {
  const CoursesCardWidget({
    Key? key,
    required this.title,
    required this.icon,
    this.onTap,
    this.onLearnMore,
    this.contentPadding = const EdgeInsets.all(12),
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onLearnMore;
  final EdgeInsets contentPadding;

  @override
  Widget build(BuildContext context) {
    const Color cardBg = Colors.white;
    final Color borderColor = AppColor.primaryColor.withOpacity(0.20);
    const Color titleColor = AppColor.primaryTextColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? onLearnMore,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 120, // Set a minimum height for consistency
          ),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: contentPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon at the top
              _IconBadge(icon: icon),


              // Title text with flexible space
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: Sizes.normalText(context),
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
              ),


              // Learn more button at the bottom
              _LearnMoreButton(onPressed: onLearnMore ?? onTap),
            ],
          ),
        ),
      ),
    );
  }
}

/// Leading icon with primary-tinted badge
class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColor.indigo.withOpacity(0.06),
        border: Border.all(
          color: AppColor.primaryColor.withOpacity(0.22),
        ),
      ),
      child: Icon(
        icon,
        size: 22,
        color: AppColor.primaryColor,
      ),
    );
  }
}

/// Outlined "Learn more" button using AppColor.primary
class _LearnMoreButton extends StatelessWidget {
  const _LearnMoreButton({this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        side: BorderSide(color: AppColor.indigo.withOpacity(0.55), width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        foregroundColor: AppColor.primaryColor,
        textStyle: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: Sizes.smallText(context),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Learn more'),
          SizedBox(width: 6),
          Icon(Icons.arrow_forward_rounded, size: 16),
        ],
      ),
    );
  }
}