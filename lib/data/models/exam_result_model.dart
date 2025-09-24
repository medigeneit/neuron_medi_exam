// lib/data/models/exam_result_model.dart
import 'dart:convert';

class ExamResultModel {
  final ExamInfo? exam;
  final ResultInfo? result;

  const ExamResultModel({this.exam, this.result});

  /// Safe factory that accepts Map or JSON String
  factory ExamResultModel.fromDynamic(dynamic data) {
    if (data == null) return const ExamResultModel();
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          return ExamResultModel.fromJson(decoded);
        }
      } catch (_) {
        // ignore bad json, return empty model
      }
      return const ExamResultModel();
    }
    if (data is Map<String, dynamic>) {
      return ExamResultModel.fromJson(data);
    }
    return const ExamResultModel();
  }

  factory ExamResultModel.fromJson(Map<String, dynamic> json) {
    return ExamResultModel(
      exam: ExamInfo.fromJson(_asMap(json['exam'])),
      result: ResultInfo.fromJson(_asMap(json['result'])),
    );
  }

  Map<String, dynamic> toJson() => {
    'exam': exam?.toJson(),
    'result': result?.toJson(),
  };

  ExamResultModel copyWith({ExamInfo? exam, ResultInfo? result}) =>
      ExamResultModel(
        exam: exam ?? this.exam,
        result: result ?? this.result,
      );

  // ----------------- helpers -----------------
  static Map<String, dynamic>? _asMap(dynamic v) {
    if (v == null) return null;
    if (v is Map<String, dynamic>) return v;
    // support JSON string inside the field
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return null;
      try {
        final decoded = jsonDecode(s);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return null;
  }
}

class ExamInfo {
  final int? id;
  final String? title;
  final int? totalQuestion;
  final int? fullMark;

  const ExamInfo({
    this.id,
    this.title,
    this.totalQuestion,
    this.fullMark,
  });

  factory ExamInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ExamInfo();
    return ExamInfo(
      id: _asInt(json['id']),
      title: _asString(json['title']),
      totalQuestion: _asInt(json['total_question']),
      fullMark: _asInt(json['full_mark']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'total_question': totalQuestion,
    'full_mark': fullMark,
  };

  ExamInfo copyWith({
    int? id,
    String? title,
    int? totalQuestion,
    int? fullMark,
  }) =>
      ExamInfo(
        id: id ?? this.id,
        title: title ?? this.title,
        totalQuestion: totalQuestion ?? this.totalQuestion,
        fullMark: fullMark ?? this.fullMark,
      );
}

class ResultInfo {
  final double? correctMark;
  final double? negativeMark;
  final double? obtainedMark;
  final double? obtainedMarkPercent;
  /// Kept flexible—API may send 10 or 10.0. Use num? to preserve either.
  final num? obtainedMarkDecimal;
  final int? wrongAnswers;
  final int? overallPosition;
  final int? batchPosition;

  const ResultInfo({
    this.correctMark,
    this.negativeMark,
    this.obtainedMark,
    this.obtainedMarkPercent,
    this.obtainedMarkDecimal,
    this.wrongAnswers,
    this.overallPosition,
    this.batchPosition,
  });

  factory ResultInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ResultInfo();
    return ResultInfo(
      correctMark: _asDouble(json['correct_mark']),
      negativeMark: _asDouble(json['negative_mark']),
      obtainedMark: _asDouble(json['obtained_mark']),
      obtainedMarkPercent: _asDouble(json['obtained_mark_percent']),
      obtainedMarkDecimal: _asNum(json['obtained_mark_decimal']),
      wrongAnswers: _asInt(json['wrong_answers']),
      overallPosition: _asInt(json['overall_position']),
      batchPosition: _asInt(json['batch_position']),
    );
  }

  Map<String, dynamic> toJson() => {
    'correct_mark': correctMark,
    'negative_mark': negativeMark,
    'obtained_mark': obtainedMark,
    'obtained_mark_percent': obtainedMarkPercent,
    'obtained_mark_decimal': obtainedMarkDecimal,
    'wrong_answers': wrongAnswers,
    'overall_position': overallPosition,
    'batch_position': batchPosition,
  };

  ResultInfo copyWith({
    double? correctMark,
    double? negativeMark,
    double? obtainedMark,
    double? obtainedMarkPercent,
    num? obtainedMarkDecimal,
    int? wrongAnswers,
    int? overallPosition,
    int? batchPosition,
  }) =>
      ResultInfo(
        correctMark: correctMark ?? this.correctMark,
        negativeMark: negativeMark ?? this.negativeMark,
        obtainedMark: obtainedMark ?? this.obtainedMark,
        obtainedMarkPercent: obtainedMarkPercent ?? this.obtainedMarkPercent,
        obtainedMarkDecimal: obtainedMarkDecimal ?? this.obtainedMarkDecimal,
        wrongAnswers: wrongAnswers ?? this.wrongAnswers,
        overallPosition: overallPosition ?? this.overallPosition,
        batchPosition: batchPosition ?? this.batchPosition,
      );
}

// ----------------- parsing utilities (null/empty safe) -----------------

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return null;
    final n = num.tryParse(s);
    return n?.toInt();
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
    final n = num.tryParse(s);
    return n?.toDouble();
  }
  return null;
}

num? _asNum(dynamic v) {
  if (v == null) return null;
  if (v is num) return v;
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return null;
    return num.tryParse(s);
  }
  return null;
}

String? _asString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}
