import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:medi_exam/data/network_caller.dart';



class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    // Correct: Instantiate and store immediately
    Get.put<Logger>(Logger());

    // Correct: Create NetworkCaller immediately with the actual logger instance
    Get.put<NetworkCaller>(NetworkCaller(logger: Get.find<Logger>()));
  }
}

