import 'dart:convert';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/urls.dart';
import 'package:medi_exam/data/models/batch_enrollment_model.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:logger/logger.dart';

class BatchEnrollmentService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> enrollInBatch(String batchPackageId) async {
    final url = Urls.batchEnroll(batchPackageId);

    // Get token from local storage
    final token = LocalStorageService.getString(LocalStorageService.token);

    if (token == null || token.isEmpty) {
      return NetworkResponse(
        statusCode: 401,
        isSuccess: false,
        errorMessage: "Authentication required. Please login again.",
      );
    }

    final resp = await _caller.postRequest(
      url,
      token: token,
      // No body needed for this POST request based on the API structure
    );

    // If HTTP failed, bubble up as-is
    if (!resp.isSuccess) return resp;

    // Normalize the payload into a Map<String, dynamic>
    final raw = resp.responseData;
    Map<String, dynamic>? map;
    if (raw is Map<String, dynamic>) {
      map = raw;
    } else if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          map = decoded;
        }
      } catch (_) {/* fallthrough */}
    }

    if (map == null) {
      return NetworkResponse(
        statusCode: resp.statusCode,
        isSuccess: false,
        errorMessage:
        "Invalid response format: expected JSON object but got ${raw.runtimeType}",
      );
    }

    // Check if the response contains the is_enroll flag
    if (map.containsKey('is_enroll')) {
      final isEnroll = map['is_enroll'] as bool?;
      final message = map['message']?.toString() ?? 'Unknown error occurred';
      final batchPackage = map['batch_package'];

      // Case 1: User is already enrolled
      if (isEnroll == false && message.contains('already filled admission form')) {
        return NetworkResponse(
          statusCode: resp.statusCode,
          isSuccess: true, // HTTP success, but enrollment failed due to already enrolled
          responseData: {
            'is_enroll': false,
            'message': message,
            'already_enrolled': true
          },
        );
      }

      // Case 2: Wrong batchPackageId or other data issues
      if (isEnroll == false && (batchPackage == null || batchPackage == '')) {
        return NetworkResponse(
          statusCode: resp.statusCode,
          isSuccess: false,
          errorMessage: message,
          responseData: map,
        );
      }

      // Case 3: Other false cases (shouldn't normally happen)
      if (isEnroll == false) {
        return NetworkResponse(
          statusCode: resp.statusCode,
          isSuccess: false,
          errorMessage: message,
          responseData: map,
        );
      }
    }

    // Otherwise, parse as the normal enrollment model
    try {
      final model = BatchEnrollmentModel.fromJson(map);

      // Check if admission ID is valid
      if (model.admission?.id != null && model.admission!.id!.toString().isNotEmpty) {
        return NetworkResponse(
          statusCode: resp.statusCode,
          isSuccess: true,
          responseData: model,
        );
      } else {
        return NetworkResponse(
          statusCode: resp.statusCode,
          isSuccess: false,
          errorMessage: "Enrollment succeeded but no valid admission ID received",
          responseData: map,
        );
      }
    } catch (e) {
      return NetworkResponse(
        statusCode: resp.statusCode,
        isSuccess: false,
        errorMessage: "Failed to parse BatchEnrollmentModel: $e",
        responseData: map,
      );
    }
  }
}