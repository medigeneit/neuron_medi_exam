import 'package:flutter/material.dart';
import 'package:medi_exam/app.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required before async init
  await LocalStorageService.init();

  runApp(const MyApp());
}
