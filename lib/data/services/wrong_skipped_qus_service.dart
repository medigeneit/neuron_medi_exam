// lib/data/services/wrong_skipped_qus_service.dart
import 'package:logger/logger.dart';
import 'package:medi_exam/data/models/wrong_skipped_qus_model.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/data/utils/urls.dart';

class WrongSkippedQusService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> fetchWrongSkippedQusSummary() async {
    final token = LocalStorageService.getString(LocalStorageService.token);

    if (token == null || token.isEmpty) {
      return NetworkResponse(
        statusCode: 401,
        isSuccess: false,
        errorMessage: "Authentication required. Please login again.",
      );
    }

    final response = await _caller.getRequest(
      Urls.wrongSkippedQus,
      token: token,
    );

    if (!response.isSuccess || response.responseData == null) {
      return response; // pass through errors
    }

    try {
      final model = WrongSkippedQusModel.parse(response.responseData);

      return NetworkResponse(
        statusCode: response.statusCode,
        isSuccess: true,
        responseData: model, // ✅ correct type
      );
    } catch (e) {
      return NetworkResponse(
        statusCode: response.statusCode,
        isSuccess: false,
        errorMessage: "Failed to parse WrongSkippedQusModel: $e",
      );
    }
  }
}
