import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/app_theme.dart';
import 'package:medi_exam/controller_binder.dart';
import 'package:medi_exam/main.dart';
import 'package:medi_exam/presentation/utils/routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GENESIS',
      theme: AppTheme.lightTheme,
      initialBinding: ControllerBinder(),
      initialRoute: RouteNames.splash,
      getPages: appRoutes,
      navigatorObservers: [routeObserver], //
    );
  }
}