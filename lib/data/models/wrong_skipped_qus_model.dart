// lib/data/models/wrong_skipped_qus_model.dart
import 'dart:convert';

class WrongSkippedQusModel {
  // -------------------- Question-level (SBA+MCQ as "questions") --------------------
  final int? totalQuestions;
  final int? totalAnsweredQuestions;
  final int? totalUnansweredQuestions; // skipped (question-level)
  final int? totalWrongAnswers;

  // -------------------- Unit-level (MCQ stems + SBA) --------------------
  final int? totalQuestionUnits;
  final int? totalAnsweredQuestionUnits;
  final int? totalUnansweredQuestionUnits; // skipped (unit-level)
  final int? totalWrongAnswerUnits;

  final Map<String, WrongSkippedExamTypeSummary>? typeSummary;

  const WrongSkippedQusModel({
    this.totalQuestions,
    this.totalAnsweredQuestions,
    this.totalUnansweredQuestions,
    this.totalWrongAnswers,
    this.totalQuestionUnits,
    this.totalAnsweredQuestionUnits,
    this.totalUnansweredQuestionUnits,
    this.totalWrongAnswerUnits,
    this.typeSummary,
  });

  // -------------------- Computed helpers (question-level) --------------------
  int get computedTotalQuestions =>
      totalQuestions ??
          ((totalAnsweredQuestions ?? 0) + (totalUnansweredQuestions ?? 0));

  int get computedSkippedQuestions => totalUnansweredQuestions ?? 0;

  int get computedCorrectQuestions {
    final answered = totalAnsweredQuestions ?? 0;
    final wrong = totalWrongAnswers ?? 0;
    final c = answered - wrong;
    return c < 0 ? 0 : c;
  }

  // -------------------- Computed helpers (unit-level) --------------------
  int get computedTotalQuestionUnits =>
      totalQuestionUnits ??
          ((totalAnsweredQuestionUnits ?? 0) + (totalUnansweredQuestionUnits ?? 0));

  int get computedSkippedQuestionUnits => totalUnansweredQuestionUnits ?? 0;

  int get computedCorrectQuestionUnits {
    final answered = totalAnsweredQuestionUnits ?? 0;
    final wrong = totalWrongAnswerUnits ?? 0;
    final c = answered - wrong;
    return c < 0 ? 0 : c;
  }

  factory WrongSkippedQusModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const WrongSkippedQusModel();

    final rawTypeSummary = _toMap(json['type_summary']);
    final parsedTypeSummary = <String, WrongSkippedExamTypeSummary>{};

    if (rawTypeSummary != null) {
      rawTypeSummary.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          parsedTypeSummary[key] = WrongSkippedExamTypeSummary.fromJson(value);
        } else {
          parsedTypeSummary[key] = const WrongSkippedExamTypeSummary();
        }
      });
    }

    return WrongSkippedQusModel(
      // question-level
      totalQuestions: _toInt(json['total_questions']),
      totalAnsweredQuestions: _toInt(json['total_answered_questions']),
      totalUnansweredQuestions: _toInt(json['total_unanswered_questions']),
      totalWrongAnswers: _toInt(json['total_wrong_answers']),

      // unit-level
      totalQuestionUnits: _toInt(json['total_question_units']),
      totalAnsweredQuestionUnits: _toInt(json['total_answered_question_units']),
      totalUnansweredQuestionUnits: _toInt(json['total_unanswered_question_units']),
      totalWrongAnswerUnits: _toInt(json['total_wrong_answer_units']),

      typeSummary: parsedTypeSummary.isEmpty ? null : parsedTypeSummary,
    );
  }

  /// Accepts either a Map or a JSON string.
  factory WrongSkippedQusModel.parse(dynamic source) {
    if (source == null) return const WrongSkippedQusModel();

    if (source is Map<String, dynamic>) {
      return WrongSkippedQusModel.fromJson(source);
    }

    if (source is String && source.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(source);
        if (decoded is Map<String, dynamic>) {
          return WrongSkippedQusModel.fromJson(decoded);
        }
      } catch (_) {}
    }

    return const WrongSkippedQusModel();
  }

  Map<String, dynamic> toJson() => {
    // question-level
    'total_questions': totalQuestions,
    'total_answered_questions': totalAnsweredQuestions,
    'total_unanswered_questions': totalUnansweredQuestions,
    'total_wrong_answers': totalWrongAnswers,

    // unit-level
    'total_question_units': totalQuestionUnits,
    'total_answered_question_units': totalAnsweredQuestionUnits,
    'total_unanswered_question_units': totalUnansweredQuestionUnits,
    'total_wrong_answer_units': totalWrongAnswerUnits,

    'type_summary': typeSummary?.map((k, v) => MapEntry(k, v.toJson())),
  };

  WrongSkippedQusModel copyWith({
    int? totalQuestions,
    int? totalAnsweredQuestions,
    int? totalUnansweredQuestions,
    int? totalWrongAnswers,
    int? totalQuestionUnits,
    int? totalAnsweredQuestionUnits,
    int? totalUnansweredQuestionUnits,
    int? totalWrongAnswerUnits,
    Map<String, WrongSkippedExamTypeSummary>? typeSummary,
  }) =>
      WrongSkippedQusModel(
        totalQuestions: totalQuestions ?? this.totalQuestions,
        totalAnsweredQuestions: totalAnsweredQuestions ?? this.totalAnsweredQuestions,
        totalUnansweredQuestions: totalUnansweredQuestions ?? this.totalUnansweredQuestions,
        totalWrongAnswers: totalWrongAnswers ?? this.totalWrongAnswers,

        totalQuestionUnits: totalQuestionUnits ?? this.totalQuestionUnits,
        totalAnsweredQuestionUnits:
        totalAnsweredQuestionUnits ?? this.totalAnsweredQuestionUnits,
        totalUnansweredQuestionUnits:
        totalUnansweredQuestionUnits ?? this.totalUnansweredQuestionUnits,
        totalWrongAnswerUnits: totalWrongAnswerUnits ?? this.totalWrongAnswerUnits,

        typeSummary: typeSummary ?? this.typeSummary,
      );
}

