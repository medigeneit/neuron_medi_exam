import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/presentation/screens/courses_screen.dart';
import 'package:medi_exam/presentation/screens/dashboard_screen.dart';
import 'package:medi_exam/presentation/screens/home_screen.dart';
import 'package:medi_exam/presentation/screens/notice_screen.dart';
import 'package:medi_exam/presentation/screens/profile_screen.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/custom_nav_bar.dart';

class NavBarScreen extends StatefulWidget {
  const NavBarScreen({super.key});

  @override
  State<NavBarScreen> createState() => _NavBarScreenState();
}

class _NavBarScreenState extends State<NavBarScreen> {
  late int _currentIndex; // Start with home as the default

  final List<Widget> _screens = [
    const Dashboard(),
    const CoursesScreen(),
    const HomeScreen(),
    const NoticeScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = Get.arguments ?? 2; // Get initial index (default to 1)
  }

  void _onNavBarTap(int index) {
    if (index == _currentIndex) return; // Avoid unnecessary updates
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
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      showDrawer: false,
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}
