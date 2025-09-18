import 'package:shared_preferences/shared_preferences.dart';

/// Stores read notice IDs per-user in SharedPreferences.
class NoticeReadStore {
  static const String _baseKey = 'read_notice_ids';
  static const String _anonymous = '_anonymous';

  /// Compute the storage key for a given user.
  static String keyForUser(String? userId) =>
      userId == null || userId.isEmpty ? '$_baseKey$_anonymous' : '$_baseKey$userId';

  /// Read all read IDs for a user.
  static Future<Set<int>> getReadIds({required String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(keyForUser(userId)) ?? const <String>[];
    return list.map(int.parse).toSet();
  }

  /// Add a single read ID for a user.
  static Future<void> add(int id, {required String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = keyForUser(userId);
    final set = (prefs.getStringList(key) ?? [])
        .map(int.parse)
        .toSet()
      ..add(id);
    await prefs.setStringList(key, set.map((e) => e.toString()).toList());
  }

  /// Remove a single read ID for a user.
  static Future<void> remove(int id, {required String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = keyForUser(userId);
    final set = (prefs.getStringList(key) ?? [])
        .map(int.parse)
        .toSet()
      ..remove(id);
    await prefs.setStringList(key, set.map((e) => e.toString()).toList());
  }

  /// Overwrite with a full set of IDs for a user.
  static Future<void> setAll(Iterable<int> ids, {required String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      keyForUser(userId),
      ids.map((e) => e.toString()).toList(),
    );
  }

  /// Clear read IDs for a user (not used on logout in this solution).
  static Future<void> clear({required String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyForUser(userId));
  }

  /// Expose the base key (useful if you need to build exceptions yourself).
  static String get baseKey => _baseKey;
}
