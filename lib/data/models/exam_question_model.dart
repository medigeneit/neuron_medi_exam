import 'dart:convert';

/// Convenience: decode from a raw JSON string.
ExamQuestionModel examQuestionModelFromJson(String source) =>
    ExamQuestionModel.fromJson(jsonDecode(source) as Map<String, dynamic>);

/// Convenience: encode to a raw JSON string.
String examQuestionModelToJson(ExamQuestionModel model) =>
    jsonEncode(model.toJson());

class ExamQuestionModel {
  final bool? runningExam;

  /// Backend sends this as MINUTES (e.g. 20).
  final int? duration;

  /// keyed by questionId when numeric
  final Map<int, SubmittedAnswer>? submittedAnswers;

  final int? totalNumberOfQuestion;
  final int? submittedNumberOfQuestions;
  final List<int>? checkAnswerSubmittedIds;
  final List<int>? partialAnsweredQuestionIds;
  final int? countPartialAnsweredQuestionIds;

  /// keyed by questionId when numeric
  final Map<int, Question>? questions;

  final ExamInfo? exam;

  const ExamQuestionModel({
    this.runningExam,
    this.duration,
    this.submittedAnswers,
    this.totalNumberOfQuestion,
    this.submittedNumberOfQuestions,
    this.checkAnswerSubmittedIds,
    this.partialAnsweredQuestionIds,
    this.countPartialAnsweredQuestionIds,
    this.questions,
    this.exam,
  });

  /// ✅ Convenience getters (no breaking changes)
  int get durationMinutes => duration ?? 0;

  /// If you need seconds for timers.
  int get durationSeconds => durationMinutes * 60;

  /// If you want a Dart Duration.
  Duration get durationAsDuration => Duration(minutes: durationMinutes);

  /// ✅ IMPORTANT: allows safe immutable updates from UI
  ExamQuestionModel copyWith({
    bool? runningExam,
    int? duration,
    Map<int, SubmittedAnswer>? submittedAnswers,
    int? totalNumberOfQuestion,
    int? submittedNumberOfQuestions,
    List<int>? checkAnswerSubmittedIds,
    List<int>? partialAnsweredQuestionIds,
    int? countPartialAnsweredQuestionIds,
    Map<int, Question>? questions,
    ExamInfo? exam,
  }) {
    return ExamQuestionModel(
      runningExam: runningExam ?? this.runningExam,
      duration: duration ?? this.duration,
      submittedAnswers: submittedAnswers ?? this.submittedAnswers,
      totalNumberOfQuestion: totalNumberOfQuestion ?? this.totalNumberOfQuestion,
      submittedNumberOfQuestions:
      submittedNumberOfQuestions ?? this.submittedNumberOfQuestions,
      checkAnswerSubmittedIds:
      checkAnswerSubmittedIds ?? this.checkAnswerSubmittedIds,
      partialAnsweredQuestionIds:
      partialAnsweredQuestionIds ?? this.partialAnsweredQuestionIds,
      countPartialAnsweredQuestionIds:
      countPartialAnsweredQuestionIds ?? this.countPartialAnsweredQuestionIds,
      questions: questions ?? this.questions,
      exam: exam ?? this.exam,
    );
  }

  factory ExamQuestionModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ExamQuestionModel();

    // Parse submitted_answers map (keys are strings like "4", "5")
    Map<int, SubmittedAnswer>? _submittedAnswers;
    final rawSubmitted = json['submitted_answers'];
    if (rawSubmitted is Map) {
      final out = <int, SubmittedAnswer>{};
      rawSubmitted.forEach((k, v) {
        final keyInt = JsonUtils.toIntSafe(k);
        final map = JsonUtils.toMapStringDynamic(v);
        if (keyInt != null && map != null) {
          out[keyInt] = SubmittedAnswer.fromJson(map, questionIdFromKey: keyInt);
        }
      });
      _submittedAnswers = out.isEmpty ? null : out;
    }

    // Parse questions map (keys are strings like "15", "14", etc.)
    Map<int, Question>? _questions;
    final rawQuestions = json['questions'];
    if (rawQuestions is Map) {
      final out = <int, Question>{};
      rawQuestions.forEach((k, v) {
        final keyInt = JsonUtils.toIntSafe(k);
        final map = JsonUtils.toMapStringDynamic(v);
        if (keyInt != null && map != null) {
          out[keyInt] = Question.fromJson(map);
        }
      });
      _questions = out.isEmpty ? null : out;
    }

