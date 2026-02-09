// lib/data/services/wrong_skipped_qus_details_service.dart
import 'dart:convert';

import 'package:logger/logger.dart';

import 'package:medi_exam/data/models/wrong_skipped_qus_details_model.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/data/utils/urls.dart';

class WrongSkippedQusDetailsService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> fetchWrongSkippedQusDetails({
    required String type,
    required String examId,
  }) async {
    // This endpoint requires authentication
    final token = LocalStorageService.getString(LocalStorageService.token);
    if (token == null || token.isEmpty) {
      return NetworkResponse(
        statusCode: 401,
        isSuccess: false,
        errorMessage: "Authentication required. Please login again.",
      );
    }

    final url = Urls.wrongSkippedQuestion(type, examId);

    final response = await _caller.getRequest(
      url,
      token: token,
    );

    if (response.isSuccess && response.responseData != null) {
      try {
        Map<String, dynamic>? asMap;

        final data = response.responseData;
        if (data is Map<String, dynamic>) {
          asMap = data;
        } else if (data is String) {
          final s = data.trim();
          if (s.isNotEmpty) {
            final decoded = jsonDecode(s);
            if (decoded is Map<String, dynamic>) {
              asMap = decoded;
            }
          }
        }

        if (asMap != null) {
          final model = WrongSkippedQusDetailsModel.fromJson(asMap);
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
          errorMessage: "Failed to parse Wrong/Skipped Details: $e",
        );
      }
    }

    // Pass through non-success responses from the caller
    return response;
  }
}
