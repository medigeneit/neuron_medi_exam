// navbar_screen.dart
import 'dart:ui' show ImageFilter; // for BackdropFilter blur
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for SystemNavigator.pop
import 'package:get/get.dart';
import 'package:medi_exam/data/utils/auth_checker.dart';
import 'package:medi_exam/presentation/screens/courses_screen.dart';
import 'package:medi_exam/presentation/screens/dashboard_screens/dashboard_screen.dart';
import 'package:medi_exam/presentation/screens/home_screen.dart';
import 'package:medi_exam/presentation/screens/notice_screen.dart';
import 'package:medi_exam/presentation/screens/profile_section_screen.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/assets_path.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/custom_nav_bar.dart';

enum ExitBehavior { doubleTap, dialog }

class NavBarScreen extends StatefulWidget {
  const NavBarScreen({super.key});

  @override
  State<NavBarScreen> createState() => _NavBarScreenState();
}

class _NavBarScreenState extends State<NavBarScreen> {
  late int _currentIndex;
  final AuthChecker _authService = Get.find<AuthChecker>();

  // -------- choose your back-press behavior here --------
  final ExitBehavior _exitBehavior = ExitBehavior.doubleTap;
  //final ExitBehavior _exitBehavior = ExitBehavior.dialog;
  // ------------------------------------------------------

  DateTime? _lastBackPress; // for "double back to exit"

  @override
  void initState() {
    super.initState();
    _currentIndex = (Get.arguments is int) ? Get.arguments as int : 2;
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    if (_requiresAuthentication(_currentIndex)) {
      final isAuthenticated = await _authService.isAuthenticated();
      if (!isAuthenticated && mounted) {
        if (Get.isSnackbarOpen ?? false) Get.closeAllSnackbars();
        Get.snackbar(
          'Login Required',
          'Please log in to access this section.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          colorText: Colors.white,
        );

        Get.offAllNamed(
          RouteNames.login,
          arguments: {
            'returnRoute': RouteNames.navBar,
            'returnArguments': _currentIndex,
          },
        );
      }
    }
  }

  bool _requiresAuthentication(int index) {
    // Dashboard and Profile require auth
    return index == 0 || index == 4;
  }

  Future<void> _onNavBarTap(int index) async {
    HapticFeedback.lightImpact();

    if (index == _currentIndex) return;

    if (_requiresAuthentication(index)) {
      final isAuthenticated = await _authService.isAuthenticated();
      if (!isAuthenticated) {
        if (Get.isSnackbarOpen ?? false) Get.closeAllSnackbars();
        Get.snackbar(
          'Login Required',
          'Please log in to access this section.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        Get.toNamed(
          RouteNames.login,
          arguments: {
            'returnRoute': RouteNames.navBar,
            'returnArguments': index,
            'message': "Join us to access your personalized features.",
          },
        );
        return;
      }
    }

    // IMPORTANT: don't push another NavBar route; just switch the tab locally.
    setState(() => _currentIndex = index);
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Courses';
      case 2:
        return AssetsPath.appName;
      case 3:
        return 'Notice';
      case 4:
        return 'Profile';
      default:
        return AssetsPath.appName;
    }
  }

// ===== modern back-press handler via PopScope =====
  Future<void> _handleBack(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    if (_exitBehavior == ExitBehavior.doubleTap) {
      final now = DateTime.now();
      if (_lastBackPress == null ||
          now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
        _lastBackPress = now;

        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(12),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.black.withOpacity(0.7),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: const [
                Icon(Icons.exit_to_app_rounded, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('One more tap',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      SizedBox(height: 2),
                      Text('Tap back again to exit.', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
        return; // don't exit yet
      }

      messenger.hideCurrentSnackBar();
      SystemNavigator.pop(); // exit app (Android)
    } else {
      _showExitDialog(context);
    }
  }


  void _showExitDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Exit',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, __, ___) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return Opacity(
          opacity: anim.value,
          child: Center(
            child: Transform.scale(
              scale: Tween<double>(begin: 0.75, end: 1).animate(curved).value,
              child: _ExitDialog(
                appName: AssetsPath.appName,
                onExit: () {
                  Navigator.of(ctx, rootNavigator: true).pop();
                  SystemNavigator.pop();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // We take over back handling at the root of this shell.
      canPop: false,
      onPopInvoked: (didPop) async {
        // If an inner Navigator popped something, do nothing here.
        if (didPop) return;
        await _handleBack(context);
      },
      child: CommonScaffold(
        title: _getTitle(_currentIndex),
        body: _getCurrentScreen(),
        showDrawer: false,
        bottomNavigationBar: CustomNavBar(
          currentIndex: _currentIndex,
          onTap: _onNavBarTap,
        ),
      ),
    );
  }

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return const Dashboard();
      case 1:
        return const CoursesScreen();
      case 2:
        return const HomeScreen();
      case 3:
        return const NoticeScreen();
      case 4:
        return const ProfileSectionScreen();
      default:
        return const HomeScreen();
    }
  }
}

/// A modern, glassy, animated exit dialog.
class _ExitDialog extends StatelessWidget {
  final String appName;
  final VoidCallback onExit;

  const _ExitDialog({required this.appName, required this.onExit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(

          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.88,
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
            child: CustomBlobBackground(
              backgroundColor: Colors.white,
              blobColor: Colors.redAccent,
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Subtle icon animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.5, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) =>
                          Transform.scale(scale: value, child: child),
                      child: CircleAvatar(
                        radius: 34,
                        backgroundColor:
                        theme.colorScheme.primary.withOpacity(0.15),
                        child: Icon(
                          Icons.exit_to_app_rounded,
                          size: 34,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Exit $appName?',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "You're about to close the app.",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: BorderSide(
                                color: AppColor.primaryColor
                              ),
                              foregroundColor:
                              AppColor.primaryColor,
                            ),
                            onPressed: () =>
                                Navigator.of(context, rootNavigator: true).pop(),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: onExit,
                            icon: const Icon(Icons.power_settings_new_rounded, color: Colors.white,),
                            label: const Text('Exit'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