    return ExamQuestionModel(
      runningExam: JsonUtils.toBool(json['running_exam']),
      // duration from backend is MINUTES (keep as-is)
      duration: JsonUtils.toInt(json['duration']),
      submittedAnswers: _submittedAnswers,
      totalNumberOfQuestion: JsonUtils.toInt(json['total_number_of_question']),
      submittedNumberOfQuestions:
      JsonUtils.toInt(json['submitted_number_of_questions']),
      checkAnswerSubmittedIds:
      JsonUtils.toIntList(json['check_answer_submitted_ids']),
      partialAnsweredQuestionIds:
      JsonUtils.toIntList(json['partial_answered_question_ids']),
      countPartialAnsweredQuestionIds:
      JsonUtils.toInt(json['count_partial_answered_question_ids']),
      questions: _questions,
      exam: ExamInfo.fromJson(
        JsonUtils.toMapStringDynamic(json['exam']),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'running_exam': runningExam,
    // keep sending minutes
    'duration': duration,
    'submitted_answers': submittedAnswers == null
        ? null
        : submittedAnswers!.map((k, v) => MapEntry(
      k.toString(),
      v.toJson(),
    )),
    'total_number_of_question': totalNumberOfQuestion,
    'submitted_number_of_questions': submittedNumberOfQuestions,
    'check_answer_submitted_ids': checkAnswerSubmittedIds,
    'partial_answered_question_ids': partialAnsweredQuestionIds,
    'count_partial_answered_question_ids': countPartialAnsweredQuestionIds,
    'questions': questions == null
        ? null
        : questions!.map((k, v) => MapEntry(k.toString(), v.toJson())),
    'exam': exam?.toJson(),
  };
}

class ExamInfo {
  final int? id;
  final String? title;
  final int? status;

  const ExamInfo({this.id, this.title, this.status});

  ExamInfo copyWith({
    int? id,
    String? title,
    int? status,
  }) {
    return ExamInfo(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
    );
  }

  factory ExamInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ExamInfo();
    return ExamInfo(
      id: JsonUtils.toInt(json['id']),
      title: JsonUtils.toStringOrNull(json['title']),
      status: JsonUtils.toInt(json['status']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'status': status,
  };
}

/// Generic exam question (works for both MCQ & SBA).
class Question {
  final int? questionId;
  final int? examQuestionId;
  final int? questionTypeId; // 1 = MCQ, 2 = SBA
  final String? questionType; // "MCQ" / "SBA"
  final int? numberOfOptions; // usually 5
  final String? questionTitle;
  final List<QuestionOption>? questionOption;

  const Question({
    this.questionId,
    this.examQuestionId,
    this.questionTypeId,
    this.questionType,
    this.numberOfOptions,
    this.questionTitle,
    this.questionOption,
  });

  bool get isMCQ =>
      (questionTypeId == 1) || (questionType?.toUpperCase() == 'MCQ');

  bool get isSBA =>
      (questionTypeId == 2) || (questionType?.toUpperCase() == 'SBA');

  Question copyWith({
    int? questionId,
    int? examQuestionId,
    int? questionTypeId,
    String? questionType,
    int? numberOfOptions,
    String? questionTitle,
    List<QuestionOption>? questionOption,
  }) {
    return Question(
      questionId: questionId ?? this.questionId,
      examQuestionId: examQuestionId ?? this.examQuestionId,
      questionTypeId: questionTypeId ?? this.questionTypeId,
      questionType: questionType ?? this.questionType,
      numberOfOptions: numberOfOptions ?? this.numberOfOptions,
      questionTitle: questionTitle ?? this.questionTitle,
      questionOption: questionOption ?? this.questionOption,
    );
  }

  factory Question.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const Question();

    final optsRaw = json['question_option'];
    List<QuestionOption>? options;
    if (optsRaw is List) {
      options = optsRaw
          .map(JsonUtils.toMapStringDynamic)
          .whereType<Map<String, dynamic>>()
          .map(QuestionOption.fromJson)
          .toList();
      if (options.isEmpty) options = null;
    }

    return Question(
      questionId: JsonUtils.toInt(json['question_id']),
      examQuestionId: JsonUtils.toInt(json['exam_question_id']),
      questionTypeId: JsonUtils.toInt(json['question_type_id']),
      questionType: JsonUtils.toStringOrNull(json['question_type']),
      numberOfOptions: JsonUtils.toInt(json['number_of_options']),
      questionTitle: JsonUtils.toStringOrNull(json['question_title']),
      questionOption: options,
    );
  }

  Map<String, dynamic> toJson() => {
    'question_id': questionId,
    'exam_question_id': examQuestionId,
    'question_type_id': questionTypeId,
    'question_type': questionType,
    'number_of_options': numberOfOptions,
    'question_title': questionTitle,
    'question_option': questionOption?.map((e) => e.toJson()).toList(),
  };
}

class QuestionOption {
  final String? serial; // "A".."E"
  final String? title;

  const QuestionOption({this.serial, this.title});

  QuestionOption copyWith({
    String? serial,
    String? title,
  }) {
    return QuestionOption(
      serial: serial ?? this.serial,
      title: title ?? this.title,
    );
  }

  factory QuestionOption.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const QuestionOption();
    return QuestionOption(
      serial: JsonUtils.toStringOrNull(json['serial']),
      title: JsonUtils.toStringOrNull(json['title']),
    );
  }

  Map<String, dynamic> toJson() => {
    'serial': serial,
    'title': title,
  };
}

