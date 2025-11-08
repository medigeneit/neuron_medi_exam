import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:medi_exam/app.dart';
import 'package:medi_exam/data/utils/auth_checker.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';

// ⬇️ Add these two imports
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required before async init

  // Force system Photo Picker everywhere it is available (no READ_MEDIA_* needed)
  final pickerPlatform = ImagePickerPlatform.instance;
  if (pickerPlatform is ImagePickerAndroid) {
    pickerPlatform.useAndroidPhotoPicker = true;
  }

  await LocalStorageService.init();
  await Get.putAsync(() => AuthChecker().init());

  // Enable WebView debugging only on supported platforms (avoid desktop)
  if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
    try {
      await InAppWebViewController.setWebContentsDebuggingEnabled(true);
    } catch (e) {
      // Ignore if not supported
      debugPrint("WebView debugging not supported on this platform: $e");
    }
  }

  runApp(const MyApp());
}
