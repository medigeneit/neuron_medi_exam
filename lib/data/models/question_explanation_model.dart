// lib/data/models/question_explanation_model.dart
import 'dart:convert';

QuestionExplanationModel questionExplanationFromJson(String source) {
  final decoded = jsonDecode(source);
  return QuestionExplanationModel.fromAny(decoded);
}

class QuestionExplanationModel {
  final bool? success;
  final int? questionId;
  final bool? hasExplanation;
  final QuestionExplanation? explanation;

  const QuestionExplanationModel({
    this.success,
    this.questionId,
    this.hasExplanation,
    this.explanation,
  });

  /// Accepts either:
  /// - full response map (your example)
  /// - direct "explanation" map
  factory QuestionExplanationModel.fromAny(dynamic json) {
    if (json is Map<String, dynamic>) {
      // If caller passes only the explanation object directly
      final isDirectExplanation =
          json.containsKey('body_html') || json.containsKey('body');

      if (isDirectExplanation) {
        return QuestionExplanationModel(
          success: true,
          hasExplanation: true,
          explanation: QuestionExplanation.fromJson(json),
        );
      }

      return QuestionExplanationModel(
        success: QeJsonUtils.toBool(json['success']),
        questionId: QeJsonUtils.toInt(json['question_id']),
        hasExplanation: QeJsonUtils.toBool(json['has_explanation']),
        explanation: QuestionExplanation.fromJson(
          json['explanation'] is Map<String, dynamic>
              ? (json['explanation'] as Map<String, dynamic>)
              : null,
        ),
      );
    }

    return const QuestionExplanationModel();
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'question_id': questionId,
    'has_explanation': hasExplanation,
    'explanation': explanation?.toJson(),
  };

  String toRawJson() => jsonEncode(toJson());

  QuestionExplanationModel copyWith({
    bool? success,
    int? questionId,
    bool? hasExplanation,
    QuestionExplanation? explanation,
  }) {
    return QuestionExplanationModel(
      success: success ?? this.success,
      questionId: questionId ?? this.questionId,
      hasExplanation: hasExplanation ?? this.hasExplanation,
      explanation: explanation ?? this.explanation,
    );
  }
}

/// ------------------------------
/// Explanation object
/// ------------------------------
class QuestionExplanation {
  final int? id;
  final String? bodyHtml;

  const QuestionExplanation({
    this.id,
    this.bodyHtml,
  });

  factory QuestionExplanation.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const QuestionExplanation();
    return QuestionExplanation(
      id: QeJsonUtils.toInt(json['id']),
      bodyHtml: QeJsonUtils.toStringOrNull(json['body_html'] ?? json['body']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'body_html': bodyHtml,
  };

  QuestionExplanation copyWith({
    int? id,
    String? bodyHtml,
  }) {
    return QuestionExplanation(
      id: id ?? this.id,
      bodyHtml: bodyHtml ?? this.bodyHtml,
    );
  }
}

/// ------------------------------
/// Utils
/// ------------------------------
class QeJsonUtils {
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
}
