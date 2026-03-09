// lib/data/services/easy_finder_questions_service.dart
import 'package:logger/logger.dart';
import 'package:medi_exam/data/models/easy_finder_questions_model.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/data/utils/urls.dart';

class EasyFinderQuestionsService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  /// ✅ Call API by query: Urls.smartSearchQuestions(query)
  Future<NetworkResponse> fetchEasyFinderQuestions(String query) async {
    final q = query.trim();

    if (q.isEmpty) {
      return NetworkResponse(
        statusCode: 400,
        isSuccess: false,
        errorMessage: "Search query can't be empty.",
      );
    }

    final token = LocalStorageService.getString(LocalStorageService.token);
    if (token == null || token.isEmpty) {
      return NetworkResponse(
        statusCode: 401,
        isSuccess: false,
        errorMessage: "Authentication required. Please login again.",
      );
    }

    final url = Urls.smartSearchQuestions(q);

    final response = await _caller.getRequest(
      url,
      token: token,
    );

    if (response.isSuccess && response.responseData != null) {
      try {
        final data = response.responseData;

        // Supports either raw List or wrapped Map
        if (data is List || data is Map<String, dynamic>) {
          final model = EasyFinderQuestionsModel.fromAny(data);
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
          errorMessage: "Failed to parse Easy Finder Questions: $e",
        );
      }
    }

    // pass through failures
    return response;
  }
}