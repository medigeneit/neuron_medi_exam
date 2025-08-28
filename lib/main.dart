import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/app.dart';
import 'package:medi_exam/data/utils/auth_service.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required before async init
  await LocalStorageService.init();
  await Get.putAsync(() => AuthService().init());
  runApp(const MyApp());
}
