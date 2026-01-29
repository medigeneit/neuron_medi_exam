import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:medi_exam/data/models/free_exam_create_model.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/urls.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';


class FreeExamCreateService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> createFreeExam(
      FreeExamCreateRequestModel requestModel) async {
    final url = Urls.freeExamCreate;

    // Get token from local storage
    final token = LocalStorageService.getString(LocalStorageService.token);

    if (token == null || token.isEmpty) {
      return NetworkResponse(
        statusCode: 401,
        isSuccess: false,
        errorMessage: "Authentication required. Please login again.",
      );
    }

    // Send request
    final resp = await _caller.postRequest(
      url,
      token: token,
      body: requestModel.toJson(),
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

    // Check ok flag early
    final ok = map['ok'] is bool ? map['ok'] as bool : false;
    final message = map['message']?.toString() ?? "Unknown error occurred";

    if (!ok) {
      return NetworkResponse(
        statusCode: resp.statusCode,
        isSuccess: false,
        errorMessage: message,
        responseData: map,
      );
    }

    // Parse response model
    try {
      final model = FreeExamCreateResponseModel.fromJson(map);

      // Validate essential response
      if (model.isSuccess && model.exam != null && model.exam!.examId != null) {
        return NetworkResponse(
          statusCode: resp.statusCode,
          isSuccess: true,
          responseData: model,
        );
      } else {
        return NetworkResponse(
          statusCode: resp.statusCode,
          isSuccess: false,
          errorMessage:
          "Exam created but exam_id not found in response. Please try again.",
          responseData: map,
        );
      }
    } catch (e) {
      return NetworkResponse(
        statusCode: resp.statusCode,
        isSuccess: false,
        errorMessage: "Failed to parse FreeExamCreateResponseModel: $e",
        responseData: map,
      );
    }
  }
}
