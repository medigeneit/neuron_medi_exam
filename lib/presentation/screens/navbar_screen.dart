import 'package:flutter/material.dart';
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

class _NavBarScreenState extends State<NavBarScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 1; // Start with home as the default
  late PageController _pageController;

  final List<Widget> _screens = [
    const Dashboard(),
    const HomeScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
        return 'App Name';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: _getTitle(_currentIndex),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      showDrawer: true,
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.jumpToPage(index);
          });
        },
      ),
    );
  }
}
