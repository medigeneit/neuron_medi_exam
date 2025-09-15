
import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/responsive.dart';



class Sizes {



  static double drawerWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Typically, drawer width is 70-80% of screen width on mobile
    // You can adjust these values as needed
    if (width < 600) {
      return width * 0.65; // 65% of screen width on small devices
    } else {
      return 400; // Fixed width for tablets/desktops
    }
  }



  static double bodyText(BuildContext context) {
    return Responsive.isMobile(context) ? 16 : (Responsive.isTablet(context) ? 18 : 20);
  }

  static double titleText(BuildContext context) {
    return Responsive.isMobile(context) ? 20 : (Responsive.isTablet(context) ? 22 : 24);
  }
  static double subTitleText(BuildContext context) {
    return Responsive.isMobile(context) ? 18 : (Responsive.isTablet(context) ? 20 : 22);
  }

  static double headingText(BuildContext context) {
    return Responsive.isMobile(context) ? 24 : (Responsive.isTablet(context) ? 26 : 28);
  }

  static double normalText(BuildContext context) {
    return Responsive.isMobile(context) ? 14 : (Responsive.isTablet(context) ? 16 : 18);
  }

  static double smallText(BuildContext context) {
    return Responsive.isMobile(context) ? 12 : (Responsive.isTablet(context) ? 14 : 16);
  }
  static double verySmallText(BuildContext context) {
    return Responsive.isMobile(context) ? 10 : (Responsive.isTablet(context) ? 12 : 14);
  }
  static double extraSmallText(BuildContext context) {
    return Responsive.isMobile(context) ? 8 : (Responsive.isTablet(context) ? 10 : 12);
  }

  static double buttonText(BuildContext context) {
    return Responsive.isMobile(context) ? 16 : (Responsive.isTablet(context) ? 18 : 20);
  }

  static double logoBig(BuildContext context) {
    return Responsive.isMobile(context) ? 200 : (Responsive.isTablet(context) ? 240 : 250);
  }

  static double profileImage(BuildContext context) {
    return Responsive.isMobile(context) ? 32 : (Responsive.isTablet(context) ? 36 : 38);
  }
  static double profileImageBig(BuildContext context) {
    return Responsive.isMobile(context) ? 50 : (Responsive.isTablet(context) ? 54 : 58);
  }

  static double courseIcon(BuildContext context) {
    return Responsive.isMobile(context) ? 44 : (Responsive.isTablet(context) ? 60 : 72);
  }

  static double normalIcon(BuildContext context) {
    return Responsive.isMobile(context) ? 30 : (Responsive.isTablet(context) ? 32 : 34);
  }

  static double smallIcon(BuildContext context) {
    return Responsive.isMobile(context) ? 26 : (Responsive.isTablet(context) ? 28 : 30);
  }

  static double verySmallIcon(BuildContext context) {
    return Responsive.isMobile(context) ? 20 : (Responsive.isTablet(context) ? 22 : 26);
  }

  static double extraSmallIcon(BuildContext context) {
    return Responsive.isMobile(context) ? 16 : (Responsive.isTablet(context) ? 20 : 22);
  }

  static double veryExtraSmallIcon(BuildContext context) {
    return Responsive.isMobile(context) ? 12 : (Responsive.isTablet(context) ? 16 : 20);
  }

  static double verySmallRadius(BuildContext context) {
    return Responsive.isMobile(context) ? 5 : (Responsive.isTablet(context) ? 6 : 7);
  }

  static double verySmallDotRadius(BuildContext context) {
    return Responsive.isMobile(context) ? 4 : (Responsive.isTablet(context) ? 6 : 8);
  }


  static double loaderBig(BuildContext context) {
    return Responsive.isMobile(context) ? 50 : (Responsive.isTablet(context) ? 70 : 90);
  }
}









