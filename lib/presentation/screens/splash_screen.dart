import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/assets_path.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';
import 'package:in_app_update/in_app_update.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _checkForUpdate();
    await _navigate();
  }

  Future<void> _navigate() async {
    await LocalStorageService.init();
    await Future.delayed(const Duration(seconds: 2));
    _handleRegularNavigation();
  }

  void _handleRegularNavigation() {
    final token = LocalStorageService.getString(LocalStorageService.token);
    final route = token != null && token.isNotEmpty ? RouteNames.homeScreen : RouteNames.login;
    debugPrint('Navigating to: $route');
    Get.offAllNamed(route);
  }

  Future<void> _checkForUpdate() async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          await _performImmediateUpdate();
        } else if (updateInfo.flexibleUpdateAllowed) {
          // You can choose to implement flexible update if needed
          debugPrint('Flexible update available but not implemented');
        }
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
    }
  }

  Future<void> _performImmediateUpdate() async {
    try {
      final result = await InAppUpdate.performImmediateUpdate();

      if (result == AppUpdateResult.success) {
        debugPrint('Update successful');
      } else {
        debugPrint('Update failed with result: $result');
        // Update failed, continue with app
      }
    } catch (e) {
      debugPrint('Immediate update failed: $e');
      // Update failed, continue with app
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AssetsPath.appLogo,
              width: Sizes.logoBig(context),
            ),
            const SizedBox(height: 60),
            const LoadingWidget(),
            const SizedBox(height: 40),
            Text(
              'Welcome to Neuron', // Change to your app name
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColor.primaryColor,
                fontSize: Sizes.subTitleText(context),
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ),
    );
  }
}