// lib/data/services/free_exam_quota_service.dart
import 'package:logger/logger.dart';
import 'package:medi_exam/data/models/free_exam_quota_model.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/data/utils/urls.dart';

class FreeExamQuotaService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> fetchFreeExamQuota() async {
    final token = LocalStorageService.getString(LocalStorageService.token);

    if (token == null || token.isEmpty) {
      return NetworkResponse(
        statusCode: 401,
        isSuccess: false,
        errorMessage: "Authentication required. Please login again.",
      );
    }

    final response = await _caller.getRequest(
      Urls.freeExamQuota,
      token: token,
    );

    if (!response.isSuccess || response.responseData == null) {
      return response; // pass through errors
    }

    try {
      // response.responseData can be Map or JSON string; parse handles both
      final model = FreeExamQuotaModel.parse(response.responseData);

      // Optional validation: ok must be true
      if (model.ok != true) {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: "Failed to load free exam quota.",
        );
      }

      return NetworkResponse(
        statusCode: response.statusCode,
        isSuccess: true,
        responseData: model, // ✅ correct type
      );
    } catch (e) {
      return NetworkResponse(
        statusCode: response.statusCode,
        isSuccess: false,
        errorMessage: "Failed to parse FreeExamQuotaModel: $e",
      );
    }
  }
}
