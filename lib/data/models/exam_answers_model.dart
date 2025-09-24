// lib/data/models/exam_answers_model.dart
import 'dart:convert';

/// ------------------------------
/// Top-level helpers
/// ------------------------------

/// If your endpoint returns a raw JSON array, use this.
/// Example: final items = examAnswersFromJson(jsonString);
List<ExamAnswerItem> examAnswersFromJson(String source) {
  final decoded = jsonDecode(source);
  return ExamAnswersModel.fromAny(decoded).items ?? const <ExamAnswerItem>[];
}

/// If you want a wrapper model (flexible for future),
/// use this: final model = ExamAnswersModel.fromAny(jsonDecode(...));
class ExamAnswersModel {
  final List<ExamAnswerItem>? items;

  const ExamAnswersModel({this.items});

  /// Accepts:
  /// - List<dynamic>  (your sample)
  /// - { "answers": [...] } or { "data": [...] }
  /// - null / anything else -> empty
  factory ExamAnswersModel.fromAny(dynamic json) {
    if (json is List) {
      return ExamAnswersModel(
        items: json
            .whereType<Map<String, dynamic>>()
            .map(ExamAnswerItem.fromJson)
            .toList(),
      );
    }
    if (json is Map<String, dynamic>) {
      final list =
          (json['answers'] ?? json['data']) as List<dynamic>? ?? const [];
      return ExamAnswersModel(
        items: list
            .whereType<Map<String, dynamic>>()
            .map(ExamAnswerItem.fromJson)
            .toList(),
      );
    }
    return const ExamAnswersModel(items: []);
  }

  Map<String, dynamic> toJson() => {
    'answers': items?.map((e) => e.toJson()).toList(),
  };

  String toRawJson() => jsonEncode(toJson());
}

/// ------------------------------
/// Single answer item
/// ------------------------------
class ExamAnswerItem {
  final int? questionId;
  final int? examQuestionId;
  final int? questionTypeId; // 1 = MCQ, 2 = SBA
  final String? questionType; // "MCQ" / "SBA"
  final int? numberOfOptions; // usually 5
  final String? questionTitle;
  final List<AnswerOption>? questionOption;

  /// Official answer from server.
  /// MCQ: "TFTFT" ; SBA: "A".."E"
  final String? answerScript;

  /// Doctor/user answer.
  /// MCQ: e.g. "TT..F" ('.' = blank)
  /// SBA: single letter or "." if blank
  final String? doctorAnswer;

  const ExamAnswerItem({
    this.questionId,
    this.examQuestionId,
    this.questionTypeId,
    this.questionType,
    this.numberOfOptions,
    this.questionTitle,
    this.questionOption,
    this.answerScript,
    this.doctorAnswer,
  });

  /// -------- Convenience flags --------
  bool get isMCQ =>
      (questionTypeId == 1) || (questionType?.trim().toUpperCase() == 'MCQ');

  bool get isSBA =>
      (questionTypeId == 2) || (questionType?.trim().toUpperCase() == 'SBA');

  /// -------- Parsed states (MCQ) --------
  /// List<bool?> of length 5:
  /// - true  => 'T'
  /// - false => 'F'
  /// - null  => '.' or missing
  List<bool?>? get correctStates =>
      isMCQ ? AnswersMCQHelper.parse(answerScript) : null;

  List<bool?>? get doctorStates =>
      isMCQ ? AnswersMCQHelper.parse(doctorAnswer) : null;

  /// Per-statement match for MCQ (true/false/null=unknown)
  /// If either side is null for a position, result is null.
  List<bool?>? get mcqMatches {
    if (!isMCQ) return null;
    final a = correctStates ?? const [null, null, null, null, null];
    final b = doctorStates ?? const [null, null, null, null, null];
    final out = <bool?>[];
    for (var i = 0; i < 5; i++) {
      final x = i < a.length ? a[i] : null;
      final y = i < b.length ? b[i] : null;
      if (x == null || y == null) {
        out.add(null); // cannot evaluate
      } else {
        out.add(x == y);
      }
    }
    return out;
  }

  /// -------- Parsed choice (SBA) --------
  int? get correctSbaIndex =>
      isSBA ? AnswersSBAHelper.indexFromLetter(answerScript) : null;

  int? get doctorSbaIndex =>
      isSBA ? AnswersSBAHelper.indexFromLetter(doctorAnswer) : null;

  /// SBA overall correctness (null if unknown)
  bool? get sbaIsCorrect {
    if (!isSBA) return null;
    final c = correctSbaIndex;
    final d = doctorSbaIndex;
    if (c == null || d == null) return null;
    return c == d;
  }

