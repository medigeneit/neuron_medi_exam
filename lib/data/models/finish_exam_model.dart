

import 'dart:convert';

/// Decode from a raw JSON string.
FinishExamModel finishExamModelFromJson(String source) =>
    FinishExamModel.fromJson(jsonDecode(source) as Map<String, dynamic>?);

/// Encode to a raw JSON string.
String finishExamModelToJson(FinishExamModel model) =>
    jsonEncode(model.toJson());

class FinishExamModel {
  /// Server message (may be empty or null).
  final String? message;

  /// Whether finishing/submitting the exam was successful.
  final bool? success;

  const FinishExamModel({
    this.message,
    this.success,
  });

  factory FinishExamModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FinishExamModel();
    return FinishExamModel(
      message: _Json.toStringOrNull(json['message']),
      success: _Json.toBool(json['success']),
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'success': success,
  };

  /// Optional convenience: treat null as false.
  bool get isSuccess => success == true;
}

/// Lightweight, forgiving JSON helpers (self-contained).
class _Json {
  static String? toStringOrNull(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    return v.toString();
  }

  static bool? toBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final t = v.trim().toLowerCase();
      if (t.isEmpty) return null;
      if (t == 'true' || t == '1' || t == 'yes') return true;
      if (t == 'false' || t == '0' || t == 'no') return false;
    }
    return null;
  }
}
