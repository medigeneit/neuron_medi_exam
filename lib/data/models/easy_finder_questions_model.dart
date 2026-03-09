// lib/data/models/easy_finder_questions_model.dart
import 'dart:convert';

EasyFinderQuestionsModel easyFinderQuestionsModelFromRawJson(String source) {
  final decoded = jsonDecode(source);
  return EasyFinderQuestionsModel.fromAny(decoded);
}

class EasyFinderQuestionsModel {
  final List<EasyFinderQuestionItem>? items;
  final EasyFinderMeta? meta;

  const EasyFinderQuestionsModel({
    this.items,
    this.meta,
  });

  factory EasyFinderQuestionsModel.fromAny(dynamic json) {
    // If API returns a raw list
    if (json is List) {
      return EasyFinderQuestionsModel(
        items: json
            .whereType<Map<String, dynamic>>()
            .map(EasyFinderQuestionItem.fromJson)
            .toList(),
        meta: null,
      );
    }

    // If API returns wrapped map: { data: [...], meta: {...} }
    if (json is Map<String, dynamic>) {
      final list = (json['data'] ?? json['items']) as List<dynamic>? ?? const [];
      final metaRaw = json['meta'];

      return EasyFinderQuestionsModel(
        items: list
            .whereType<Map<String, dynamic>>()
            .map(EasyFinderQuestionItem.fromJson)
            .toList(),
        meta: metaRaw is Map<String, dynamic>
            ? EasyFinderMeta.fromJson(metaRaw)
            : null,
      );
    }

    return const EasyFinderQuestionsModel(items: [], meta: null);
  }

  Map<String, dynamic> toJson() => {
    'data': items?.map((e) => e.toJson()).toList(),
    'meta': meta?.toJson(),
  };

  String toRawJson() => jsonEncode(toJson());
}

/// ------------------------------------------------------------
/// Single Question Item
/// ------------------------------------------------------------
class EasyFinderQuestionItem {
  final int? id;

  final int? questionTypeId; // 1=MCQ, 2=SBA
  final String? questionType; // "MCQ"/"SBA"

  final String? title;
  final List<EasyFinderOption>? options;

  /// SBA: "A".."E"
  /// MCQ: "TFTFF" etc
  final String? correctAns;

  final EasyFinderMiniRef? topic;
  final EasyFinderMiniRef? chapter;
  final EasyFinderMiniRef? subject;

  const EasyFinderQuestionItem({
    this.id,
    this.questionTypeId,
    this.questionType,
    this.title,
    this.options,
    this.correctAns,
    this.topic,
    this.chapter,
    this.subject,
  });

  bool get isMCQ =>
      (questionTypeId == 1) || (questionType?.trim().toUpperCase() == 'MCQ');

  bool get isSBA =>
      (questionTypeId == 2) || (questionType?.trim().toUpperCase() == 'SBA');

  String get safeTitle => (title ?? '').trim();

  String get safeQuestionType => (questionType ?? '').trim();

  int get safeId => id ?? 0;

  List<EasyFinderOption> get safeOptions => options ?? const <EasyFinderOption>[];

  /// MCQ helper: parse "TFTFF" to [true,false,true,false,false] with null for invalid chars
  List<bool?>? get correctMcqStates =>
      isMCQ ? EasyFinderMCQHelper.parse(correctAns) : null;

  /// SBA helper: "A".."E" -> 0..4
  int? get correctSbaIndex =>
      isSBA ? EasyFinderSBAHelper.indexFromLetter(correctAns) : null;

  String? get correctSbaLetter =>
      isSBA ? (correctAns?.trim().toUpperCase()) : null;

  factory EasyFinderQuestionItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const EasyFinderQuestionItem();

    List<EasyFinderOption>? opts;
    final rawOpts = json['options'];
    if (rawOpts is List) {
      opts = rawOpts
          .whereType<Map<String, dynamic>>()
          .map(EasyFinderOption.fromJson)
          .toList();
      if (opts.isEmpty) opts = null;
    }

