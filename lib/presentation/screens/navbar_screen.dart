import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/presentation/screens/dashboard_screen.dart';
import 'package:medi_exam/presentation/screens/home_screen.dart';
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
    const HomeScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = Get.arguments ?? 1; // Get initial index (default to 1)
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
        return 'Neuron Exam';
      case 2:
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
      showDrawer: true,
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}
