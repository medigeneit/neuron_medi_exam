import 'package:logger/logger.dart';
import 'package:medi_exam/data/models/video_link_model.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/data/utils/urls.dart';

class VideoLinkService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> fetchVideoLink(String admissionId, String solveVideoId) async {
    final url = Urls.solveVideo(admissionId, solveVideoId);

    // This endpoint requires authentication
    final token = LocalStorageService.getString(LocalStorageService.token);

    if (token == null || token.isEmpty) {
      return NetworkResponse(
        statusCode: 401,
        isSuccess: false,
        errorMessage: "Authentication required. Please login again.",
      );
    }

    final response = await _caller.getRequest(
      url,
      token: token,
    );

    if (response.isSuccess && response.responseData != null) {
      try {
        // doctor schedule response is a Map<String, dynamic>
        if (response.responseData is Map<String, dynamic>) {
          final model = VideoLinkModel.fromJson(
            response.responseData as Map<String, dynamic>,
          );
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
            "Invalid response format: expected Map but got ${response.responseData.runtimeType}",
          );
        }
      } catch (e) {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: "Failed to parse VideoLinkModel: $e",
        );
      }
    }

    return response;
  }
}