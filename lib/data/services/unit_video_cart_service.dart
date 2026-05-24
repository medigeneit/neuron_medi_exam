import 'package:logger/logger.dart';
import 'package:medi_exam/data/models/unit_video_cart_model.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/data/utils/urls.dart';

class UnitVideoCartService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> fetchUnitVideoCart() async {
    final token = LocalStorageService.getString(LocalStorageService.token);

    if (token == null || token.isEmpty) {
      return NetworkResponse(
        statusCode: 401,
        isSuccess: false,
        errorMessage: "Authentication required. Please login again.",
      );
    }

    final response = await _caller.getRequest(
      Urls.unitVideoCart,
      token: token,
    );

    if (response.isSuccess && response.responseData != null) {
      try {
        final data = response.responseData;

        // API format:
        // {
        //   success,
        //   message,
        //   data: {
        //     items: [],
        //     total_items,
        //     total_amount
        //   }
        // }

        if (data is Map<String, dynamic>) {
          final cartData = data['data'];

          if (cartData is Map<String, dynamic>) {
            final model = UnitVideoCartModel.fromJson(cartData);

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
              "Invalid response format: expected data Map but got ${cartData.runtimeType}",
            );
          }
        } else {
          return NetworkResponse(
            statusCode: response.statusCode,
            isSuccess: false,
            errorMessage:
            "Invalid response format: expected Map but got ${data.runtimeType}",
          );
        }
      } catch (e) {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: "Failed to parse Unit Video Cart: $e",
        );
      }
    }

    return response;
  }

  Future<NetworkResponse> removeSingleVideoFromCart(String cartItemId) async {
    final token = LocalStorageService.getString(LocalStorageService.token);

    if (token == null || token.isEmpty) {
      return NetworkResponse(
        statusCode: 401,
        isSuccess: false,
        errorMessage: "Authentication required. Please login again.",
      );
    }

    final response = await _caller.deleteRequest(
      Urls.removeSingleVideoFromCart(cartItemId),
      token: token,
    );

    if (response.isSuccess && response.responseData != null) {
      try {
        final data = response.responseData;

        if (data is Map<String, dynamic>) {
          final cartData = data['data'];

          if (cartData is Map<String, dynamic>) {
            final model = UnitVideoCartModel.fromJson(cartData);

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
              "Invalid response format: expected data Map but got ${cartData.runtimeType}",
            );
          }
        } else {
          return NetworkResponse(
            statusCode: response.statusCode,
            isSuccess: false,
            errorMessage:
            "Invalid response format: expected Map but got ${data.runtimeType}",
          );
        }
      } catch (e) {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: "Failed to parse Remove Cart Item Response: $e",
        );
      }
    }

    return response;
  }

  Future<NetworkResponse> clearUnitVideoCart() async {
    final token = LocalStorageService.getString(LocalStorageService.token);

    if (token == null || token.isEmpty) {
      return NetworkResponse(
        statusCode: 401,
        isSuccess: false,
        errorMessage: "Authentication required. Please login again.",
      );
    }

    final response = await _caller.deleteRequest(
      Urls.unitVideoAllRemoveFromCart,
      token: token,
    );

    if (response.isSuccess && response.responseData != null) {
      try {
        final data = response.responseData;

        if (data is Map<String, dynamic>) {
          final cartData = data['data'];

          if (cartData is Map<String, dynamic>) {
            final model = UnitVideoCartModel.fromJson(cartData);

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
              "Invalid response format: expected data Map but got ${cartData.runtimeType}",
            );
          }
        } else {
          return NetworkResponse(
            statusCode: response.statusCode,
            isSuccess: false,
            errorMessage:
            "Invalid response format: expected Map but got ${data.runtimeType}",
          );
        }
      } catch (e) {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: "Failed to parse Clear Cart Response: $e",
        );
      }
    }

    return response;
  }
}