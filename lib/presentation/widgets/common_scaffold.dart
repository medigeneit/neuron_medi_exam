import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/presentation/controllers/background_settings_controller.dart';
import 'package:medi_exam/presentation/screens/unit_video_cart_screen.dart';

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

  /// Show unit video cart icon in app bar
  final bool showCart;

  /// Optional cart button tap override
  final VoidCallback? onCartTap;

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
    this.showCart = false,
    this.onCartTap,
    this.maxContentWidth = 900,
    this.largeScreenPadding = const EdgeInsets.symmetric(horizontal: 16.0),
  });

  BackgroundSettingsController _bgCtrl() {
    return Get.isRegistered<BackgroundSettingsController>()
        ? Get.find<BackgroundSettingsController>()
        : Get.put(BackgroundSettingsController(), permanent: true);
  }

  List<Widget> _buildActions(BuildContext context) {
    final List<Widget> appBarActions = [];

    if (actions != null) {
      appBarActions.addAll(actions!);
    }

    if (showCart) {
      appBarActions.add(
        IconButton(
          tooltip: 'Cart',
          icon: const Icon(
            Icons.shopping_cart_outlined,
            color: Colors.white,
          ),
          onPressed: onCartTap ??
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UnitVideoCartScreen(),
                  ),
                );
              },
        ),
      );
    }

    return appBarActions;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final bgCtrl = _bgCtrl();

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
            title: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: Sizes.titleText(context),
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            centerTitle: true,
            actions: _buildActions(context),
          ),
          endDrawer: showDrawer ? const CustomDrawer() : null,

          // React to toggle
          body: Obx(() {
            final enabled = bgCtrl.animationEnabled.value;

            return AppBackground(
              enabled: enabled,
              intensity: isMobile ? 0.25 : 0.30,
              opacity: isMobile ? 0.10 : 0.12,
              child: responsiveBody,
            );
          }),

          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
        ),
      ),
    );
  }
}