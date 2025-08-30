import 'package:flutter/material.dart';

class AppColor {

  static const Color primaryColor = Color(0xFF662483);
  static const Color primaryDisableColor = Color(0xFF8C7594);
  static const Color lightCardColor = Color(0xFFF7ECF0);
  static const Color lightCircleColor = Color(0xFFF1DBFF);
  //static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color secondaryColor = Color(0xFFC580EA);
  static const Color backgroundColor = Color(0xFFF7F5F8);
  static const Color primaryTextColor = Color(0xFF1F003B);
  static const Color secondaryTextColor = Color(0xFF505050);
  static const Color greyColor = Colors.grey;
  static const Color blackColor = Colors.black;
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color orangeColor = Color(0xFFFF6B00);
  static const Color armyGreen = Color(0xFF454B1B);
  static const Color midnightBlue = Color(0xFF191970);
  static const Color midnightPurple = Color(0xFF24002A);
  static const Color indigo = Color(0xFF6366F1);
  static const Color purple = Color(0xFF8B5CF6);

  static const Gradient primaryGradient = LinearGradient(
    colors: [AppColor.primaryColor, AppColor.secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient secondaryGradient = LinearGradient(
    colors: [AppColor.purple, AppColor.indigo,],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient warningGradient = LinearGradient(
    colors: [Colors.red, Colors.orange],
    begin: Alignment.bottomRight,
    end: Alignment.topLeft,
  );

  static  Gradient silverGradient = LinearGradient(
    colors: [Colors.grey.shade700, Colors.grey.shade300],
    begin: Alignment.bottomRight,
    end: Alignment.topLeft,
  );

}