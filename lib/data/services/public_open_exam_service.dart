import 'package:logger/logger.dart';
import 'package:medi_exam/data/models/open_exam_list_model.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';

class PublicOpenExamService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  /// Public: {{BASE_URL}}/open-exams/free  (no token)
  Future<NetworkResponse> fetchPublicFreeOpenExams(String url) async {
    final response = await _caller.getRequest(url);

    if (response.isSuccess && response.responseData != null) {
      try {
        final model = OpenExamListModel.fromJsonList(response.responseData);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseData: model,
        );
      } catch (e) {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: "Failed to parse public Free Exam List: $e",
        );
      }
    }

    return response;
  }
}