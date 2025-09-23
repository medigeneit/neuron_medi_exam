

import 'dart:convert';

/// Convenience: decode from a raw JSON string.
SingleAnswerSubmitModel singleAnswerSubmitModelFromJson(String source) =>
    SingleAnswerSubmitModel.fromJson(
      jsonDecode(source) as Map<String, dynamic>?,
    );

/// Convenience: encode to a raw JSON string.
String singleAnswerSubmitModelToJson(SingleAnswerSubmitModel model) =>
    jsonEncode(model.toJson());

class SingleAnswerSubmitModel {
  /// Whether the submission succeeded.
  final bool? success;

  /// Server message (may be empty).
  final String? message;

  /// Total number of questions submitted in this action.
  final int? submitedQuestions; // note: API spelling

  /// IDs that were submitted in this action.
  final List<int>? submitedQuestionIds; // note: API spelling

  /// IDs that were only partially answered.
  final List<int>? partialAnsweredQuestionIds;

  /// Count of partially answered question IDs.
  final int? countPartialAnsweredQuestionIds;

  const SingleAnswerSubmitModel({
    this.success,
    this.message,
    this.submitedQuestions,
    this.submitedQuestionIds,
    this.partialAnsweredQuestionIds,
    this.countPartialAnsweredQuestionIds,
  });

  factory SingleAnswerSubmitModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SingleAnswerSubmitModel();

    return SingleAnswerSubmitModel(
      success: _Json.toBool(json['success']),
      message: _Json.toStringOrNull(json['message']),
      submitedQuestions: _Json.toInt(json['submited_questions']),
      submitedQuestionIds: _Json.toIntList(json['submited_question_ids']),
      partialAnsweredQuestionIds:
      _Json.toIntList(json['partial_answered_question_ids']),
      countPartialAnsweredQuestionIds:
      _Json.toInt(json['count_partial_answered_question_ids']),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'submited_questions': submitedQuestions,
    'submited_question_ids': submitedQuestionIds,
    'partial_answered_question_ids': partialAnsweredQuestionIds,
    'count_partial_answered_question_ids':
    countPartialAnsweredQuestionIds,
  };

  /// Optional convenience: sorted copies of the ID lists.
  List<int>? get submitedQuestionIdsSorted =>
      submitedQuestionIds == null ? null : [...submitedQuestionIds!]?..sort();

  List<int>? get partialAnsweredQuestionIdsSorted =>
      partialAnsweredQuestionIds == null
          ? null
          : [...partialAnsweredQuestionIds!]?..sort();
}

/// Lightweight, forgiving JSON helpers (self-contained).
class _Json {
  static String? toStringOrNull(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    return v.toString();
  }

  static int? toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) {
      final t = v.trim();
      if (t.isEmpty) return null;
      return int.tryParse(t);
    }
    return null;
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

  static List<int>? toIntList(dynamic v) {
    if (v == null) return null;
    if (v is List) {
      final list = <int>[];
      for (final e in v) {
        final n = toInt(e);
        if (n != null) list.add(n);
      }
      return list.isEmpty ? null : list;
    }
    // Accept a single scalar too.
    final single = toInt(v);
    if (single != null) return [single];
    return null;
  }
}
