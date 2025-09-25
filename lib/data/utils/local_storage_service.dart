import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static SharedPreferences? _prefs;

  // Fixed Keys
  static const String seenOnboarding = 'seen_onboarding';
  static const String token = 'auth_token';

  // Legacy (kept for migration/read-only)
  static const String userData = 'user_data';

  static const String appVersion = 'app_version';
  static const String rememberMe = 'remember_me';
  static const String deviceInfo = 'device_info';
  static const String deviceId = 'device_id';
  static const String platform = 'platform';

  // NEW: auth/otp session keys
  static const String lastPhone = 'last_phone';
  static const String lastOtpCode = 'last_otp_code';
  static const String otpToken = 'otp_token';
  static const String lastOtpExpiresAt = 'otp_expires_at';      // ISO string
  static const String lastOtpVerifiedAt = 'otp_verified_at';    // ISO string
  static const String isLoggedIn = 'is_logged_in';              // "true"/"false"
  static const String loggedInAt = 'logged_in_at';              // ISO string
  static const String lastAuthSnapshot = 'last_auth_snapshot';  // JSON

  // NEW: separate keys for doctor profile + top-level profile status
  static const String profileStatus = 'profile_status'; // bool

  static const String doctorId = 'doctor_id';
  static const String doctorNameKey = 'doctor_name';
  static const String doctorPhone = 'doctor_phone';
  static const String doctorEmail = 'doctor_email';
  static const String doctorStatus = 'doctor_status';
  static const String doctorPhoto = 'doctor_photo';

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

  /// Returns false when missing; use [getBoolNullable] if you need tri-state.
  static bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  /// Nullable bool getter (true/false/null)
  static bool? getBoolNullable(String key) {
    return _prefs?.getBool(key);
  }

  // --------- Double ---------
  static Future<void> setDouble(String key, double value) async {
    await _prefs?.setDouble(key, value);
  }

  static double? getDouble(String key) {
    return _prefs?.getDouble(key);
  }

  // --------- JSON Object (Map) [legacy/general utility] ---------
  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    await _prefs?.setString(key, jsonString);
  }

  static Map<String, dynamic>? getObject(String key) {
    final jsonString = _prefs?.getString(key);
    if (jsonString == null) return null;
    try {
      final decoded = jsonDecode(jsonString);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  // --------- Remove / Clear ---------
  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  /// Clear everything EXCEPT keys listed in [exceptKeys].
  static Future<void> clearAll({Set<String> exceptKeys = const {}}) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final k in keys) {
      if (!exceptKeys.contains(k)) {
        await prefs.remove(k);
      }
    }
  }

  // =======================================================================
  //                 NEW: DOCTOR PROFILE – SEPARATE FIELDS
  // =======================================================================

  /// Set multiple doctor fields at once (null removes the key).
  static Future<void> setDoctorFields({
    int? id,
    String? name,
    String? phone,
    String? email,
    bool? status,
    String? photo,
    bool? topLevelProfileStatus, // maps your old { "status": true }
  }) async {
    await _setOrRemoveInt(doctorId, id);
    await _setOrRemoveString(doctorNameKey, name);
    await _setOrRemoveString(doctorPhone, phone);
    await _setOrRemoveString(doctorEmail, email);
    await _setOrRemoveBool(doctorStatus, status);
    await _setOrRemoveString(doctorPhoto, photo);
    await _setOrRemoveBool(profileStatus, topLevelProfileStatus);
  }

  static int? getDoctorId() => getInt(doctorId);
  static String? getDoctorName() => getString(doctorNameKey);
  static String? getDoctorPhone() => getString(doctorPhone);
  static String? getDoctorEmail() => getString(doctorEmail);
  static bool? getDoctorStatus() => getBoolNullable(doctorStatus);
  static String? getDoctorPhoto() => getString(doctorPhoto);
  static bool? getProfileStatus() => getBoolNullable(profileStatus);

  /// Convenience: return a map shaped like the API's doctor object.
  static Map<String, dynamic> getDoctorAsMap() {
    return {
      'id': getDoctorId(),
      'name': getDoctorName(),
      'phone_number': getDoctorPhone(),
      'email': getDoctorEmail(),
      'status': getDoctorStatus(),
      'photo': getDoctorPhoto(),
    };
  }

  /// Remove all stored doctor fields.
  static Future<void> clearDoctor() async {
    await remove(doctorId);
    await remove(doctorNameKey);
    await remove(doctorPhone);
    await remove(doctorEmail);
    await remove(doctorStatus);
    await remove(doctorPhoto);
    await remove(profileStatus);
  }

  // =======================================================================
  //                        INTERNAL HELPERS + MIGRATION
  // =======================================================================

  static Future<void> _setOrRemoveString(String key, String? value) async {
    if (value == null || value.trim().isEmpty) {
      await remove(key);
    } else {
      await setString(key, value.trim());
    }
  }

  static Future<void> _setOrRemoveInt(String key, int? value) async {
    if (value == null) {
      await remove(key);
    } else {
      await setInt(key, value);
    }
  }

  static Future<void> _setOrRemoveBool(String key, bool? value) async {
    if (value == null) {
      await remove(key);
    } else {
      await setBool(key, value);
    }
  }



  // Lightweight safe casters (avoid importing model layer here)
  static int? _tryParseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return null;
      return int.tryParse(s) ?? double.tryParse(s)?.toInt();
    }
    return null;
  }

  static String? _asString(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static bool? _asBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.trim().toLowerCase();
      if (s.isEmpty) return null;
      if (['true', '1', 'yes', 'y'].contains(s)) return true;
      if (['false', '0', 'no', 'n'].contains(s)) return false;
    }
    return null;
  }
}
