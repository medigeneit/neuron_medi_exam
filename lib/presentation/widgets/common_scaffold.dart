import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/responsive.dart';
import 'package:medi_exam/presentation/widgets/app_background.dart';
import 'package:medi_exam/presentation/widgets/custom_drawer.dart';

import '../utils/sizes.dart';


class CommonScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showDrawer;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  /// Max content width used on tablet/desktop
  final double maxContentWidth;

  /// Optional horizontal padding around the clamped content on larger screens
  final EdgeInsetsGeometry largeScreenPadding;

  const CommonScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showDrawer = false,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.maxContentWidth = 900, // tweak to taste
    this.largeScreenPadding = const EdgeInsets.symmetric(horizontal: 16.0),
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    // Mobile -> raw body
    // Tablet/Desktop -> centered, width-constrained body
    final Widget responsiveBody = isMobile
        ? body
        : Center(
      child: Padding(
        padding: largeScreenPadding,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: body,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.purple.shade900,
      body: SafeArea(
        child: Scaffold(
          backgroundColor: AppColor.backgroundColor,
          appBar: AppBar(
            backgroundColor: AppColor.primaryColor,
            title: Text(title, style:  TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: Sizes.titleText(context))),
            iconTheme: const IconThemeData(color: Colors.white),
            centerTitle: true,
            actions: actions,
          ),
          endDrawer: showDrawer ? const CustomDrawer() : null,
          body: isMobile ? AppBackground(
            intensity: 0.20,
              opacity: 0.05,
              child: responsiveBody) : AppBackground(
              intensity: 0.25,
              opacity: 0.06,
              child: responsiveBody),
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
        ),
      ),
    );
  }
}