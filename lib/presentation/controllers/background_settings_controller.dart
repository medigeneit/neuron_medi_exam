import 'package:get/get.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';

class BackgroundSettingsController extends GetxController {
  /// Storage key (so we can keep it on logout too if you want)
  static const String storageKey = 'background_animation_enabled';

  final RxBool animationEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    animationEnabled.value =
        LocalStorageService.getBackgroundAnimationEnabled(defaultValue: true);
  }

  void setEnabled(bool value) {
    animationEnabled.value = value;
    LocalStorageService.setBackgroundAnimationEnabled(value);
  }

  void toggle() => setEnabled(!animationEnabled.value);
}