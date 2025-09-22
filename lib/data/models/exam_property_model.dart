// exam_property_model.dart
import 'dart:convert';
class ExamPropertyModel {
  final ExamInfo? exam;
  final QuestionProperty? questionProperty;

  /// Keep raw so we can handle null, String (HTML), Map, etc.
  final dynamic policy;

  const ExamPropertyModel({
    this.exam,
    this.questionProperty,
    this.policy,
  });

  factory ExamPropertyModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ExamPropertyModel();
    return ExamPropertyModel(
      exam: ExamInfo.fromJson(_asMap(json['exam'])),
      questionProperty: QuestionProperty.fromJson(_asMap(json['question_property'])),
      policy: json['policy'], // could be null / String / Map / etc.
    );
  }

  Map<String, dynamic> toJson() => {
    'exam': exam?.toJson(),
    'question_property': questionProperty?.toJson(),
    'policy': policy,
  };

  /// -------- Safe getters for UI --------

  bool get isEmpty =>
      (exam == null || exam!.isEmpty) &&
          (questionProperty == null || questionProperty!.isEmpty) &&
          (safePolicyHtml.isEmpty);

  // Exam
  String get safeExamTitle => exam?.safeTitle ?? '';
  int get safeExamDurationMinutes => exam?.durationMinutes ?? 0;
  bool get safeIsPublished => exam?.isPublished ?? false;
  int get safeExamQuestionCount => exam?.questionCount ?? 0;

  // Question property
  int get safeTotalQuestion => questionProperty?.totalQuestion ?? 0;
  double get safePerQuestionMark => questionProperty?.perQuestionMark ?? 0.0;
  double get safeNegativeMarking => questionProperty?.negativeMarking ?? 0.0;
  List<QuestionType> get safeQuestionTypes =>
      questionProperty?.questionTypes ?? const [];

  // Policy (HTML string from backend)
  /// Raw HTML as string (or empty if not present / not a string)
  String get safePolicyHtml {
    final s = _asString(policy);
    return s?.trim() ?? '';
  }

  /// Plain text version (tags stripped, entities unescaped)
  String get safePolicyText => _htmlToPlainText(safePolicyHtml);

  /// Split into bullet-ish paragraphs (already stripped + unescaped)
  List<String> get policyParagraphs {
    final html = safePolicyHtml;
    if (html.isEmpty) return const [];
    final paras = _extractHtmlParagraphs(html);
    if (paras.isNotEmpty) return paras;
    // Fallback: split by lines if no <p> tags present
    final text = safePolicyText;
    return text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  ExamPropertyModel copyWith({
    ExamInfo? exam,
    QuestionProperty? questionProperty,
    dynamic policy,
  }) {
    return ExamPropertyModel(
      exam: exam ?? this.exam,
      questionProperty: questionProperty ?? this.questionProperty,
      policy: policy ?? this.policy,
    );
  }
}

/// Exam sub-object
class ExamInfo {
  final int? id;
  final String? title;
  final int? durationMinutes;
  final bool? isPublished;
  final int? questionCount;

  const ExamInfo({
    this.id,
    this.title,
    this.durationMinutes,
    this.isPublished,
    this.questionCount,
  });

  factory ExamInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ExamInfo();
    return ExamInfo(
      id: _asInt(json['id']),
      title: _asString(json['title']),
      durationMinutes: _asInt(json['duration_minutes']),
      isPublished: _asBool(json['is_published']),
      questionCount: _asInt(json['question_count']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'duration_minutes': durationMinutes,
    'is_published': isPublished,
    'question_count': questionCount,
  };

  bool get isEmpty =>
      id == null &&
          (title == null || title!.trim().isEmpty) &&
          durationMinutes == null &&
          isPublished == null &&
          questionCount == null;

  String get safeTitle => title?.trim() ?? '';
}

/// QuestionProperty sub-object
class QuestionProperty {
  final int? id;
  final int? totalQuestion;
  final double? perQuestionMark;
  final double? negativeMarking;
  final List<QuestionType>? questionTypes;

  const QuestionProperty({
    this.id,
    this.totalQuestion,
    this.perQuestionMark,
    this.negativeMarking,
    this.questionTypes,
  });

