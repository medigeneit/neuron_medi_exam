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
      // by trying to connect to a reliable server
      try {
        final response = await http.get(Uri.parse('https://www.google.com')).timeout(const Duration(seconds: 5));
        return response.statusCode == 200;
      } catch (e) {
        return false; // No internet access despite having connection
      }
    } catch (e) {
      logger.e('Network check exception: $e');
      return false;
    }
  }

  // Show network error snackbar
  void _showNetworkErrorSnackbar() {
    // Check if snackbar is already showing to avoid duplicates
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

  // GET Request with network check
  Future<NetworkResponse> getRequest(
      String url, {
        String? token,
        Map<String, String>? headers,
      }) async {
    // Check network connectivity first
    final hasNetwork = await _checkNetworkConnection();
    if (!hasNetwork) {
      _showNetworkErrorSnackbar();
      return NetworkResponse(
        statusCode: -2, // Custom code for no network
        isSuccess: false,
        errorMessage: "No internet connection",
      );
    }

    try {
      final combinedHeaders = {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers, // ✅ allows custom headers from service
      };

      logger.i('GET: $url');
      final response = await http.get(Uri.parse(url), headers: combinedHeaders);

      logger.i('Response (${response.headers})');
      logger.i('Response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseData: decoded,
        );
      } else if (response.statusCode == 401) {
        logger.e('Unauthorized: Token expired or invalid');
        await LocalStorageService.remove(LocalStorageService.token);

        Get.snackbar(
          "Session Expired",
          "Please login again",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );

        Get.offAllNamed(RouteNames.login); // 👈 redirect to login
        return NetworkResponse(
          statusCode: 401,
          isSuccess: false,
          errorMessage: "Session expired or logged out",
        );
      } else if (response.statusCode == 500) {
        logger.e('500: Server Error');
        Get.snackbar(
          "Server Error",
          "Please try again later",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        if (Get.isSnackbarOpen == false && Get.isDialogOpen == false && Get.key.currentState?.canPop() == true) {
          Get.back();
        }
        return NetworkResponse(
          statusCode: 500,
          isSuccess: false,
          errorMessage: "Server Error",
        );
      } else {
        logger.e('Error Response (${response.statusCode}): ${response.body}');

        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: response.body,
        );
      }
    } catch (e) {
      logger.e('GET Exception: $e');

      // Check if it's a network-related exception
      if (e is http.ClientException || e.toString().contains('Network') || e.toString().contains('Socket')) {
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
    // Check network connectivity first
    final hasNetwork = await _checkNetworkConnection();
    if (!hasNetwork) {
      _showNetworkErrorSnackbar();
      return NetworkResponse(
        statusCode: -2, // Custom code for no network
        isSuccess: false,
        errorMessage: "No internet connection",
      );
    }

    try {
      final combinedHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      };

      final encodedBody = jsonEncode(body);
      logger.i('POST: $url');
      logger.d('Request Body: $encodedBody');

      final response = await http.post(
        Uri.parse(url),
        headers: combinedHeaders,
        body: encodedBody,
      );

      logger.i('Response (${response.statusCode}): ${response.body}');

      // Parse response body
      dynamic responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        responseData = response.body; // Fallback to string if not JSON
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseData: responseData,
        );
      } else if (response.statusCode == 409) {
        // Conflict - user already exists
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          responseData: responseData,
          errorMessage: _extractErrorMessage(responseData),
        );
      } else if (response.statusCode == 401) {
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
      } else if (response.statusCode == 500) {
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

      // Check if it's a network-related exception
      if (e is http.ClientException || e.toString().contains('Network') || e.toString().contains('Socket')) {
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

  // Helper method to extract error message from response data
  String _extractErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData['message'] ?? 'Something went wrong';
    } else if (responseData is String) {
      return responseData;
    }
    return 'Something went wrong';
  }
}