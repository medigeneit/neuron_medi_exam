import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/data/utils/urls.dart';

class ChangePasswordService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // 1) Auth
    final token = LocalStorageService.getString(LocalStorageService.token);
    if (token == null || token.isEmpty) {
      return NetworkResponse(
        statusCode: 401,
        isSuccess: false,
        errorMessage: "Authentication required. Please login again.",
      );
    }

    // 2) Payload
    final body = {
      'current_password': currentPassword,
      'new_password': newPassword,
      'new_password_confirmation': confirmPassword,
    };

    // 3) Fire request
    final resp = await _caller.postRequest(
      Urls.changePassword,
      token: token,
      body: body,
    );

    // 4) Normalize payload to Map<String, dynamic>
    Map<String, dynamic>? map;
    final raw = resp.responseData;
    if (raw is Map<String, dynamic>) {
      map = raw;
    } else if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) map = decoded;
      } catch (_) {/* keep null */}
    }

    // If HTTP failed (e.g., 4xx/5xx)
    if (!resp.isSuccess) {
      // Prefer API-provided message if available
      final message = map?['message']?.toString() ?? resp.errorMessage ?? 'Something went wrong';
      return NetworkResponse(
        statusCode: resp.statusCode,
        isSuccess: false,
        errorMessage: message,
        responseData: map ?? raw,
      );
    }

    // HTTP 200 – check API "status" & "message"
    final message = map?['message']?.toString() ?? 'Password changed successfully';
    final apiStatus = map?['status'];

    // Some backends might still return status=false with HTTP 200; honor that.
    if (apiStatus is bool && apiStatus == false) {
      return NetworkResponse(
        statusCode: resp.statusCode,
        isSuccess: false,
        errorMessage: message,
        responseData: map,
      );
    }

    // Success
    return NetworkResponse(
      statusCode: resp.statusCode,
      isSuccess: true,
      responseData: map ?? {'status': true, 'message': message},
    );
  }
}
