// free_exam_list_public_service.dart

import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/urls.dart';
import 'package:medi_exam/data/models/free_exam_list_public_model.dart';
import 'package:logger/logger.dart';

class FreeExamListPublicService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> fetchFreeExamPublicList() async {
    const url = Urls.freeExamPublicList;

    final response = await _caller.getRequest(
      url,
      // Token is optional as this is public data
    );

    if (response.isSuccess && response.responseData != null) {
      try {
        // API returns a List<dynamic> (top-level JSON array)
        if (response.responseData is List) {
          final model =
          FreeExamListPublicModel.fromJsonList(response.responseData as List);
          return NetworkResponse(
            statusCode: response.statusCode,
            isSuccess: true,
            responseData: model,
          );
        }

        // Sometimes API may wrap list in { "data": [...] }
        if (response.responseData is Map) {
          final model = FreeExamListPublicModel.fromJsonList(response.responseData);
          if (model.isNotEmpty) {
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
            "Invalid response format: expected List or {data: List} but got Map without a usable 'data' list",
          );
        }

        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage:
          "Invalid response format: expected List but got ${response.responseData.runtimeType}",
        );
      } catch (e) {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: "Failed to parse FreeExamListModel: $e",
        );
      }
    }

    return response;
  }
}
