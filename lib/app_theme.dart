import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';


class AppTheme {
  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primaryColor),
    scaffoldBackgroundColor: AppColor.backgroundColor,
    appBarTheme: const AppBarTheme(
        backgroundColor: AppColor.backgroundColor,
        foregroundColor: AppColor.primaryTextColor),
    primaryColor: AppColor.primaryColor,

    // ---------- CARD THEME ----------
    cardTheme: CardTheme(
      color: AppColor.whiteColor, // Soft background color
      elevation: 2, // Light shadow effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
        side: BorderSide(
          color: Colors.grey.shade300,
          width: 1,
        ), // Grey border
      ),
    ),



    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: AppColor.primaryTextColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: TextStyle(
        color: AppColor.secondaryTextColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: _outlineInputBorder(),
        enabledBorder: _outlineInputBorder(),
        focusedBorder: _outlineInputBorder(AppColor.secondaryColor),
        errorBorder: _outlineInputBorder(),
        focusedErrorBorder: _outlineInputBorder(Colors.red),
        hintStyle: const TextStyle(color: AppColor.secondaryTextColor),
        labelStyle: const TextStyle(color: AppColor.secondaryTextColor)),
  );

  static OutlineInputBorder _outlineInputBorder([Color? color]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color ?? AppColor.primaryColor),
    );
  }
}
