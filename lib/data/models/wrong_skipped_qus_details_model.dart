// lib/data/models/wrong_skipped_qus_details_model.dart
import 'dart:convert';

class WrongSkippedQusDetailsModel {
  final String? examType;
  final int? examId;
  final String? examTitle;
  final String? status;
  final String? updatedAt;

  // Question counts
  final int? totalQuestions;
  final int? totalAnsweredQuestions;
  final int? totalUnansweredQuestions;
  final int? totalWrongAnswers;

  // Unit (stem) counts
  final int? totalQuestionUnits;
  final int? totalAnsweredQuestionUnits;
  final int? totalUnansweredQuestionUnits;
  final int? totalWrongAnswerUnits;

  final List<WrongSkippedQuestionAttempt>? wrongQuestions;
  final List<WrongSkippedQuestionAttempt>? unansweredQuestions;

  const WrongSkippedQusDetailsModel({
    this.examType,
    this.examId,
    this.examTitle,
    this.status,
    this.updatedAt,
    this.totalQuestions,
    this.totalAnsweredQuestions,
    this.totalUnansweredQuestions,
    this.totalWrongAnswers,
    this.totalQuestionUnits,
    this.totalAnsweredQuestionUnits,
    this.totalUnansweredQuestionUnits,
    this.totalWrongAnswerUnits,
    this.wrongQuestions,
    this.unansweredQuestions,
  });

  // Fallback totals
  int get computedTotalQuestions =>
      totalQuestions ??
          ((totalAnsweredQuestions ?? 0) + (totalUnansweredQuestions ?? 0));

  int get computedTotalUnits =>
      totalQuestionUnits ??
          ((totalAnsweredQuestionUnits ?? 0) + (totalUnansweredQuestionUnits ?? 0));

  factory WrongSkippedQusDetailsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const WrongSkippedQusDetailsModel();

    return WrongSkippedQusDetailsModel(
      examType: _toStringOrNull(json['exam_type']),
      examId: _toInt(json['exam_id']),
      examTitle: _toStringOrNull(json['exam_title']),
      status: _toStringOrNull(json['status']),
      updatedAt: _toStringOrNull(json['updated_at']),

      totalQuestions: _toInt(json['total_questions']),
      totalAnsweredQuestions: _toInt(json['total_answered_questions']),
      totalUnansweredQuestions: _toInt(json['total_unanswered_questions']),
      totalWrongAnswers: _toInt(json['total_wrong_answers']),

      totalQuestionUnits: _toInt(json['total_question_units']),
      totalAnsweredQuestionUnits: _toInt(json['total_answered_question_units']),
      totalUnansweredQuestionUnits: _toInt(json['total_unanswered_question_units']),
      totalWrongAnswerUnits: _toInt(json['total_wrong_answer_units']),

      wrongQuestions: _toList(json['wrong_questions'])
          ?.map((e) => e is Map<String, dynamic>
          ? WrongSkippedQuestionAttempt.fromJson(e)
          : const WrongSkippedQuestionAttempt())
          .toList(),

      unansweredQuestions: _toList(json['unanswered_questions'])
          ?.map((e) => e is Map<String, dynamic>
          ? WrongSkippedQuestionAttempt.fromJson(e)
          : const WrongSkippedQuestionAttempt())
          .toList(),
    );
  }

  /// Accepts either a Map or a JSON string.
  factory WrongSkippedQusDetailsModel.parse(dynamic source) {
    if (source == null) return const WrongSkippedQusDetailsModel();

    if (source is Map<String, dynamic>) {
      return WrongSkippedQusDetailsModel.fromJson(source);
    }

    if (source is String && source.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(source);
        if (decoded is Map<String, dynamic>) {
          return WrongSkippedQusDetailsModel.fromJson(decoded);
        }
      } catch (_) {}
    }

    return const WrongSkippedQusDetailsModel();
  }

  Map<String, dynamic> toJson() => {
    'exam_type': examType,
    'exam_id': examId,
    'exam_title': examTitle,
    'status': status,
    'updated_at': updatedAt,
    'total_questions': totalQuestions,
    'total_answered_questions': totalAnsweredQuestions,
    'total_unanswered_questions': totalUnansweredQuestions,
    'total_wrong_answers': totalWrongAnswers,
    'total_question_units': totalQuestionUnits,
    'total_answered_question_units': totalAnsweredQuestionUnits,
    'total_unanswered_question_units': totalUnansweredQuestionUnits,
    'total_wrong_answer_units': totalWrongAnswerUnits,
    'wrong_questions': wrongQuestions?.map((e) => e.toJson()).toList(),
    'unanswered_questions': unansweredQuestions?.map((e) => e.toJson()).toList(),
  };

  WrongSkippedQusDetailsModel copyWith({
    String? examType,
    int? examId,
    String? examTitle,
    String? status,
    String? updatedAt,
    int? totalQuestions,
    int? totalAnsweredQuestions,
    int? totalUnansweredQuestions,
    int? totalWrongAnswers,
    int? totalQuestionUnits,
    int? totalAnsweredQuestionUnits,
    int? totalUnansweredQuestionUnits,
    int? totalWrongAnswerUnits,
    List<WrongSkippedQuestionAttempt>? wrongQuestions,
    List<WrongSkippedQuestionAttempt>? unansweredQuestions,
  }) =>
      WrongSkippedQusDetailsModel(
        examType: examType ?? this.examType,
        examId: examId ?? this.examId,
        examTitle: examTitle ?? this.examTitle,
        status: status ?? this.status,
        updatedAt: updatedAt ?? this.updatedAt,
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
        wrongQuestions: wrongQuestions ?? this.wrongQuestions,
        unansweredQuestions: unansweredQuestions ?? this.unansweredQuestions,
      );
}