class WrongSkippedExamTypeSummary {
  final String? examType;
  final String? examTypeLabel;

  // question-level
  final int? totalQuestions;
  final int? totalAnsweredQuestions;
  final int? totalUnansweredQuestions; // skipped
  final int? totalWrongAnswers;

  // unit-level
  final int? totalQuestionUnits;
  final int? totalAnsweredQuestionUnits;
  final int? totalUnansweredQuestionUnits; // skipped
  final int? totalWrongAnswerUnits;

  final List<WrongSkippedExamSummaryItem>? items;

  const WrongSkippedExamTypeSummary({
    this.examType,
    this.examTypeLabel,

    this.totalQuestions,
    this.totalAnsweredQuestions,
    this.totalUnansweredQuestions,
    this.totalWrongAnswers,

    this.totalQuestionUnits,
    this.totalAnsweredQuestionUnits,
    this.totalUnansweredQuestionUnits,
    this.totalWrongAnswerUnits,

    this.items,
  });

  // computed (question-level)
  int get computedTotalQuestions =>
      totalQuestions ??
          ((totalAnsweredQuestions ?? 0) + (totalUnansweredQuestions ?? 0));

  int get computedCorrectQuestions {
    final answered = totalAnsweredQuestions ?? 0;
    final wrong = totalWrongAnswers ?? 0;
    final c = answered - wrong;
    return c < 0 ? 0 : c;
  }

  // computed (unit-level)
  int get computedTotalQuestionUnits =>
      totalQuestionUnits ??
          ((totalAnsweredQuestionUnits ?? 0) + (totalUnansweredQuestionUnits ?? 0));

  int get computedCorrectQuestionUnits {
    final answered = totalAnsweredQuestionUnits ?? 0;
    final wrong = totalWrongAnswerUnits ?? 0;
    final c = answered - wrong;
    return c < 0 ? 0 : c;
  }

  factory WrongSkippedExamTypeSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const WrongSkippedExamTypeSummary();