  factory ExamAnswerItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ExamAnswerItem();

    List<AnswerOption>? options;
    final rawOpts = json['question_option'];
    if (rawOpts is List) {
      options = rawOpts
          .whereType<Map<String, dynamic>>()
          .map(AnswerOption.fromJson)
          .toList();
      if (options.isEmpty) options = null;
    }

    return ExamAnswerItem(
      questionId: AnswerJsonUtils.toInt(json['question_id']),
      examQuestionId: AnswerJsonUtils.toInt(json['exam_question_id']),
      questionTypeId: AnswerJsonUtils.toInt(json['question_type_id']),
      questionType: AnswerJsonUtils.toStringOrNull(json['question_type']),
      numberOfOptions: AnswerJsonUtils.toInt(json['number_of_options']),
      questionTitle: AnswerJsonUtils.toStringOrNull(json['question_title']),
      questionOption: options,
      answerScript: AnswerJsonUtils.toStringOrNull(json['answer_script']),
      doctorAnswer: AnswerJsonUtils.toStringOrNull(json['doctor_answer']),
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
    'answer_script': answerScript,
    'doctor_answer': doctorAnswer,
  };

  ExamAnswerItem copyWith({
    int? questionId,
    int? examQuestionId,
    int? questionTypeId,
    String? questionType,
    int? numberOfOptions,
    String? questionTitle,
    List<AnswerOption>? questionOption,
    String? answerScript,
    String? doctorAnswer,
  }) {
    return ExamAnswerItem(
      questionId: questionId ?? this.questionId,
      examQuestionId: examQuestionId ?? this.examQuestionId,
      questionTypeId: questionTypeId ?? this.questionTypeId,
      questionType: questionType ?? this.questionType,
      numberOfOptions: numberOfOptions ?? this.numberOfOptions,
      questionTitle: questionTitle ?? this.questionTitle,
      questionOption: questionOption ?? this.questionOption,
      answerScript: answerScript ?? this.answerScript,
      doctorAnswer: doctorAnswer ?? this.doctorAnswer,
    );
  }
}

/// ------------------------------
/// Options (A..E)
/// ------------------------------
class AnswerOption {
  final String? serial; // "A".."E"
  final String? title;

  const AnswerOption({this.serial, this.title});

  factory AnswerOption.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AnswerOption();
    return AnswerOption(
      serial: AnswerJsonUtils.toStringOrNull(json['serial']),
      title: AnswerJsonUtils.toStringOrNull(json['title']),
    );
    // NOTE: If you later add isCorrect flags, extend here safely.
  }

  Map<String, dynamic> toJson() => {
    'serial': serial,
    'title': title,
  };
}

/// ------------------------------
/// MCQ/SBA parsing helpers (namespaced to avoid collisions)
/// ------------------------------
class AnswersMCQHelper {
  /// Parse a 5-char string like "TFTTF" or "TT..F" to List<bool?> length 5.
  static List<bool?> parse(String? input) {
    const len = 5;
    final out = List<bool?>.filled(len, null, growable: false);
    if (input == null || input.isEmpty) return out;

    for (var i = 0; i < len && i < input.length; i++) {
      final ch = input[i].toUpperCase();
      if (ch == 'T') out[i] = true;
      else if (ch == 'F') out[i] = false;
      else out[i] = null; // '.', space, etc.
    }
    return out;
  }

  /// Build "T/F/."*5 string from states.
  static String build(List<bool?>? states) {
    if (states == null || states.isEmpty) return '.....';
    final buf = StringBuffer();
    for (var i = 0; i < 5; i++) {
      final v = i < states.length ? states[i] : null;
      if (v == null) buf.write('.');
      else buf.write(v ? 'T' : 'F');
    }
    return buf.toString();
  }
}

class AnswersSBAHelper {
  /// 'A'..'E' -> 0..4; returns null if invalid/blank
  static int? indexFromLetter(String? input) {
    if (input == null || input.isEmpty) return null;
    final c = input.trim().toUpperCase();
    if (c.length != 1) return null;
    final code = c.codeUnitAt(0) - 'A'.codeUnitAt(0);
    if (code < 0 || code > 4) return null;
    return code;
  }

  /// 0..4 -> 'A'..'E'; null if out of range
  static String? letterFromIndex(int? index) {
    if (index == null || index < 0 || index > 4) return null;
    return String.fromCharCode('A'.codeUnitAt(0) + index);
  }
}

/// ------------------------------
/// Null-safe, forgiving converters
/// (Renamed to avoid conflicts with other models)
/// ------------------------------
class AnswerJsonUtils {
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
}
