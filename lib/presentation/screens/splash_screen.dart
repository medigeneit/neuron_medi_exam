import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/assets_path.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _opacityAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    final route = RouteNames.navBar;
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
      }
    } catch (e) {
      debugPrint('Immediate update failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.primary.withOpacity(.15),
                  cs.secondary.withOpacity(.10),
                  cs.tertiary.withOpacity(.10),
                ],
              ),
            ),
          ),
          // Animated blobs for depth
          Positioned(
            top: -80,
            left: -60,
            child: _Blob(color: cs.primary.withOpacity(.20), size: 220),
          ),
          Positioned(
            bottom: -60,
            right: -40,
            child: _Blob(color: cs.secondary.withOpacity(.18), size: 180),
          ),

          // Center content
          Center(
            child: FadeTransition(
              opacity: _opacityAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
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
                      'Welcome to ${AssetsPath.appName}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColor.primaryColor,
                        fontSize: Sizes.subTitleText(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AssetsPath.appTagline,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        letterSpacing: 0.8,
                        color: AppColor.primaryColor.withOpacity(0.6),
                        fontSize: Sizes.normalText(context),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(.35),
            blurRadius: 60,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}
