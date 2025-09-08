import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/urls.dart';
import 'package:medi_exam/data/models/courses_model.dart';
import 'package:logger/logger.dart';

class ActiveBatchCoursesService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> fetchActiveBatchCourses() async {
    const url = Urls.activeBatchCourses;

    final response = await _caller.getRequest(
      url,
      // Token is optional as this is public data
    );

    if (response.isSuccess && response.responseData != null) {
      try {
        // The response is a List<dynamic>, not a Map<String, dynamic>
        if (response.responseData is List) {
          final model = CoursesModel.fromJson(response.responseData as List<dynamic>);
          return NetworkResponse(
            statusCode: response.statusCode,
            isSuccess: true,
            responseData: model,
          );
        } else {
          return NetworkResponse(
            statusCode: response.statusCode,
            isSuccess: false,
            errorMessage: "Invalid response format: expected List but got ${response.responseData.runtimeType}",
          );
        }
      } catch (e) {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: "Failed to parse AllBatchCoursesModel: $e",
        );
      }
    }

    return response;
  }
}