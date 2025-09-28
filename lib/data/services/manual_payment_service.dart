import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/data/utils/urls.dart';

/// Submits a manual payment (bKash/Nagad/Rocket) to the backend.
class ManualPaymentService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  /// gatewayType must be one of: 'bkash' | 'nagad' | 'rocket'
  Future<NetworkResponse> submitManualPayment({
    required String admissionId,
    required String transId,
    required double amount,
    required String gatewayType,
  }) async {
    // token
    final token = LocalStorageService.getString(LocalStorageService.token);
    if (token == null || token.isEmpty) {
      return NetworkResponse(
        statusCode: 401,
        isSuccess: false,
        errorMessage: "Authentication required. Please login again.",
      );
    }

    final url = Urls.manualPayments; // ensure this exists in your Urls class

    final Map<String, dynamic> body = {
      "admission_id": admissionId,
      "trans_id": transId,
      "amount": amount,
      "gateway_type": gatewayType.toLowerCase(),
    };

    final resp = await _caller.postRequest(
      url,
      token: token,
      body: body,
    );

    // If HTTP layer failed, return as-is
    if (!resp.isSuccess) return resp;

    // Normalize payload into Map<String, dynamic>
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

    // Accept 201 as success from server contract
    final code = resp.statusCode;
    if (code == 201) {
      return NetworkResponse(
        statusCode: code,
        isSuccess: true,
        responseData: map ?? raw,
      );
    }

    // Other 2xx without JSON still OK, but mark success
    if (code != null && code >= 200 && code < 300) {
      return NetworkResponse(
        statusCode: code,
        isSuccess: true,
        responseData: map ?? raw,
      );
    }

    // Non-2xx => failure
    return NetworkResponse(
      statusCode: code,
      isSuccess: false,
      errorMessage: "Manual payment failed (${code ?? 'unknown code'}).",
      responseData: map ?? raw,
    );
  }
}
