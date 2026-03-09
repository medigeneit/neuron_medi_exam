// lib/data/services/easy_finder_keywords_service.dart
import 'package:logger/logger.dart';
import 'package:medi_exam/data/models/easy_finder_keywords_model.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/data/utils/urls.dart';

class EasyFinderKeywordsService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> fetchAllKeywords() async {
    // Auth required (doctor endpoint)
    final token = LocalStorageService.getString(LocalStorageService.token);
    if (token == null || token.isEmpty) {
      return NetworkResponse(
        statusCode: 401,
        isSuccess: false,
        errorMessage: "Authentication required. Please login again.",
      );
    }

    final response = await _caller.getRequest(
      Urls.smartSearchKeywordsAll,
      token: token,
    );

    if (response.isSuccess && response.responseData != null) {
      try {
        final data = response.responseData;

        if (data is List || data is Map<String, dynamic>) {
          final model = EasyFinderKeywordsModel.fromAny(data);
          return NetworkResponse(
            statusCode: response.statusCode,
            isSuccess: true,
            responseData: model,
          );
        }

        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage:
          "Invalid response format: expected List/Map but got ${data.runtimeType}",
        );
      } catch (e) {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: "Failed to parse keywords: $e",
        );
      }
    }

    return response;
  }
}