    return WrongSkippedExamTypeSummary(
      examType: _toStringOrNull(json['exam_type']),
      examTypeLabel: _toStringOrNull(json['exam_type_label']),

      // question-level
      totalQuestions: _toInt(json['total_questions']),
      totalAnsweredQuestions: _toInt(json['total_answered_questions']),
      totalUnansweredQuestions: _toInt(json['total_unanswered_questions']),
      totalWrongAnswers: _toInt(json['total_wrong_answers']),

      // unit-level
      totalQuestionUnits: _toInt(json['total_question_units']),
      totalAnsweredQuestionUnits: _toInt(json['total_answered_question_units']),
      totalUnansweredQuestionUnits: _toInt(json['total_unanswered_question_units']),
      totalWrongAnswerUnits: _toInt(json['total_wrong_answer_units']),

      items: _toList(json['items'])
          ?.map((e) => e is Map<String, dynamic>
          ? WrongSkippedExamSummaryItem.fromJson(e)
          : const WrongSkippedExamSummaryItem())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'exam_type': examType,
    'exam_type_label': examTypeLabel,

    // question-level
    'total_questions': totalQuestions,
    'total_answered_questions': totalAnsweredQuestions,
    'total_unanswered_questions': totalUnansweredQuestions,
    'total_wrong_answers': totalWrongAnswers,

    // unit-level
    'total_question_units': totalQuestionUnits,
    'total_answered_question_units': totalAnsweredQuestionUnits,
    'total_unanswered_question_units': totalUnansweredQuestionUnits,
    'total_wrong_answer_units': totalWrongAnswerUnits,

    'items': items?.map((e) => e.toJson()).toList(),
  };

  WrongSkippedExamTypeSummary copyWith({
    String? examType,
    String? examTypeLabel,

    int? totalQuestions,
    int? totalAnsweredQuestions,
    int? totalUnansweredQuestions,
    int? totalWrongAnswers,

    int? totalQuestionUnits,
    int? totalAnsweredQuestionUnits,
    int? totalUnansweredQuestionUnits,
    int? totalWrongAnswerUnits,

    List<WrongSkippedExamSummaryItem>? items,
  }) =>
      WrongSkippedExamTypeSummary(
        examType: examType ?? this.examType,
        examTypeLabel: examTypeLabel ?? this.examTypeLabel,

        totalQuestions: totalQuestions ?? this.totalQuestions,
        totalAnsweredQuestions: totalAnsweredQuestions ?? this.totalAnsweredQuestions,
        totalUnansweredQuestions: totalUnansweredQuestions ?? this.totalUnansweredQuestions,
        totalWrongAnswers: totalWrongAnswers ?? this.totalWrongAnswers,

        totalQuestionUnits: totalQuestionUnits ?? this.totalQuestionUnits,
        totalAnsweredQuestionUnits:
        totalAnsweredQuestionUnits ?? this.totalAnsweredQuestionUnits,
        totalUnansweredQuestionUnits:
        totalUnansweredQuestionUnits ?? this.totalUnansweredQuestionUnits,
        totalWrongAnswerUnits: totalWrongAnswerUnits ?? this.totalWrongAnswerUnits,

        items: items ?? this.items,
      );
}

class WrongSkippedExamSummaryItem {
  final String? uid;

  final String? examType;
  final String? examTypeLabel;

  final int? examId;
  final String? examTitle;

  final String? status;

  // question-level
  final int? totalQuestions;
  final int? totalAnsweredQuestions;
  final int? totalUnansweredQuestions; // skipped
  final int? totalWrongAnswers;

  // unit-level
  final int? totalQuestionUnits;
  final int? totalAnsweredQuestionUnits;
  final int? totalUnansweredQuestionUnits; // skipped
  final int? totalWrongAnswerUnits;

  final String? updatedAt;

  /// For open/batch sometimes you get extra ids (doctor_exam_id, admission_id, etc.)
  final Map<String, dynamic>? meta;

  const WrongSkippedExamSummaryItem({
    this.uid,
    this.examType,
    this.examTypeLabel,
    this.examId,
    this.examTitle,
    this.status,

    this.totalQuestions,
    this.totalAnsweredQuestions,
    this.totalUnansweredQuestions,
    this.totalWrongAnswers,

    this.totalQuestionUnits,
    this.totalAnsweredQuestionUnits,
    this.totalUnansweredQuestionUnits,
    this.totalWrongAnswerUnits,

    this.updatedAt,
    this.meta,
  });

  // computed (question-level)
  int get computedTotalQuestions =>
      totalQuestions ??
          ((totalAnsweredQuestions ?? 0) + (totalUnansweredQuestions ?? 0));

  int get computedCorrectQuestions {
    final answered = totalAnsweredQuestions ?? 0;
    final wrong = totalWrongAnswers ?? 0;
    final c = answered - wrong;
    return c < 0 ? 0 : c;
  }

