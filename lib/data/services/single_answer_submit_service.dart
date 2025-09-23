// lib/data/services/single_answer_submit_service.dart

import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/urls.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/data/models/single_answer_submit_model.dart';

class SingleAnswerSubmitService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> submitSingleAnswer({
    String? admissionId,
    String? examId,
    String? questionId,
    String? examQuestionId,
    String? questionTypeId,
    String? answer,
    String? endDuration,
  }) async {
    final url = Urls.singleAnswerSubmit;

    // Get token from local storage if not provided
    final rawToken = LocalStorageService.getString(LocalStorageService.token);

    if (rawToken == null || rawToken.isEmpty) {
      // Keep parity with other services: fail fast when no token is present.
      return NetworkResponse(
        statusCode: 401,
        isSuccess: false,
        errorMessage: "Authentication required. Please login again.",
      );
    }

    // Build body: API expects strings; convert null -> "" to be safe.
    String _s(String? v) => v?.trim() ?? '';

    final Map<String, dynamic> body = {
      'token': _s(rawToken),
      'admission_id': _s(admissionId),
      'exam_id': _s(examId),
      'question_id': _s(questionId),
      'exam_question_id': _s(examQuestionId),
      'question_type_id': _s(questionTypeId),
      'answer': _s(answer),
      'end_duration': _s(endDuration),
    };

    // Fire the POST request (pass token as header too, for consistency)
    final resp = await _caller.postRequest(
      url,
      token: rawToken,
      body: body,
    );

    // If HTTP failed, bubble up the original response
    if (!resp.isSuccess) return resp;

    // Normalize payload to Map<String, dynamic>
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
      } catch (_) {/* swallow and handle below */}
    }

    if (map == null) {
      return NetworkResponse(
        statusCode: resp.statusCode,
        isSuccess: false,
        errorMessage: 'Invalid server response format',
        responseData: raw,
      );
    }

    // Try to parse into the model for a clean success/message read
    try {
      final model = SingleAnswerSubmitModel.fromJson(map);
      final ok = model.success == true;

      return NetworkResponse(
        statusCode: resp.statusCode,
        isSuccess: ok,
        errorMessage: 'Answer submission failed',
        responseData: map,
      );
    } catch (e) {
      // Model parsing failed: still return the raw map, but flag as error
      return NetworkResponse(
        statusCode: resp.statusCode,
        isSuccess: false,
        errorMessage: "Failed to parse SingleAnswerSubmitModel: $e",
        responseData: map,
      );
    }
  }
}
