import 'package:logger/logger.dart';
import 'package:medi_exam/data/models/unit_video_model.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/data/utils/urls.dart';

class UnitVideoService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> fetchUnitVideos(String questionId) async {
    // This endpoint requires authentication
    final token = LocalStorageService.getString(LocalStorageService.token);

    if (token == null || token.isEmpty) {
      return NetworkResponse(
        statusCode: 401,
        isSuccess: false,
        errorMessage: "Authentication required. Please login again.",
      );
    }

    final url = Urls.unitVideo(questionId);

    final response = await _caller.getRequest(
      url,
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
        //     question_id,
        //     videos: [...]
        //   }
        // }

        if (data is Map<String, dynamic>) {
          final unitVideoData = data['data'];

          if (unitVideoData is Map<String, dynamic>) {
            final model = UnitVideoModel.fromJson(unitVideoData);

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
              "Invalid response format: expected data Map but got ${unitVideoData.runtimeType}",
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
          errorMessage: "Failed to parse Unit Videos: $e",
        );
      }
    }

    // pass through non-success or null-body responses
    return response;
  }
}