  // computed (unit-level)
  int get computedTotalQuestionUnits =>
      totalQuestionUnits ??
          ((totalAnsweredQuestionUnits ?? 0) + (totalUnansweredQuestionUnits ?? 0));

  int get computedCorrectQuestionUnits {
    final answered = totalAnsweredQuestionUnits ?? 0;
    final wrong = totalWrongAnswerUnits ?? 0;
    final c = answered - wrong;
    return c < 0 ? 0 : c;
  }

  factory WrongSkippedExamSummaryItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const WrongSkippedExamSummaryItem();

    return WrongSkippedExamSummaryItem(
      uid: _toStringOrNull(json['uid']),
      examType: _toStringOrNull(json['exam_type']),
      examTypeLabel: _toStringOrNull(json['exam_type_label']),
      examId: _toInt(json['exam_id']),
      examTitle: _toStringOrNull(json['exam_title']),
      status: _toStringOrNull(json['status']),

      // question-level
      totalQuestions: _toInt(json['total_questions']),
      totalAnsweredQuestions: _toInt(json['total_answered_questions']),
      totalUnansweredQuestions: _toInt(json['total_unanswered_questions']),
      totalWrongAnswers: _toInt(json['total_wrong_answers']),

      // unit-level
      totalQuestionUnits: _toInt(json['total_question_units']),
      totalAnsweredQuestionUnits: _toInt(json['total_answered_question_units']),
      totalUnansweredQuestionUnits: _toInt(json['total_unanswered_question_units']),
      totalWrongAnswerUnits: _toInt(json['total_wrong_answer_units']),

      updatedAt: _toStringOrNull(json['updated_at']),
      meta: _toMap(json['meta']),
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'exam_type': examType,
    'exam_type_label': examTypeLabel,
    'exam_id': examId,
    'exam_title': examTitle,
    'status': status,

    // question-level
    'total_questions': totalQuestions,
    'total_answered_questions': totalAnsweredQuestions,
    'total_unanswered_questions': totalUnansweredQuestions,
    'total_wrong_answers': totalWrongAnswers,

    // unit-level
    'total_question_units': totalQuestionUnits,
    'total_answered_question_units': totalAnsweredQuestionUnits,
    'total_unanswered_question_units': totalUnansweredQuestionUnits,
    'total_wrong_answer_units': totalWrongAnswerUnits,

    'updated_at': updatedAt,
    'meta': meta,
  };

  WrongSkippedExamSummaryItem copyWith({
    String? uid,
    String? examType,
    String? examTypeLabel,
    int? examId,
    String? examTitle,
    String? status,

    int? totalQuestions,
    int? totalAnsweredQuestions,
    int? totalUnansweredQuestions,
    int? totalWrongAnswers,

    int? totalQuestionUnits,
    int? totalAnsweredQuestionUnits,
    int? totalUnansweredQuestionUnits,
    int? totalWrongAnswerUnits,

    String? updatedAt,
    Map<String, dynamic>? meta,
  }) =>
      WrongSkippedExamSummaryItem(
        uid: uid ?? this.uid,
        examType: examType ?? this.examType,
        examTypeLabel: examTypeLabel ?? this.examTypeLabel,
        examId: examId ?? this.examId,
        examTitle: examTitle ?? this.examTitle,
        status: status ?? this.status,

        totalQuestions: totalQuestions ?? this.totalQuestions,
        totalAnsweredQuestions: totalAnsweredQuestions ?? this.totalAnsweredQuestions,
        totalUnansweredQuestions: totalUnansweredQuestions ?? this.totalUnansweredQuestions,
        totalWrongAnswers: totalWrongAnswers ?? this.totalWrongAnswers,

        totalQuestionUnits: totalQuestionUnits ?? this.totalQuestionUnits,
        totalAnsweredQuestionUnits:
        totalAnsweredQuestionUnits ?? this.totalAnsweredQuestionUnits,
        totalUnansweredQuestionUnits:
        totalUnansweredQuestionUnits ?? this.totalUnansweredQuestionUnits,
        totalWrongAnswerUnits: totalWrongAnswerUnits ?? this.totalWrongAnswerUnits,

        updatedAt: updatedAt ?? this.updatedAt,
        meta: meta ?? this.meta,
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

List<dynamic>? _toList(dynamic v) {
  if (v == null) return null;
  if (v is List) return v;
  return null;
}

Map<String, dynamic>? _toMap(dynamic v) {
  if (v == null) return null;
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
  return null;
}