  factory QuestionProperty.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const QuestionProperty();
    final list = _asList(json['question_types']);
    return QuestionProperty(
      id: _asInt(json['id']),
      totalQuestion: _asInt(json['total_question']),
      perQuestionMark: _asDouble(json['per_question_mark']),
      negativeMarking: _asDouble(json['negative_marking']),
      questionTypes: list
          .map((e) => QuestionType.fromJson(_asMap(e)))
          .whereType<QuestionType>()
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'total_question': totalQuestion,
    'per_question_mark': perQuestionMark,
    'negative_marking': negativeMarking,
    'question_types': questionTypes?.map((e) => e.toJson()).toList(),
  };

  bool get isEmpty =>
      id == null &&
          totalQuestion == null &&
          perQuestionMark == null &&
          negativeMarking == null &&
          (questionTypes == null || questionTypes!.isEmpty);
}

/// QuestionType item inside question_property.question_types
class QuestionType {
  final int? id;
  final String? name;
  final int? numberOfOptions;
  final int? answerType;
  final int? numberOfQuestion;
  final double? perQuestionNegative;

  const QuestionType({
    this.id,
    this.name,
    this.numberOfOptions,
    this.answerType,
    this.numberOfQuestion,
    this.perQuestionNegative,
  });

  factory QuestionType.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const QuestionType();
    return QuestionType(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      numberOfOptions: _asInt(json['number_of_options']),
      answerType: _asInt(json['answer_type']),
      numberOfQuestion: _asInt(json['number_of_question']),
      perQuestionNegative: _asDouble(json['per_question_negative']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'number_of_options': numberOfOptions,
    'answer_type': answerType,
    'number_of_question': numberOfQuestion,
    'per_question_negative': perQuestionNegative,
  };

  bool get isEmpty =>
      id == null &&
          (name == null || name!.trim().isEmpty) &&
          numberOfOptions == null &&
          answerType == null &&
          numberOfQuestion == null &&
          perQuestionNegative == null;
}

//
// -------------------- Safe parsing helpers --------------------
//

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return null;
    final i = int.tryParse(s);
    if (i != null) return i;
    final d = double.tryParse(s);
    return d?.toInt();
  }
  return null;
}

double? _asDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }
  return null;
}

bool? _asBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final s = v.trim().toLowerCase();
    if (s.isEmpty) return null;
    if (s == 'true' || s == '1' || s == 'yes' || s == 'y') return true;
    if (s == 'false' || s == '0' || s == 'no' || s == 'n') return false;
  }
  return null;
}

String? _asString(dynamic v) {
  if (v == null) return null;
  if (v is String) return v;
  // Primitive to string; complex -> JSON text (so you still "see" something)
  if (v is num || v is bool) return v.toString();
  try {
    return jsonEncode(v);
  } catch (_) {
    return v.toString();
  }
}

Map<String, dynamic>? _asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  return null;
}

List<dynamic> _asList(dynamic v) {
  if (v is List) return v;
  return const [];
}

/// -------------------- Minimal HTML utilities --------------------
/// Very small, dependency-free helpers to consume simple HTML policy safely.

/// Strip tags and unescape a few common entities.
/// Good enough for lightweight, trusted HTML from the backend.
String _htmlToPlainText(String html) {
  if (html.isEmpty) return '';
  var text = html;

  // Normalize line breaks for common tags
  text = text.replaceAll(RegExp(r'(?i)<br\s*/?>'), '\n');
  text = text.replaceAll(RegExp(r'(?i)</p>'), '\n');

  // Remove all tags
  text = text.replaceAll(RegExp(r'<[^>]+>'), '');

  // Unescape common entities
  text = text
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'");

  // Collapse multiple newlines/spaces
  text = text.replaceAll(RegExp(r'\n\s*\n\s*'), '\n\n').trim();
  return text;
}

/// Extract <p>...</p> blocks as plain text bullets; falls back to stripping tags.
List<String> _extractHtmlParagraphs(String html) {
  final reg = RegExp(r'(?is)<p[^>]*>(.*?)</p>');
  final matches = reg.allMatches(html).toList();
  if (matches.isEmpty) return const [];
  return matches
      .map((m) => _htmlToPlainText(m.group(1) ?? ''))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}
