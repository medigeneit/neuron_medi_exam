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
    /// 'freeExam', 'openExam', 'courseExam', 'subjectExam'
    required String examType,

    String? admissionId,
    String? examId,
    String? questionId,

    /// NOTE:
    /// - freeExam: DO NOT send exam_question_id
    /// - other types: send it normally
    String? examQuestionId,

    String? questionTypeId,
    String? answer,
    String? endDuration,
  }) async {
    // Token
    final rawToken = LocalStorageService.getString(LocalStorageService.token);
    if (rawToken == null || rawToken.isEmpty) {
      return NetworkResponse(
        statusCode: 401,
        isSuccess: false,
        errorMessage: "Authentication required. Please login again.",
      );
    }

    String _s(String? v) => v?.trim() ?? '';

    // ✅ Only courseExam needs admission_id
    final bool needsAdmissionId = examType == 'courseExam';

    // ✅ Pick URL based on examType
    final String url = _singleAnswerUrlByExamType(examType);

    // Build request body
    final Map<String, dynamic> body = {
      'token': _s(rawToken),
      'exam_id': _s(examId),
      'question_id': _s(questionId),
      'question_type_id': _s(questionTypeId),
      'answer': _s(answer),
      'end_duration': _s(endDuration),
    };

    // ✅ freeExam: do NOT include exam_question_id at all
    if (examType != 'freeExam') {
      body['exam_question_id'] = _s(examQuestionId);
    }

    // ✅ only courseExam: include admission_id
    if (needsAdmissionId) {
      body['admission_id'] = _s(admissionId);
    }

    // POST
    final resp = await _caller.postRequest(
      url,
      token: rawToken,
      body: body,
    );

    if (!resp.isSuccess) return resp;

    // Normalize responseData to Map<String, dynamic>
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
        errorMessage: 'Invalid server response format',
        responseData: raw,
      );
    }

    // Parse model
    try {
      final model = SingleAnswerSubmitModel.fromJson(map);
      final ok = model.success == true;

      final String? serverMsg = (model.message is String &&
          (model.message as String).trim().isNotEmpty)
          ? (model.message as String).trim()
          : null;

      return NetworkResponse(
        statusCode: resp.statusCode,
        isSuccess: ok,
        errorMessage: 'Answer submission failed',
        responseData: map,
      );
    } catch (e) {
      return NetworkResponse(
        statusCode: resp.statusCode,
        isSuccess: false,
        errorMessage: "Failed to parse SingleAnswerSubmitModel: $e",
        responseData: map,
      );
    }
  }

  /// Map examType -> endpoint
  /// Ensure these exist in Urls (or rename here to match your Urls).
  String _singleAnswerUrlByExamType(String examType) {
    switch (examType) {
      case 'freeExam':
        return Urls.freeExamSingleAnswerSubmit;
      case 'openExam':
        return Urls.openExamSingleAnswerSubmit;
      case 'courseExam':
        return Urls.courseExamSingleAnswerSubmit;
/*      case 'subjectExam':
        return Urls.subjectExamSingleAnswerSubmit;*/
      default:
        return Urls.openExamSingleAnswerSubmit;
    }
  }
}
