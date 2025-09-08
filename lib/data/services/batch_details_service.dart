import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/urls.dart';
import 'package:medi_exam/data/models/batch_details_model.dart';
import 'package:logger/logger.dart';

class BatchDetailsService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> fetchBatchDetails(String batchId, String coursePackageId) async {
    final url = Urls.batchDetails(batchId, coursePackageId);

    final response = await _caller.getRequest(
      url,
      // Token is optional as this is public data
    );

    if (response.isSuccess && response.responseData != null) {
      try {
        // The response is a Map<String, dynamic> for single batch details
        if (response.responseData is Map<String, dynamic>) {
          final model = BatchDetailsModel.fromJson(response.responseData as Map<String, dynamic>);
          return NetworkResponse(
            statusCode: response.statusCode,
            isSuccess: true,
            responseData: model,
          );
        } else {
          return NetworkResponse(
            statusCode: response.statusCode,
            isSuccess: false,
            errorMessage: "Invalid response format: expected Map but got ${response.responseData.runtimeType}",
          );
        }
      } catch (e) {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: "Failed to parse BatchDetailsModel: $e",
        );
      }
    }

    return response;
  }
}