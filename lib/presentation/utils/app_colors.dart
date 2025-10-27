import 'package:flutter/material.dart';

class AppColor {

  static const Color primaryColor = Color(0xFF662483);
  static const Color secondaryColor = Color(0xFFC580EA);
  static const Color primaryDisableColor = Color(0xFF8C7594);

/*  static const Color primaryColor = Color(0xFF1373B6);
  static const Color secondaryColor = Colors.lightBlueAccent;
  static const Color primaryDisableColor = Colors.blueGrey;*/



  static const Color lightCardColor = Color(0xFFF7ECF0);
  static const Color lightCircleColor = Color(0xFFF1DBFF);


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


  static  Gradient blueGradient = LinearGradient(
    colors: [Colors.blue.shade600, Colors.blue.shade800],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient greenGradient = LinearGradient(
    colors: [Colors.green.shade500, Colors.green.shade800],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient redGradient = LinearGradient(
    colors: [Colors.red.shade400, Colors.red.shade800],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient orangeGradient = LinearGradient(
    colors: [Colors.orange.shade400, Colors.orange.shade800],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient yellowGradient = LinearGradient(
    colors: [Colors.yellow.shade400, Colors.yellow.shade800],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient purpleGradient = LinearGradient(
    colors: [Colors.purple.shade400, Colors.purple.shade800],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient pinkGradient = LinearGradient(
    colors: [Colors.pink.shade400, Colors.pink.shade800],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient tealGradient = LinearGradient(
    colors: [Colors.teal.shade400, Colors.teal.shade800],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient cyanGradient = LinearGradient(
    colors: [Colors.cyan.shade400, Colors.cyan.shade800],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient deepPurpleCyanGradient = LinearGradient(
    colors: [Colors.deepPurpleAccent, Colors.cyan,],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient deepPurpleBlueGradient = LinearGradient(
    colors: [Colors.deepPurple, Colors.blue,],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient deepPurplePinkGradient = LinearGradient(
    colors: [Colors.deepPurple, Colors.pink,],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient deepPrimaryDeepPurpleGradient = LinearGradient(
    colors: [AppColor.primaryColor, Colors.deepPurple,],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient blueCyanGradient = LinearGradient(
    colors: [Colors.blue, Colors.cyan,],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient greenTealGradient = LinearGradient(
    colors: [Colors.green, Colors.teal,],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

static Gradient deepPurpleTealGradient = LinearGradient(
    colors: [Colors.deepPurple, Colors.teal,],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );


  static Gradient blueGreenGradient = LinearGradient(
    colors: [Colors.blue, Colors.green,],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient blueGreenDarkGradient = LinearGradient(
    colors: [Colors.blue.shade700, Colors.green.shade700,],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}