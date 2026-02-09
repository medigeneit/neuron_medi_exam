import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/data/utils/urls.dart';

class FavouritesToggleService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  /// ✅ Toggle favourite:
  /// POST {{BASE_URL}}/doctor/favourites/add
  /// body: { "question_id": 354 }
  /// response: { "status": "added" } or { "status": "removed" }
  Future<NetworkResponse> toggleFavourite({required int questionId}) async {
    final token = LocalStorageService.getString(LocalStorageService.token);

    if (token == null || token.isEmpty) {
      return NetworkResponse(
        statusCode: 401,
        isSuccess: false,
        errorMessage: "Authentication required. Please login again.",
      );
    }

    final response = await _caller.postRequest(
      Urls.favouritesToggleAddRemove, // ✅ make sure this exists in Urls
      body: {"question_id": questionId},
      token: token,
    );

    return response;
  }

  /// ✅ Safely extract "added" / "removed"
  /// Your NetworkCaller already jsonDecodes, but this keeps it safe.
  String? extractStatus(dynamic responseData) {
    if (responseData == null) return null;

    try {
      if (responseData is Map<String, dynamic>) {
        return responseData['status']?.toString();
      }

      if (responseData is String && responseData.trim().isNotEmpty) {
        final decoded = jsonDecode(responseData);
        if (decoded is Map<String, dynamic>) {
          return decoded['status']?.toString();
        }
      }
    } catch (_) {}

    return null;
  }
}