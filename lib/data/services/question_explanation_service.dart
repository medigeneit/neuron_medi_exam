// lib/data/services/question_explanation_service.dart
import 'package:logger/logger.dart';
import 'package:medi_exam/data/models/question_explanation_model.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/data/utils/urls.dart';

class QuestionExplanationService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> fetchQuestionExplanation(String questionId) async {
    // This endpoint requires authentication
    final token = LocalStorageService.getString(LocalStorageService.token);
    if (token == null || token.isEmpty) {
      return NetworkResponse(
        statusCode: 401,
        isSuccess: false,
        errorMessage: "Authentication required. Please login again.",
      );
    }

    final url = Urls.questionExplanation(questionId);

    final response = await _caller.getRequest(
      url,
      token: token,
    );

    if (response.isSuccess && response.responseData != null) {
      try {
        final data = response.responseData;

        // API expected to return a wrapped Map like:
        // { success: true, question_id: ..., has_explanation: ..., explanation: {...} }
        if (data is Map<String, dynamic>) {
          final model = QuestionExplanationModel.fromAny(data);
          return NetworkResponse(
            statusCode: response.statusCode,
            isSuccess: true,
            responseData: model,
          );
        } else {
          return NetworkResponse(
            statusCode: response.statusCode,
            isSuccess: false,
            errorMessage:
            "Invalid response format: expected Map but got ${data.runtimeType}",
          );
        }
      } catch (e) {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: "Failed to parse Question Explanation: $e",
        );
      }
    }

    // pass through non-success or null-body responses
    return response;
  }
}
