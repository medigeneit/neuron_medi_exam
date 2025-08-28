// auth_service.dart
import 'package:get/get.dart';
import 'local_storage_service.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  Future<bool> isAuthenticated() async {
    await LocalStorageService.init();
    final token = LocalStorageService.getString(LocalStorageService.token);
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await LocalStorageService.remove(LocalStorageService.token);
    await LocalStorageService.remove(LocalStorageService.userData);
  }

  Future<AuthService> init() async {
    await LocalStorageService.init();
    return this;
  }
}