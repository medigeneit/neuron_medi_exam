import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CircleNavBar(
      activeIcons: const [
        Icon(Icons.dashboard_customize_rounded, color: AppColor.whiteColor),
        Icon(Icons.home_rounded, color: AppColor.whiteColor),
        Icon(Icons.person, color: AppColor.whiteColor),
      ],
      inactiveIcons:  [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard_customize_outlined, color: AppColor.primaryTextColor),
            SizedBox(height: 2), // Space between icon and text
            Text("Dashboard", style: TextStyle(color: AppColor.primaryTextColor, fontSize: Sizes.verySmallText(context))),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_outlined, color: AppColor.primaryTextColor),
            SizedBox(height: 2), // Space between icon and text
            Text("Home", style: TextStyle(color: AppColor.primaryTextColor, fontSize: Sizes.verySmallText(context))),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, color: AppColor.primaryTextColor),
            SizedBox(height: 2), // Space between icon and text
            Text("Profile", style: TextStyle(color: AppColor.primaryTextColor, fontSize: Sizes.verySmallText(context))),
          ],
        ),
      ],
      circleColor: AppColor.primaryColor,
      color: AppColor.whiteColor,
      height: 54,
      circleWidth: 54,
      activeIndex: currentIndex,
      onTap: onTap,
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
      cornerRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
        bottomRight: Radius.circular(24),
        bottomLeft: Radius.circular(24),

      ),
      shadowColor: AppColor.primaryColor,
      elevation: 1,
    );
  }
}