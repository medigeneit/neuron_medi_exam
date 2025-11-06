// free_exam_list_service.dart
import 'package:logger/logger.dart';
import 'package:medi_exam/data/models/free_exam_list_model.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/data/utils/urls.dart';

class FreeExamListService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  /// Fetch the list of free exams.

  Future<NetworkResponse> fetchFreeExamList(String courseId) async {
    final url = Urls.freeExamList(courseId);

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
        // The API returns a top-level JSON array OR a wrapped map with `data: []`.
        final model = FreeExamListModel.fromJsonList(response.responseData);

        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseData: model, // return strongly-typed model
        );
      } catch (e) {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: "Failed to parse Free Exam List: $e",
        );
      }
    }


    return response;
  }
}
