// get_bkash_url_service.dart
import 'package:logger/logger.dart';
import 'package:medi_exam/data/models/get_bkash_url_model.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/data/utils/urls.dart';



class GetBkashUrlService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> fetchBkashUrl(
      String admissionId,
      String amount,
      ) async {
    final url = Urls.makeBkashPayment(admissionId, amount);

    // This endpoint requires authentication
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
        if (response.responseData is Map<String, dynamic>) {
          final map = response.responseData as Map<String, dynamic>;
          final model = GetBkashUrlModel.fromMap(map);

          // Optional sanity check
          if (model.bkashUrl.isEmpty) {
            return NetworkResponse(
              statusCode: response.statusCode,
              isSuccess: false,
              errorMessage: "bKash URL missing in response.",
            );
          }

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
          errorMessage: "Failed to parse bKash URL: $e",
        );
      }
    }

    // Bubble up non-200 / transport errors as-is
    return response;
  }
}
