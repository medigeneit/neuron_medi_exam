import 'package:logger/logger.dart';
import 'package:medi_exam/data/models/unit_video_add_to_cart_model.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/data/utils/urls.dart';

class UnitVideoAddToCartService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> addUnitVideoToCart({
    required int questionVideoLinkId,
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

    final response = await _caller.postRequest(
      Urls.unitVideoAddToCart,
      body: {
        'question_video_link_id': questionVideoLinkId,
      },
      token: token,
    );

    if (response.isSuccess && response.responseData != null) {
      try {
        final data = response.responseData;

        // API expected format:
        // {
        //   success,
        //   message,
        //   data: {
        //     cart_item: {...},
        //     cart: { items: [...], total_items, total_amount }
        //   }
        // }

        if (data is Map<String, dynamic>) {
          final model = UnitVideoAddToCartModel.fromJson(data);

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
            "Invalid response format: expected Map but got ${data.runtimeType}",
          );
        }
      } catch (e) {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: "Failed to parse Unit Video Add To Cart: $e",
        );
      }
    }

    // pass through non-success or null-body responses
    return response;
  }
}
