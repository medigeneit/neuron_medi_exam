// navbar_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/utils/auth_service.dart';
import 'package:medi_exam/presentation/screens/courses_screen.dart';
import 'package:medi_exam/presentation/screens/dashboard_screen.dart';
import 'package:medi_exam/presentation/screens/home_screen.dart';
import 'package:medi_exam/presentation/screens/notice_screen.dart';
import 'package:medi_exam/presentation/screens/profile_section_screen.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/custom_nav_bar.dart';


class NavBarScreen extends StatefulWidget {
  const NavBarScreen({super.key});

  @override
  State<NavBarScreen> createState() => _NavBarScreenState();
}

class _NavBarScreenState extends State<NavBarScreen> {
  late int _currentIndex;
  final AuthService _authService = Get.find<AuthService>();

  @override
  void initState() {
    super.initState();
    _currentIndex = Get.arguments ?? 2;
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    // Check if current screen requires authentication
    if (_requiresAuthentication(_currentIndex)) {
      final isAuthenticated = await _authService.isAuthenticated();
      if (!isAuthenticated) {
        // Navigate to login and pass the intended destination
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
    // Define which screens require authentication
    return index == 0 || index == 4; // Dashboard and Profile require auth
  }

  Future<void> _onNavBarTap(int index) async {
    if (index == _currentIndex) return;

    // Check authentication for protected screens
    if (_requiresAuthentication(index)) {
      final isAuthenticated = await _authService.isAuthenticated();
      if (!isAuthenticated) {
        // Navigate to login and pass the intended destination
        Get.toNamed(
          RouteNames.login,
          arguments: {
            'returnRoute': RouteNames.navBar,
            'returnArguments': index,
          },
        );
        return;
      }
    }

    // If authenticated or doesn't require auth, proceed with navigation
    switch (index) {
      case 0:
        Get.toNamed(RouteNames.navBar, arguments: 0);
        break;
      case 1:
        Get.toNamed(RouteNames.navBar, arguments: 1);
        break;
      case 2:
        Get.toNamed(RouteNames.navBar, arguments: 2);
        break;
      case 3:
        Get.toNamed(RouteNames.navBar, arguments: 3);
        break;
      case 4:
        Get.toNamed(RouteNames.navBar, arguments: 4);
        break;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Courses';
      case 2:
        return 'Neuron Exam';
      case 3:
        return 'Notice';
      case 4:
        return 'Profile';
      default:
        return 'Neuron Exam';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: _getTitle(_currentIndex),
      body: _getCurrentScreen(),
      showDrawer: false,
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
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