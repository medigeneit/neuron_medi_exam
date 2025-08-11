import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static SharedPreferences? _prefs;

  // Fixed Keys
  static const String seenOnboarding = 'seen_onboarding';
  static const String token = 'auth_token';
  static const String userData = 'user_data';
  static const String appVersion = 'app_version';
  static const String rememberMe = 'remember_me';
  static const String deviceInfo = 'device_info';
  static const String deviceId = 'device_id';
  static const String platform = 'platform';

  // Initialize
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // --------- String ---------
  static Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  // --------- Int ---------
  static Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  // --------- Bool ---------
  static Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  // --------- Double ---------
  static Future<void> setDouble(String key, double value) async {
    await _prefs?.setDouble(key, value);
  }

  static double? getDouble(String key) {
    return _prefs?.getDouble(key);
  }

  // --------- JSON Object (Map) ---------
  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    String jsonString = jsonEncode(value);
    await _prefs?.setString(key, jsonString);
  }

  static Map<String, dynamic>? getObject(String key) {
    String? jsonString = _prefs?.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  // --------- Remove / Clear ---------
  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  static Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
