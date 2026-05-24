import 'package:logger/logger.dart';
import 'package:medi_exam/data/models/unit_video_bkash_checkout_model.dart';
import 'package:medi_exam/data/models/unit_video_bkash_payment_status_model.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/data/utils/urls.dart';

class UnitVideoPaymentService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> initiateBkashCheckout() async {
    final token = LocalStorageService.getString(LocalStorageService.token);

    if (token == null || token.isEmpty) {
      return NetworkResponse(
        statusCode: 401,
        isSuccess: false,
        errorMessage: "Authentication required. Please login again.",
      );
    }

    final response = await _caller.postRequest(
      Urls.unitVideoBkashCheckOut,
      token: token,

      // Keep empty body because this checkout is based on current cart.
      // If backend later requires anything, add it here.
      body: {},
    );

    if (response.isSuccess && response.responseData != null) {
      try {
        final data = response.responseData;

        if (data is Map<String, dynamic>) {
          final model = UnitVideoBkashCheckoutModel.fromJson(data);

          return NetworkResponse(
            statusCode: response.statusCode,
            isSuccess: true,
            responseData: model,

          );
        } else {
          return NetworkResponse(
            statusCode: response.statusCode,
            isSuccess: false,
            responseData: response.responseData,
            errorMessage:
            "Invalid response format: expected Map but got ${data.runtimeType}",
          );
        }
      } catch (e) {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          responseData: response.responseData,
          errorMessage: "Failed to parse bKash checkout response: $e",
        );
      }
    }

    return response;
  }

  Future<NetworkResponse> checkBkashPaymentStatus(String paymentID) async {
    final token = LocalStorageService.getString(LocalStorageService.token);

    if (token == null || token.isEmpty) {
      return NetworkResponse(
        statusCode: 401,
        isSuccess: false,
        errorMessage: "Authentication required. Please login again.",
      );
    }

    final trimmedPaymentID = paymentID.trim();

    if (trimmedPaymentID.isEmpty) {
      return NetworkResponse(
        statusCode: 400,
        isSuccess: false,
        errorMessage: "Payment ID is required.",
      );
    }

    final response = await _caller.getRequest(
      Urls.bkashPaymentStatus(trimmedPaymentID),
      token: token,
    );

    if (response.responseData != null) {
      try {
        final data = response.responseData;

        if (data is Map<String, dynamic>) {
          final model = UnitVideoBkashPaymentStatusModel.fromJson(data);

          return NetworkResponse(
            statusCode: response.statusCode,
            isSuccess: model.success == true,
            responseData: model,
            errorMessage: model.statusMessage,
          );
        } else {
          return NetworkResponse(
            statusCode: response.statusCode,
            isSuccess: false,
            responseData: response.responseData,
            errorMessage:
            "Invalid response format: expected Map but got ${data.runtimeType}",
          );
        }
      } catch (e) {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          responseData: response.responseData,
          errorMessage: "Failed to parse bKash payment status response: $e",
        );
      }
    }

    return response;
  }
}