import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/urls.dart';
import 'package:medi_exam/data/models/notice_list_model.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:logger/logger.dart';

class NoticeListService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> fetchNotices() async {
    final url = Urls.noticeList;

    // Token is optional as this is public data, but we'll include it if available
    final token = LocalStorageService.getString(LocalStorageService.token);

    final response = await _caller.getRequest(
      url,
      token: token, // Token is optional, can be null
    );

    if (response.isSuccess && response.responseData != null) {
      try {
        // The response is a Map<String, dynamic> containing a 'data' list
        if (response.responseData is Map<String, dynamic>) {
          final model = NoticeListModel.fromJson(
              response.responseData as Map<String, dynamic>);
          return NetworkResponse(
            statusCode: response.statusCode,
            isSuccess: true,
            responseData: model,
          );
        } else {
          return NetworkResponse(
            statusCode: response.statusCode,
            isSuccess: false,
            errorMessage: "Invalid response format: expected Map but got ${response.responseData.runtimeType}",
          );
        }
      } catch (e) {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: "Failed to parse NoticeListModel: $e",
        );
      }
    }

    return response;
  }
}