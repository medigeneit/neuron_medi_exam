import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/urls.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/data/models/exam_feedback_model.dart';

class ExamFeedbackService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  /// Submit exam feedback as a simple string.
  ///
  /// POST: Urls.examFeedback(admissionId, examId)
  /// Body: { "exam_feedback": "<feedback>" }
  ///
  /// On success, `responseData` is an [ExamFeedbackModel].
  Future<NetworkResponse> submitExamFeedback({
    required String admissionId,
    required String examId,
    required String feedback,
  }) async {
    final url = Urls.examFeedback(admissionId, examId);

    // Token
    final token = LocalStorageService.getString(LocalStorageService.token);
    if (token == null || token.isEmpty) {
      return NetworkResponse(
        statusCode: 401,
        isSuccess: false,
        errorMessage: "Authentication required. Please login again.",
      );
    }

    // Body per API contract
    final body = {"exam_feedback": feedback};

    final resp = await _caller.postRequest(
      url,
      token: token,
      body: body,
    );

    // If HTTP failed, bubble up
    if (!resp.isSuccess) return resp;

    // Normalize to Map<String, dynamic>
    final raw = resp.responseData;
    Map<String, dynamic>? map;
    if (raw is Map<String, dynamic>) {
      map = raw;
    } else if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          map = decoded;
        }
      } catch (_) {/* ignore */}
    }

    if (map == null) {
      return NetworkResponse(
        statusCode: resp.statusCode,
        isSuccess: false,
        errorMessage:
        "Invalid response format: expected JSON object but got ${raw.runtimeType}",
      );
    }

    // Some APIs return a bare payload {exam_feedback, message}
    // Others may wrap it (e.g., {data: {...}, message: ...})
    Map<String, dynamic> payload = map;
    if (map['data'] is Map<String, dynamic>) {
      // prefer a nested data object if present
      payload = Map<String, dynamic>.from(map['data'] as Map);
      // if message only exists on root, keep it
      payload.putIfAbsent('message', () => map!['message']);
    }

    try {
      final model = ExamFeedbackModel.fromJson(payload);
      final hasMessage = (model.message).toString().trim().isNotEmpty;

      return NetworkResponse(
        statusCode: resp.statusCode,
        isSuccess: true,
        responseData: model,
        // If your NetworkResponse supports a message field, keep as is.
        // Otherwise consumers can read model.message from responseData.
        errorMessage: 'Failed to parse',
      );
    } catch (e) {
      // If it doesn't match the expected shape, still return the raw map
      return NetworkResponse(
        statusCode: resp.statusCode,
        isSuccess: false,
        errorMessage: "Failed to parse ExamFeedbackModel: $e",
        responseData: map,
      );
    }
  }
}