    return EasyFinderQuestionItem(
      id: EasyFinderJsonUtils.toInt(json['id']),
      questionTypeId: EasyFinderJsonUtils.toInt(json['question_type_id']),
      questionType: EasyFinderJsonUtils.toStringOrNull(json['question_type']),
      title: EasyFinderJsonUtils.toStringOrNull(json['title']),
      options: opts,
      correctAns: EasyFinderJsonUtils.toStringOrNull(json['correct_ans']),
      topic: EasyFinderMiniRef.fromAny(json['topic']),
      chapter: EasyFinderMiniRef.fromAny(json['chapter']),
      subject: EasyFinderMiniRef.fromAny(json['subject']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'question_type_id': questionTypeId,
    'question_type': questionType,
    'title': title,
    'options': options?.map((e) => e.toJson()).toList(),
    'correct_ans': correctAns,
    'topic': topic?.toJson(),
    'chapter': chapter?.toJson(),
    'subject': subject?.toJson(),
  };
}

/// ------------------------------------------------------------
/// Option (A..E)
/// ------------------------------------------------------------
class EasyFinderOption {
  final String? serial; // "A".."E"
  final String? title;

  const EasyFinderOption({this.serial, this.title});

  String get safeSerial => (serial ?? '').trim();
  String get safeTitle => (title ?? '').trim();

  factory EasyFinderOption.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const EasyFinderOption();
    return EasyFinderOption(
      serial: EasyFinderJsonUtils.toStringOrNull(json['serial']),
      title: EasyFinderJsonUtils.toStringOrNull(json['title']),
    );
  }

  Map<String, dynamic> toJson() => {
    'serial': serial,
    'title': title,
  };
}

/// ------------------------------------------------------------
/// Mini reference model for topic/chapter/subject
/// { id: 1, name: "Anatomy" }
/// ------------------------------------------------------------
class EasyFinderMiniRef {
  final int? id;
  final String? name;

  const EasyFinderMiniRef({this.id, this.name});

  int get safeId => id ?? 0;
  String get safeName => (name ?? '').trim();

  factory EasyFinderMiniRef.fromAny(dynamic json) {
    if (json is Map<String, dynamic>) {
      return EasyFinderMiniRef(
        id: EasyFinderJsonUtils.toInt(json['id']),
        name: EasyFinderJsonUtils.toStringOrNull(json['name']),
      );
    }
    return const EasyFinderMiniRef();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

/// ------------------------------------------------------------
/// Meta
/// { q: "nerve", per_page: 20, ... }
/// ------------------------------------------------------------
class EasyFinderMeta {
  final String? q;
  final int? perPage;

  /// keep extra keys safely (future proof)
  final Map<String, dynamic>? extra;

  const EasyFinderMeta({
    this.q,
    this.perPage,
    this.extra,
  });

  String get safeQuery => (q ?? '').trim();
  int get safePerPage => perPage ?? 0;

  factory EasyFinderMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const EasyFinderMeta();

    final known = <String, dynamic>{};
    final extra = <String, dynamic>{};

    for (final e in json.entries) {
      if (e.key == 'q' || e.key == 'per_page') {
        known[e.key] = e.value;
      } else {
        extra[e.key] = e.value;
      }
    }

    return EasyFinderMeta(
      q: EasyFinderJsonUtils.toStringOrNull(known['q']),
      perPage: EasyFinderJsonUtils.toInt(known['per_page']),
      extra: extra.isEmpty ? null : extra,
    );
  }

  Map<String, dynamic> toJson() {
    final out = <String, dynamic>{
      'q': q,
      'per_page': perPage,
    };
    if (extra != null) out.addAll(extra!);
    return out;
  }
}

/// ------------------------------------------------------------
/// Helpers (same style as your ExamAnswers helpers)
/// ------------------------------------------------------------
class EasyFinderMCQHelper {
  /// Parse 5-char string like "TFTFF" to List<bool?> length 5.
  static List<bool?> parse(String? input) {
    const len = 5;
    final out = List<bool?>.filled(len, null, growable: false);
    if (input == null || input.isEmpty) return out;

    for (var i = 0; i < len && i < input.length; i++) {
      final ch = input[i].toUpperCase();
      if (ch == 'T') out[i] = true;
      else if (ch == 'F') out[i] = false;
      else out[i] = null;
    }
    return out;
  }
}

class EasyFinderSBAHelper {
  static int? indexFromLetter(String? input) {
    if (input == null || input.isEmpty) return null;
    final c = input.trim().toUpperCase();
    if (c.length != 1) return null;
    final code = c.codeUnitAt(0) - 'A'.codeUnitAt(0);
    if (code < 0 || code > 4) return null;
    return code;
  }

  static String? letterFromIndex(int? index) {
    if (index == null || index < 0 || index > 4) return null;
    return String.fromCharCode('A'.codeUnitAt(0) + index);
  }
}

class EasyFinderJsonUtils {
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
}