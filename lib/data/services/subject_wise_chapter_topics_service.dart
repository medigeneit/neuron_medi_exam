// lib/data/services/subject_wise_chapter_topics_service.dart

import 'package:logger/logger.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/urls.dart';
import 'package:medi_exam/data/models/subject_wise_chapter_topics_model.dart';

class SubjectWiseChapterTopicsService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> fetchSubjectWiseChapterTopics({
    required String specialtyId,
    required String subjectId,
  }) async {
    final url = Urls.subjectWiseChapterTopics(specialtyId, subjectId);

    final response = await _caller.getRequest(
      url,
      // Token optional (public)
    );

    if (response.isSuccess && response.responseData != null) {
      try {
        // Response must be Map<String, dynamic>
        if (response.responseData is Map<String, dynamic>) {
          final model = SubjectWiseChapterTopicsModel.fromJson(
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
          errorMessage: "Failed to parse SubjectWiseChapterTopicsModel: $e",
        );
      }
    }

    return response;
  }
}
