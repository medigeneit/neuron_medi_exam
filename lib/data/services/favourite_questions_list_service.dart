import 'package:logger/logger.dart';
import 'package:medi_exam/data/models/favourite_questions_list_model.dart';
import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/data/utils/urls.dart';

class FavouriteQuestionsListService {
  final NetworkCaller _caller = NetworkCaller(logger: Logger());

  /// Fetch a single page (kept for reuse/debugging)
  Future<NetworkResponse> fetchFavouriteQuestions({int page = 1}) async {
    final token = LocalStorageService.getString(LocalStorageService.token);

    if (token == null || token.isEmpty) {
      return NetworkResponse(
        statusCode: 401,
        isSuccess: false,
        errorMessage: "Authentication required. Please login again.",
      );
    }

    final String url =
    page <= 1 ? Urls.favourites : "${Urls.favourites}?page=$page";

    final response = await _caller.getRequest(url, token: token);

    if (!response.isSuccess || response.responseData == null) {
      return response;
    }

    try {
      final model = FavouriteQuestionsListModel.parse(response.responseData);

      return NetworkResponse(
        statusCode: response.statusCode,
        isSuccess: true,
        responseData: model,
      );
    } catch (e) {
      return NetworkResponse(
        statusCode: response.statusCode,
        isSuccess: false,
        errorMessage: "Failed to parse FavouriteQuestionsListModel: $e",
      );
    }
  }

  /// ✅ Fetch ALL pages until the API has no more data (next_page_url == null)
  /// Returns one merged FavouriteQuestionsListModel containing ALL items in `data`.
  Future<NetworkResponse> fetchAllFavouriteQuestions({int maxPages = 50}) async {
    final token = LocalStorageService.getString(LocalStorageService.token);

    if (token == null || token.isEmpty) {
      return NetworkResponse(
        statusCode: 401,
        isSuccess: false,
        errorMessage: "Authentication required. Please login again.",
      );
    }

    final allItems = <FavouriteQuestionItem>[];
    FavouriteQuestionsListModel? lastModel;

    // We will use next_page_url when available (best), fallback to ?page=
    String? nextUrl = Urls.favourites;

    // Safety to prevent infinite loop
    final visited = <String>{};
    int pageCount = 0;

    while (nextUrl != null && nextUrl.isNotEmpty) {
      pageCount++;
      if (pageCount > maxPages) {
        break;
      }

      // Prevent infinite loops if server repeats same next_page_url
      if (visited.contains(nextUrl)) {
        break;
      }
      visited.add(nextUrl);

      final response = await _caller.getRequest(nextUrl, token: token);

      if (!response.isSuccess || response.responseData == null) {
        return response; // pass through error
      }

      try {
        final model = FavouriteQuestionsListModel.parse(response.responseData);
        lastModel = model;

        final items = model.data ?? const <FavouriteQuestionItem>[];
        if (items.isNotEmpty) {
          allItems.addAll(items);
        }

        // Stop condition: no next page OR no items returned
        if (model.nextPageUrl == null || model.nextPageUrl!.trim().isEmpty) {
          nextUrl = null;
        } else {
          nextUrl = model.nextPageUrl!.trim();
        }

        // Optional extra safety: if API returns empty data, stop
        if (items.isEmpty) {
          break;
        }
      } catch (e) {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: "Failed to parse FavouriteQuestionsListModel: $e",
        );
      }
    }

    // If nothing parsed, still return empty model safely
    final mergedModel =
    (lastModel ?? const FavouriteQuestionsListModel()).copyWith(
      data: allItems,
    );

    return NetworkResponse(
      statusCode: 200,
      isSuccess: true,
      responseData: mergedModel,
    );
  }
}