/// A user's submitted answer for any question.
/// For MCQ, `answer` is like "TFFTT" or "TT..F".
/// For SBA, `answer` is one of "A".."E".
class SubmittedAnswer {
  final int? questionIdFromKey; // the map key, if numeric (e.g., 4, 5, 27)
  final int? examQuestionId; // e.g., 27, 26...
  final String? answer; // raw answer string
  final int? questionTypeId; // 1 (MCQ) / 2 (SBA)

  const SubmittedAnswer({
    this.questionIdFromKey,
    this.examQuestionId,
    this.answer,
    this.questionTypeId,
  });

  bool get isMCQ => questionTypeId == 1;
  bool get isSBA => questionTypeId == 2;

  List<bool?>? get mcqStates => isMCQ ? MCQAnswer.parse(answer) : null;
  int? get sbaIndex => isSBA ? SBAAnswer.indexFromLetter(answer) : null;

  factory SubmittedAnswer.fromJson(
      Map<String, dynamic>? json, {
        int? questionIdFromKey,
      }) {
    if (json == null) return const SubmittedAnswer();
    return SubmittedAnswer(
      questionIdFromKey: questionIdFromKey,
      examQuestionId: JsonUtils.toInt(json['exam_question_id']),
      answer: JsonUtils.toStringOrNull(json['answer']),
      questionTypeId: JsonUtils.toInt(json['question_type_id']),
    );
  }

  Map<String, dynamic> toJson() => {
    'exam_question_id': examQuestionId,
    'answer': answer,
    'question_type_id': questionTypeId,
  };

  SubmittedAnswer copyWith({
    int? questionIdFromKey,
    int? examQuestionId,
    String? answer,
    int? questionTypeId,
  }) {
    return SubmittedAnswer(
      questionIdFromKey: questionIdFromKey ?? this.questionIdFromKey,
      examQuestionId: examQuestionId ?? this.examQuestionId,
      answer: answer ?? this.answer,
      questionTypeId: questionTypeId ?? this.questionTypeId,
    );
  }
}

/// Helpers for MCQ style "TFFTT" / "TT..F" answers.
class MCQAnswer {
  /// Parse a 5-character answer string into a List<bool?> of length 5.
  /// - 'T' -> true
  /// - 'F' -> false
  /// - '.' or anything else -> null
  /// Missing or shorter strings are padded with nulls.
  static List<bool?> parse(String? input) {
    const length = 5;
    final result = List<bool?>.filled(length, null, growable: false);
    if (input == null || input.isEmpty) return result;

    for (var i = 0; i < length && i < input.length; i++) {
      final ch = input[i].toUpperCase();
      if (ch == 'T') {
        result[i] = true;
      } else if (ch == 'F') {
        result[i] = false;
      } else {
        result[i] = null;
      }
    }
    return result;
  }

  /// Build a 5-character MCQ answer string from states.
  /// null -> '.' ; true -> 'T' ; false -> 'F'.
  static String build(List<bool?>? states) {
    if (states == null || states.isEmpty) return '.....';
    final out = StringBuffer();
    for (var i = 0; i < 5; i++) {
      final v = i < states.length ? states[i] : null;
      if (v == null) {
        out.write('.');
      } else {
        out.write(v ? 'T' : 'F');
      }
    }
    return out.toString();
  }
}

/// Helpers for SBA style single-letter answers ("A".."E").
class SBAAnswer {
  /// Returns 0..4 for 'A'..'E' (case-insensitive). Otherwise null.
  static int? indexFromLetter(String? input) {
    if (input == null || input.isEmpty) return null;
    final c = input.trim().toUpperCase();
    if (c.length != 1) return null;
    final code = c.codeUnitAt(0) - 'A'.codeUnitAt(0);
    if (code < 0 || code > 4) return null;
    return code;
  }

  /// Convert 0..4 back to 'A'..'E'. Returns null if out of range.
  static String? letterFromIndex(int? index) {
    if (index == null || index < 0 || index > 4) return null;
    return String.fromCharCode('A'.codeUnitAt(0) + index);
  }
}

/// Safe, forgiving JSON conversions.
class JsonUtils {
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
      final trimmed = v.trim();
      if (trimmed.isEmpty) return null;
      return int.tryParse(trimmed);
    }
    return null;
  }

  /// More tolerant: attempts to parse non-primitive keys too.
  static int? toIntSafe(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    final s = v.toString();
    if (s.isEmpty) return null;
    return int.tryParse(s);
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
    final single = toInt(v);
    if (single != null) return [single];
    return null;
  }

  static List<String>? toStringList(dynamic v) {
    if (v == null) return null;
    if (v is List) {
      final list = <String>[];
      for (final e in v) {
        final s = toStringOrNull(e);
        if (s != null) list.add(s);
      }
      return list.isEmpty ? null : list;
    }
    final single = toStringOrNull(v);
    if (single != null) return [single];
    return null;
  }

  /// ✅ Safe map conversion (handles Map<dynamic, dynamic> too)
  static Map<String, dynamic>? toMapStringDynamic(dynamic v) {
    if (v == null) return null;
    if (v is Map<String, dynamic>) return v;
    if (v is Map) {
      return v.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }
}
