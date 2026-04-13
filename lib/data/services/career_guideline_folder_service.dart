import 'package:logger/logger.dart';
import 'package:medi_exam/data/models/career_guideline_folder_model.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/data/utils/urls.dart';

class CareerGuidelineFolderService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  Future<NetworkResponse> fetchCareerGuidelineFolder({
    required String folderId,
    int page = 1,
  }) async {
    final url = '${Urls.careerGuidelineFolder(folderId)}?page=$page';

    // Token is optional
    final token = LocalStorageService.getString(LocalStorageService.token);

    final response = await _caller.getRequest(
      url,
      token: token,
    );

    if (response.isSuccess && response.responseData != null) {
      try {
        if (response.responseData is Map<String, dynamic>) {
          final model = CareerGuidelineFolderModel.fromJson(
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
          errorMessage: "Failed to parse CareerGuidelineFolderModel: $e",
        );
      }
    }

    return response;
  }

  Future<NetworkResponse> fetchFirstPage(String folderId) async {
    return fetchCareerGuidelineFolder(folderId: folderId, page: 1);
  }

  Future<NetworkResponse> fetchNextPage({
    required String folderId,
    required CareerGuidelinePagination pagination,
  }) async {
    if (!pagination.hasNextPage) {
      return NetworkResponse(
        statusCode: 400,
        isSuccess: false,
        errorMessage: 'No more pages available',
      );
    }

    return fetchCareerGuidelineFolder(
      folderId: folderId,
      page: pagination.nextPage!,
    );
  }

  Future<NetworkResponse> fetchPreviousPage({
    required String folderId,
    required CareerGuidelinePagination pagination,
  }) async {
    if (!pagination.hasPreviousPage) {
      return NetworkResponse(
        statusCode: 400,
        isSuccess: false,
        errorMessage: 'No previous page available',
      );
    }

    return fetchCareerGuidelineFolder(
      folderId: folderId,
      page: pagination.previousPage!,
    );
  }
}