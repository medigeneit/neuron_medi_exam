// lib/data/services/question_analytics_breakdown_service.dart
import 'package:logger/logger.dart';
import 'package:medi_exam/data/models/question_analytics_breakdown_model.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/data/utils/urls.dart';

class QuestionAnalyticsBreakdownService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> fetchQuestionAnalyticsBreakdown(
      String questionId,
      ) async {
    // This endpoint requires authentication
    final token = LocalStorageService.getString(LocalStorageService.token);
    if (token == null || token.isEmpty) {
      return NetworkResponse(
        statusCode: 401,
        isSuccess: false,
        errorMessage: "Authentication required. Please login again.",
      );
    }

    final url = Urls.questionAnalyticsBreakdown(questionId);

    final response = await _caller.getRequest(
      url,
      token: token,
    );

    if (response.isSuccess && response.responseData != null) {
      try {
        final data = response.responseData;

        // API expected formats:
        // Type 1 (option-wise): { question_id, question_type_id, "A": {...}, ... }
        // Type 2 (overall): { question_id, question_type_id, right_as_percent, wrong_as_percent, skip_as_percent }
        if (data is Map<String, dynamic>) {
          final model = QuestionAnalyticsBreakdownModel.fromJson(data);
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
          errorMessage: "Failed to parse Question Analytics Breakdown: $e",
        );
      }
    }

    // pass through non-success or null-body responses
    return response;
  }
}
