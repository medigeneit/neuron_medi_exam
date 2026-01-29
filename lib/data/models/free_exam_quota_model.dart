// lib/data/models/free_exam_quota_model.dart
import 'dart:convert';

class FreeExamQuotaModel {
  final bool? ok;
  final String? date;
  final int? dailyLimit;
  final int? usedQuestions;
  final int? remainingQuestions;
  final bool? canCreateExam;

  const FreeExamQuotaModel({
    this.ok,
    this.date,
    this.dailyLimit,
    this.usedQuestions,
    this.remainingQuestions,
    this.canCreateExam,
  });

  factory FreeExamQuotaModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FreeExamQuotaModel();
    return FreeExamQuotaModel(
      ok: _toBool(json['ok']),
      date: _toStringOrNull(json['date']),
      dailyLimit: _toInt(json['daily_limit']),
      usedQuestions: _toInt(json['used_questions']),
      remainingQuestions: _toInt(json['remaining_questions']),
      canCreateExam: _toBool(json['can_create_exam']),
    );
  }

  /// Accepts either a Map or a JSON string.
  factory FreeExamQuotaModel.parse(dynamic source) {
    if (source == null) return const FreeExamQuotaModel();

    if (source is Map<String, dynamic>) {
      return FreeExamQuotaModel.fromJson(source);
    }

    if (source is String && source.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(source);
        if (decoded is Map<String, dynamic>) {
          return FreeExamQuotaModel.fromJson(decoded);
        }
      } catch (_) {}
    }

    return const FreeExamQuotaModel();
  }

  Map<String, dynamic> toJson() => {
    'ok': ok,
    'date': date,
    'daily_limit': dailyLimit,
    'used_questions': usedQuestions,
    'remaining_questions': remainingQuestions,
    'can_create_exam': canCreateExam,
  };

  FreeExamQuotaModel copyWith({
    bool? ok,
    String? date,
    int? dailyLimit,
    int? usedQuestions,
    int? remainingQuestions,
    bool? canCreateExam,
  }) =>
      FreeExamQuotaModel(
        ok: ok ?? this.ok,
        date: date ?? this.date,
        dailyLimit: dailyLimit ?? this.dailyLimit,
        usedQuestions: usedQuestions ?? this.usedQuestions,
        remainingQuestions: remainingQuestions ?? this.remainingQuestions,
        canCreateExam: canCreateExam ?? this.canCreateExam,
      );
}

/* -------------------------- Safe parsing helpers -------------------------- */

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return null;
    return int.tryParse(s);
  }
  return null;
}

bool? _toBool(dynamic v) {
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

String? _toStringOrNull(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}
