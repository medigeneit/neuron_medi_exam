import 'dart:convert';

class QuestionAnalyticsBreakdownModel {
  final int? questionId;
  final int? questionTypeId;

  /// For question_type_id == 2 (overall breakdown)
  final int? rightAsPercent;
  final int? wrongAsPercent;
  final int? skipAsPercent;

  /// For question_type_id == 1 (option-wise breakdown)
  /// Keys can be "A", "B", ... up to any count (10/20/etc).
  final Map<String, QuestionAnalyticsOptionBreakdown>? optionBreakdowns;

  const QuestionAnalyticsBreakdownModel({
    this.questionId,
    this.questionTypeId,
    this.rightAsPercent,
    this.wrongAsPercent,
    this.skipAsPercent,
    this.optionBreakdowns,
  });

  bool get isOptionWise => questionTypeId == 1;
  bool get isOverallWise => questionTypeId == 2;

  /// Convenient getter if you still want: model.option('A')
  QuestionAnalyticsOptionBreakdown? option(String key) => optionBreakdowns?[key];

  factory QuestionAnalyticsBreakdownModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const QuestionAnalyticsBreakdownModel();

    // Collect option objects like {"A": {...}, "B": {...}, ...}
    // Ignore known top-level keys.
    const knownKeys = <String>{
      'question_id',
      'question_type_id',
      'right_as_percent',
      'wrong_as_percent',
      'skip_as_percent',
    };

    final Map<String, QuestionAnalyticsOptionBreakdown> optionMap = {};

    json.forEach((key, value) {
      if (knownKeys.contains(key)) return;

      // Option keys typically like "A", "B", "C"... but could be anything.
      if (value is Map<String, dynamic>) {
        optionMap[key] = QuestionAnalyticsOptionBreakdown.fromJson(value);
      }
    });

    return QuestionAnalyticsBreakdownModel(
      questionId: _toInt(json['question_id']),
      questionTypeId: _toInt(json['question_type_id']),

      // overall style (type 2)
      rightAsPercent: _toInt(json['right_as_percent']),
      wrongAsPercent: _toInt(json['wrong_as_percent']),
      skipAsPercent: _toInt(json['skip_as_percent']),

      // option style (type 1)
      optionBreakdowns: optionMap.isEmpty ? null : optionMap,
    );
  }

  /// Accepts either a Map or a JSON string.
  factory QuestionAnalyticsBreakdownModel.parse(dynamic source) {
    if (source == null) return const QuestionAnalyticsBreakdownModel();

    if (source is Map<String, dynamic>) {
      return QuestionAnalyticsBreakdownModel.fromJson(source);
    }

    if (source is String && source.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(source);
        if (decoded is Map<String, dynamic>) {
          return QuestionAnalyticsBreakdownModel.fromJson(decoded);
        }
      } catch (_) {}
    }

    return const QuestionAnalyticsBreakdownModel();
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'question_id': questionId,
      'question_type_id': questionTypeId,
      'right_as_percent': rightAsPercent,
      'wrong_as_percent': wrongAsPercent,
      'skip_as_percent': skipAsPercent,
    };

    // Put option keys back at top-level: "A": {...}, "B": {...}
    optionBreakdowns?.forEach((k, v) {
      map[k] = v.toJson();
    });

    return map;
  }

  QuestionAnalyticsBreakdownModel copyWith({
    int? questionId,
    int? questionTypeId,
    int? rightAsPercent,
    int? wrongAsPercent,
    int? skipAsPercent,
    Map<String, QuestionAnalyticsOptionBreakdown>? optionBreakdowns,
  }) =>
      QuestionAnalyticsBreakdownModel(
        questionId: questionId ?? this.questionId,
        questionTypeId: questionTypeId ?? this.questionTypeId,
        rightAsPercent: rightAsPercent ?? this.rightAsPercent,
        wrongAsPercent: wrongAsPercent ?? this.wrongAsPercent,
        skipAsPercent: skipAsPercent ?? this.skipAsPercent,
        optionBreakdowns: optionBreakdowns ?? this.optionBreakdowns,
      );
}

class QuestionAnalyticsOptionBreakdown {
  final int? rightAsPercent;
  final int? wrongAsPercent;
  final int? skipAsPercent;

  const QuestionAnalyticsOptionBreakdown({
    this.rightAsPercent,
    this.wrongAsPercent,
    this.skipAsPercent,
  });

  factory QuestionAnalyticsOptionBreakdown.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const QuestionAnalyticsOptionBreakdown();

    return QuestionAnalyticsOptionBreakdown(
      rightAsPercent: _toInt(json['right_as_percent']),
      wrongAsPercent: _toInt(json['wrong_as_percent']),
      skipAsPercent: _toInt(json['skip_as_percent']),
    );
  }

  Map<String, dynamic> toJson() => {
    'right_as_percent': rightAsPercent,
    'wrong_as_percent': wrongAsPercent,
    'skip_as_percent': skipAsPercent,
  };

  QuestionAnalyticsOptionBreakdown copyWith({
    int? rightAsPercent,
    int? wrongAsPercent,
    int? skipAsPercent,
  }) =>
      QuestionAnalyticsOptionBreakdown(
        rightAsPercent: rightAsPercent ?? this.rightAsPercent,
        wrongAsPercent: wrongAsPercent ?? this.wrongAsPercent,
        skipAsPercent: skipAsPercent ?? this.skipAsPercent,
      );
}

/* -------------------------- Safe parsing helpers -------------------------- */

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is num) return v.toInt();
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return null;
    return int.tryParse(s);
  }
  return null;
}

String? _toStringOrNull(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

bool? _toBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final s = v.trim().toLowerCase();
    if (s == 'true' || s == '1' || s == 'yes') return true;
    if (s == 'false' || s == '0' || s == 'no') return false;
  }
  return null;
}

List<dynamic>? _toList(dynamic v) {
  if (v == null) return null;
  if (v is List) return v;
  return null;
}
