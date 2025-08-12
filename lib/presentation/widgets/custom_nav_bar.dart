import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';

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
        Icon(Icons.dashboard_outlined, color: AppColor.primaryColor),
        Icon(Icons.home_outlined, color: AppColor.primaryColor),
        Icon(Icons.person_outline, color: AppColor.primaryColor),
      ],
      inactiveIcons: const [
        Text("Dashboard", style: TextStyle(color: AppColor.primaryColor)),
        Text("Home", style: TextStyle(color: AppColor.primaryColor)),
        Text("Profile", style: TextStyle(color: AppColor.primaryColor)),
      ],
      color: AppColor.whiteColor,
      height: 54,
      circleWidth: 54,
      activeIndex: currentIndex,
      onTap: onTap,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      cornerRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
        bottomRight: Radius.circular(24),
        bottomLeft: Radius.circular(24),
      ),
      shadowColor: AppColor.primaryColor,
      elevation: 6,
    );
  }
}