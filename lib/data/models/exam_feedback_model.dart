// lib/data/models/exam_feedback_model.dart
import 'dart:convert';

class ExamFeedbackModel {
  final String examFeedback;
  final String message;

  const ExamFeedbackModel({
    required this.examFeedback,
    required this.message,
  });

  /// Create from a JSON map
  factory ExamFeedbackModel.fromJson(Map<String, dynamic> json) {
    return ExamFeedbackModel(
      examFeedback: (json['exam_feedback'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
    );
  }

  /// Create from a raw JSON string
  factory ExamFeedbackModel.fromRawJson(String source) =>
      ExamFeedbackModel.fromJson(json.decode(source) as Map<String, dynamic>);

  /// Convert to a JSON map
  Map<String, dynamic> toJson() => {
    'exam_feedback': examFeedback,
    'message': message,
  };

  /// Convert to a raw JSON string
  String toRawJson() => json.encode(toJson());

  /// Handy copyWith
  ExamFeedbackModel copyWith({
    String? examFeedback,
    String? message,
  }) {
    return ExamFeedbackModel(
      examFeedback: examFeedback ?? this.examFeedback,
      message: message ?? this.message,
    );
  }

  // Optional "safe" getters if you use that pattern elsewhere
  String get safeExamFeedback => examFeedback;
  String get safeMessage => message;

  @override
  String toString() =>
      'ExamFeedbackModel(examFeedback: $examFeedback, message: $message)';
}
