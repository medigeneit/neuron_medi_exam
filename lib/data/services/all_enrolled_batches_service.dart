import 'package:medi_exam/data/models/all_enrolled_batches_model.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/urls.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:logger/logger.dart';

class AllEnrolledBatchesService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> fetchAllEnrolledBatches() async {
    final url = Urls.allEnrolledBatches;

    // Get token from local storage
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
        // The response is a List<dynamic> for enrolled batches
        if (response.responseData is List<dynamic>) {
          final model = AllEnrolledBatchesModel.fromJson(
              response.responseData as List<dynamic>);
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
          errorMessage: "Failed to parse AllEnrolledBatches: $e",
        );
      }
    }

    return response;
  }
}