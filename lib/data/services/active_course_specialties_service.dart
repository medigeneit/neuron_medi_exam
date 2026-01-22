import 'package:logger/logger.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/urls.dart';
import 'package:medi_exam/data/models/active_course_specialties_model.dart';

class ActiveCourseSpecialtiesService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> fetchActiveCourseSpecialties() async {
    const url = Urls.activeCourseSpecialties;

    final response = await _caller.getRequest(
      url,
      // Token optional (public)
    );

    if (response.isSuccess && response.responseData != null) {
      try {
        // Response must be List<dynamic>
        if (response.responseData is List) {
          final model = ActiveCourseSpecialtiesModel.fromJson(
            response.responseData as List<dynamic>,
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
            "Invalid response format: expected List but got ${response.responseData.runtimeType}",
          );
        }
      } catch (e) {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: "Failed to parse ActiveCourseSpecialtiesModel: $e",
        );
      }
    }

    return response;
  }
}
