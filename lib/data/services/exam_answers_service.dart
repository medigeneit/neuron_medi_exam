// lib/data/services/exam_answers_service.dart
import 'package:logger/logger.dart';
import 'package:medi_exam/data/models/exam_answers_model.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/data/utils/urls.dart';

class ExamAnswersService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> fetchExamAnswers(String admissionId, String examId) async {
    final url = Urls.examAnswers(admissionId, examId);

    // This endpoint requires authentication
    final token = LocalStorageService.getString(LocalStorageService.token);
    if (token == null || token.isEmpty) {
      return NetworkResponse(
        statusCode: 401,
        isSuccess: false,
        errorMessage: "Authentication required. Please login again.",
      );
    }

    final response = await _caller.getRequest(
      url,
      token: token,
    );

    if (response.isSuccess && response.responseData != null) {
      try {
        final data = response.responseData;

        // The API may return either a raw List or a wrapped Map.
        if (data is List || data is Map<String, dynamic>) {
          final model = ExamAnswersModel.fromAny(data);
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
            "Invalid response format: expected List/Map but got ${data.runtimeType}",
          );
        }
      } catch (e) {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: "Failed to parse Exam Answers: $e",
        );
      }
    }

    // pass through non-success or null-body responses
    return response;
  }
}
