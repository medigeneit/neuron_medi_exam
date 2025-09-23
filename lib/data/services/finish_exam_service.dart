import 'package:medi_exam/data/models/doctor_schedule_model.dart';
import 'package:medi_exam/data/models/exam_property_model.dart';
import 'package:medi_exam/data/models/exam_question_model.dart';
import 'package:medi_exam/data/models/finish_exam_model.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/urls.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:logger/logger.dart';

class FinishExamService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> fetchFinishExam(String admissionId, String examId) async {
    final url = Urls.finishExam(admissionId, examId);

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
        // doctor schedule response is a Map<String, dynamic>
        if (response.responseData is Map<String, dynamic>) {
          final model = FinishExamModel.fromJson(
            response.responseData as Map<String, dynamic>,
          );
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
            "Invalid response format: expected Map but got ${response.responseData.runtimeType}",
          );
        }
      } catch (e) {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: "Failed to parse Exam: $e",
        );
      }
    }

    return response;
  }
}
