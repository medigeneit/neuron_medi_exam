import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';

class HeaderInfoContainer extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? additionalText;
  final Color color;
  final IconData? icon;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double iconSize;

  const HeaderInfoContainer({
    Key? key,
    required this.title,
    this.subtitle,
    this.additionalText,
    this.color = AppColor.primaryColor,
    this.icon,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 16,
    this.iconSize = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: color,
                  size: iconSize,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: Sizes.bodyText(context),
                    fontWeight: FontWeight.w800,
                    color: AppColor.primaryTextColor,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: Sizes.normalText(context),
                color: AppColor.primaryTextColor.withOpacity(0.7),
              ),
            ),
          ],
          if (additionalText != null) ...[
            const SizedBox(height: 12),
            Text(
              additionalText!,
              style: TextStyle(
                fontSize: Sizes.normalText(context),
                color: AppColor.primaryTextColor.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}