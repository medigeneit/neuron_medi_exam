import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/widgets/custom_drawer.dart';


class CommonScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showDrawer;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  const CommonScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showDrawer = false,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColor.primaryColor,
          title: Text(title, style: const TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          actions: actions,
        ),
        endDrawer: showDrawer ? const CustomDrawer() : null,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}