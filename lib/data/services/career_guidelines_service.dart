import 'package:logger/logger.dart';
import 'package:medi_exam/data/models/career_guidelines_model.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/data/utils/urls.dart';

class CareerGuidelinesService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> fetchCareerGuidelines() async {
    final url = Urls.careerGuidelines;

    // Token is optional as this data can be public
    final token = LocalStorageService.getString(LocalStorageService.token);

    final response = await _caller.getRequest(
      url,
      token: token,
    );

    if (response.isSuccess && response.responseData != null) {
      try {
        if (response.responseData is Map<String, dynamic>) {
          final model = CareerGuidelinesListModel.fromJson(
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
          errorMessage: "Failed to parse CareerGuidelinesListModel: $e",
        );
      }
    }

    return response;
  }
}