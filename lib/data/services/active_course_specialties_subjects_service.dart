// active_course_specialties_subjects_service.dart

import 'package:logger/logger.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/urls.dart';
import 'package:medi_exam/data/models/active_course_specialties_subjects_model.dart';

class ActiveCourseSpecialtiesSubjectsService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> fetchActiveCourseSpecialtiesSubjects() async {
    const url = Urls.activeCourseSpecialtiesSubjects;

    final response = await _caller.getRequest(
      url,
      // Token optional (public)
    );

    if (response.isSuccess && response.responseData != null) {
      try {
        // Response must be Map<String, dynamic>
        if (response.responseData is Map<String, dynamic>) {
          final model = ActiveCourseSpecialtiesSubjectsModel.fromJson(
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
            "Invalid response format: expected Map<String, dynamic> but got ${response.responseData.runtimeType}",
          );
        }
      } catch (e) {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage:
          "Failed to parse ActiveCourseSpecialtiesSubjectsModel: $e",
        );
      }
    }

    return response;
  }
}
