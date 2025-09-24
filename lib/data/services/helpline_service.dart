// lib/data/services/helpline_service.dart
import 'package:logger/logger.dart';
import 'package:medi_exam/data/models/helpline_model.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/data/utils/urls.dart';

class HelplineService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> fetchHelpline() async {
    final url = Urls.helpLine;


    final response = await _caller.getRequest(
      url,
    );

    if (response.isSuccess && response.responseData != null) {
      try {
        // Expecting a Map<String, dynamic>; model handles inner `data` or raw map.
        if (response.responseData is Map<String, dynamic>) {
          final model = HelplineModel.fromJson(
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
          errorMessage: "Failed to parse HelplineModel: $e",
        );
      }
    }

    return response;
  }
}
