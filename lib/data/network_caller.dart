import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkCaller {
  final Logger logger;
  final Connectivity _connectivity = Connectivity();

  NetworkCaller({required this.logger});

  String? token = LocalStorageService.getString(LocalStorageService.token);

  // Check network connectivity
  Future<bool> _checkNetworkConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();

      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Additional check to see if we can actually reach the internet
      try {
        final response = await http
            .get(Uri.parse('https://www.google.com'))
            .timeout(const Duration(seconds: 5));

        return response.statusCode == 200;
      } catch (e) {
        return false;
      }
    } catch (e) {
      logger.e('Network check exception: $e');
      return false;
    }
  }

  // Show network error snackbar
  void _showNetworkErrorSnackbar() {
    if (!Get.isSnackbarOpen) {
      Get.snackbar(
        "No Internet Connection",
        "Please check your network connection and try again",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
        icon: const Icon(Icons.wifi_off, color: Colors.white),
      );
    }
  }

  dynamic _decodeResponseBody(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  String _extractErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData['message'] ?? 'Something went wrong';
    } else if (responseData is String) {
      return responseData;
    }

    return 'Something went wrong';
  }

  Future<NetworkResponse> _handleUnauthorized({
    dynamic responseData,
  }) async {
    logger.e('401: Unauthorized: Token expired or invalid');

    await LocalStorageService.remove(LocalStorageService.token);

    Get.snackbar(
      "Session Expired",
      "Please login again",
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );

    Get.offAllNamed(RouteNames.login);

    return NetworkResponse(
      statusCode: 401,
      isSuccess: false,
      responseData: responseData,
      errorMessage: "Session expired or logged out",
    );
  }

  NetworkResponse _handleServerError({
    dynamic responseData,
  }) {
    logger.e('500: Server Error');

    Get.snackbar(
      "Server Error",
      "Please try again later",
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );

    return NetworkResponse(
      statusCode: 500,
      isSuccess: false,
      responseData: responseData,
      errorMessage: "Server Error",
    );
  }

  bool _isNetworkException(Object e) {
    return e is http.ClientException ||
        e.toString().contains('Network') ||
        e.toString().contains('Socket');
  }

  Future<NetworkResponse> _noNetworkResponse() async {
    _showNetworkErrorSnackbar();

    return NetworkResponse(
      statusCode: -2,
      isSuccess: false,
      errorMessage: "No internet connection",
    );
  }

  Map<String, String> _buildHeaders({
    String? token,
    Map<String, String>? headers,
    bool hasJsonBody = false,
  }) {
    return {
      if (hasJsonBody) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };
  }

  // GET Request with network check
  Future<NetworkResponse> getRequest(
      String url, {
        String? token,
        Map<String, String>? headers,
      }) async {
    final hasNetwork = await _checkNetworkConnection();

    if (!hasNetwork) {
      return _noNetworkResponse();
    }

    try {
      final combinedHeaders = _buildHeaders(
        token: token,
        headers: headers,
      );

      logger.i('GET: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: combinedHeaders,
      );

      logger.i('Response (${response.headers})');
      logger.i('Response (${response.statusCode}): ${response.body}');

      final responseData = _decodeResponseBody(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseData: responseData,
        );
      } else if (response.statusCode == 401) {
        return await _handleUnauthorized(responseData: responseData);
      } else if (response.statusCode == 500) {
        if (Get.isSnackbarOpen == false &&
            Get.isDialogOpen == false &&
            Get.key.currentState?.canPop() == true) {
          Get.back();
        }

        return _handleServerError(responseData: responseData);
      } else {
        logger.e('Error Response (${response.statusCode}): ${response.body}');

        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          responseData: responseData,
          errorMessage: _extractErrorMessage(responseData),
        );
      }
    } catch (e) {
      logger.e('GET Exception: $e');

      if (_isNetworkException(e)) {
        _showNetworkErrorSnackbar();

        return NetworkResponse(
          statusCode: -2,
          isSuccess: false,
          errorMessage: "Network error: Please check your connection",
        );
      }

      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  // POST Request with network check
  Future<NetworkResponse> postRequest(
      String url, {
        Map<String, dynamic>? body,
        String? token,
        Map<String, String>? headers,
      }) async {
    final hasNetwork = await _checkNetworkConnection();

    if (!hasNetwork) {
      return _noNetworkResponse();
    }

    try {
      final combinedHeaders = _buildHeaders(
        token: token,
        headers: headers,
        hasJsonBody: true,
      );

      final encodedBody = jsonEncode(body);

      logger.i('POST: $url');
      logger.d('Request Body: $encodedBody');

      final response = await http.post(
        Uri.parse(url),
        headers: combinedHeaders,
        body: encodedBody,
      );

      logger.i('Response (${response.statusCode}): ${response.body}');

      final responseData = _decodeResponseBody(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseData: responseData,
        );
      } else if (response.statusCode == 409) {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          responseData: responseData,
          errorMessage: _extractErrorMessage(responseData),
        );
      } else if (response.statusCode == 401) {
        return await _handleUnauthorized(responseData: responseData);
      } else if (response.statusCode == 500) {
        return _handleServerError(responseData: responseData);
      } else {
        logger.e('Error Response (${response.statusCode}): ${response.body}');

        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          responseData: responseData,
          errorMessage: _extractErrorMessage(responseData),
        );
      }
    } catch (e) {
      logger.e('POST Exception: $e');

      if (_isNetworkException(e)) {
        _showNetworkErrorSnackbar();

        return NetworkResponse(
          statusCode: -2,
          isSuccess: false,
          errorMessage: "Network error: Please check your connection",
        );
      }

      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        responseData: null,
        errorMessage: e.toString(),
      );
    }
  }

  // DELETE Request with network check
  Future<NetworkResponse> deleteRequest(
      String url, {
        Map<String, dynamic>? body,
        String? token,
        Map<String, String>? headers,
      }) async {
    final hasNetwork = await _checkNetworkConnection();

    if (!hasNetwork) {
      return _noNetworkResponse();
    }

    try {
      final combinedHeaders = _buildHeaders(
        token: token,
        headers: headers,
        hasJsonBody: body != null,
      );

      logger.i('DELETE: $url');

      final http.Response response;

      if (body != null) {
        final encodedBody = jsonEncode(body);
        logger.d('Request Body: $encodedBody');

        response = await http.delete(
          Uri.parse(url),
          headers: combinedHeaders,
          body: encodedBody,
        );
      } else {
        response = await http.delete(
          Uri.parse(url),
          headers: combinedHeaders,
        );
      }

      logger.i('Response (${response.statusCode}): ${response.body}');

      final responseData = _decodeResponseBody(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseData: responseData,
        );
      } else if (response.statusCode == 401) {
        return await _handleUnauthorized(responseData: responseData);
      } else if (response.statusCode == 500) {
        return _handleServerError(responseData: responseData);
      } else {
        logger.e('Error Response (${response.statusCode}): ${response.body}');

        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          responseData: responseData,
          errorMessage: _extractErrorMessage(responseData),
        );
      }
    } catch (e) {
      logger.e('DELETE Exception: $e');

      if (_isNetworkException(e)) {
        _showNetworkErrorSnackbar();

        return NetworkResponse(
          statusCode: -2,
          isSuccess: false,
          errorMessage: "Network error: Please check your connection",
        );
      }

      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        responseData: null,
        errorMessage: e.toString(),
      );
    }
  }
}