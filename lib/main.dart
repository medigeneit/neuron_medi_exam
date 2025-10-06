import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:medi_exam/app.dart';
import 'package:medi_exam/data/utils/auth_checker.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required before async init
  await LocalStorageService.init();
  await Get.putAsync(() => AuthChecker().init());
  // Enable WebView debugging only on supported platforms
  if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
    try {
      await InAppWebViewController.setWebContentsDebuggingEnabled(true);
    } catch (e) {
      // Just ignore if platform does not support it
      debugPrint("WebView debugging not supported on this platform: $e");
    }
  }
  runApp(const MyApp());
}