class WrongSkippedQuestionAttempt {
  final WrongSkippedQuestion? question;

  /// For MCQ type: stems array will exist.
  final List<WrongSkippedStem>? stems;

  /// For SBA wrong: given_answer/correct_answer exist.
  /// For SBA unanswered: only correct_answer exists.
  final String? givenAnswer;
  final String? correctAnswer;

  /// For SBA: the option strings are provided
  final String? givenOption;
  final String? correctOption;

  const WrongSkippedQuestionAttempt({
    this.question,
    this.stems,
    this.givenAnswer,
    this.correctAnswer,
    this.givenOption,
    this.correctOption,
  });

  bool get isMcq =>
      (question?.questionTypeId == 1) || ((stems?.isNotEmpty ?? false) == true);

  bool get isSba =>
      (question?.questionTypeId == 2) || ((question?.options?.isNotEmpty ?? false) == true);

  factory WrongSkippedQuestionAttempt.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const WrongSkippedQuestionAttempt();

    return WrongSkippedQuestionAttempt(
      question: json['question'] is Map<String, dynamic>
          ? WrongSkippedQuestion.fromJson(json['question'])
          : null,
      stems: _toList(json['stems'])
          ?.map((e) => e is Map<String, dynamic>
          ? WrongSkippedStem.fromJson(e)
          : const WrongSkippedStem())
          .toList(),
      givenAnswer: _toStringOrNull(json['given_answer']),
      correctAnswer: _toStringOrNull(json['correct_answer']),
      givenOption: _toStringOrNull(json['given_option']),
      correctOption: _toStringOrNull(json['correct_option']),
    );
  }

  Map<String, dynamic> toJson() => {
    'question': question?.toJson(),
    'stems': stems?.map((e) => e.toJson()).toList(),
    'given_answer': givenAnswer,
    'correct_answer': correctAnswer,
    'given_option': givenOption,
    'correct_option': correctOption,
  };

  WrongSkippedQuestionAttempt copyWith({
    WrongSkippedQuestion? question,
    List<WrongSkippedStem>? stems,
    String? givenAnswer,
    String? correctAnswer,
    String? givenOption,
    String? correctOption,
  }) =>
      WrongSkippedQuestionAttempt(
        question: question ?? this.question,
        stems: stems ?? this.stems,
        givenAnswer: givenAnswer ?? this.givenAnswer,
        correctAnswer: correctAnswer ?? this.correctAnswer,
        givenOption: givenOption ?? this.givenOption,
        correctOption: correctOption ?? this.correctOption,
      );
}

class WrongSkippedQuestion {
  final int? id;
  final int? topicId;
  final int? questionTypeId; // 1=MCQ, 2=SBA
  final String? title;

  /// Only for SBA: "options": {"A": "...", "B": "..."}
  final Map<String, String>? options;

  const WrongSkippedQuestion({
    this.id,
    this.topicId,
    this.questionTypeId,
    this.title,
    this.options,
  });

  factory WrongSkippedQuestion.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const WrongSkippedQuestion();

    return WrongSkippedQuestion(
      id: _toInt(json['id']),
      topicId: _toInt(json['topic_id']),
      questionTypeId: _toInt(json['question_type_id']),
      title: _toStringOrNull(json['title']),
      options: _toStringMap(json['options']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'topic_id': topicId,
    'question_type_id': questionTypeId,
    'title': title,
    'options': options,
  };

  WrongSkippedQuestion copyWith({
    int? id,
    int? topicId,
    int? questionTypeId,
    String? title,
    Map<String, String>? options,
  }) =>
      WrongSkippedQuestion(
        id: id ?? this.id,
        topicId: topicId ?? this.topicId,
        questionTypeId: questionTypeId ?? this.questionTypeId,
        title: title ?? this.title,
        options: options ?? this.options,
      );
}

class WrongSkippedStem {
  final int? stemIndex;
  final int? stemNo;
  final String? optionTitle;

  /// For wrong MCQ: both exist. For unanswered MCQ: only correct exists.
  final String? givenAnswer;
  final String? correctAnswer;

  const WrongSkippedStem({
    this.stemIndex,
    this.stemNo,
    this.optionTitle,
    this.givenAnswer,
    this.correctAnswer,
  });

  factory WrongSkippedStem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const WrongSkippedStem();

    return WrongSkippedStem(
      stemIndex: _toInt(json['stem_index']),
      stemNo: _toInt(json['stem_no']),
      optionTitle: _toStringOrNull(json['option_title']),
      givenAnswer: _toStringOrNull(json['given_answer']),
      correctAnswer: _toStringOrNull(json['correct_answer']),
    );
  }

  Map<String, dynamic> toJson() => {
    'stem_index': stemIndex,
    'stem_no': stemNo,
    'option_title': optionTitle,
    'given_answer': givenAnswer,
    'correct_answer': correctAnswer,
  };

  WrongSkippedStem copyWith({
    int? stemIndex,
    int? stemNo,
    String? optionTitle,
    String? givenAnswer,
    String? correctAnswer,
  }) =>
      WrongSkippedStem(
        stemIndex: stemIndex ?? this.stemIndex,
        stemNo: stemNo ?? this.stemNo,
        optionTitle: optionTitle ?? this.optionTitle,
        givenAnswer: givenAnswer ?? this.givenAnswer,
        correctAnswer: correctAnswer ?? this.correctAnswer,
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

Map<String, String>? _toStringMap(dynamic v) {
  if (v == null) return null;
  if (v is Map) {
    final out = <String, String>{};
    v.forEach((k, val) {
      final key = k.toString().trim();
      final value = (val == null) ? '' : val.toString();
      if (key.isNotEmpty) out[key] = value;
    });
    return out.isEmpty ? null : out;
  }
  return null;
}
