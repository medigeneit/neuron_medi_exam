// lib/data/services/update_profile_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:medi_exam/data/models/update_profile_model.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/data/utils/urls.dart';
import 'package:medi_exam/presentation/utils/routes.dart';


class UpdateProfileService {
  final Logger _logger = Logger();
  final Connectivity _connectivity = Connectivity();


  Future<NetworkResponse> updateProfile({
    required String name,
    required String email,
    File? photo,
  }) async {
    // Auth token
    final token = LocalStorageService.getString(LocalStorageService.token);
    if (token == null || token.isEmpty) {
      return NetworkResponse(
        statusCode: 401,
        isSuccess: false,
        errorMessage: "Authentication required. Please login again.",
      );
    }

    // Network check (mirrors NetworkCaller behavior)
    final hasNetwork = await _checkNetworkConnection();
    if (!hasNetwork) {
      _showNetworkErrorSnackbar();
      return NetworkResponse(
        statusCode: -2,
        isSuccess: false,
        errorMessage: "No internet connection",
      );
    }

    final uri = Uri.parse(Urls.doctorProfileUpdate);

    try {
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll({
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          // Do NOT set Content-Type; http will set proper multipart boundary.
        })
        ..fields['name'] = name
        ..fields['email'] = email;

      if (photo != null) {
        final fileName = photo.path.split(Platform.pathSeparator).last;
        _logger.d('Attaching file: $fileName (${await photo.length()} bytes)');
        request.files.add(
          http.MultipartFile(
            'photo',
            photo.openRead(),
            await photo.length(),
            filename: fileName,
          ),
        );
      }

      _logger.i('POST (multipart): ${Urls.doctorProfileUpdate}');
      final streamedResponse = await request.send();
      final status = streamedResponse.statusCode;
      final bodyText = await streamedResponse.stream.bytesToString();

      _logger.i('Response ($status): $bodyText');

      dynamic decoded;
      try {
        decoded = jsonDecode(bodyText);
      } catch (_) {
        decoded = bodyText; // Fallback to raw string
      }

      // Handle common statuses consistently with NetworkCaller
      if (status == 200 || status == 201) {
        // Parse into model if possible
        UpdateProfileResponse? model;
        if (decoded is Map<String, dynamic>) {
          model = UpdateProfileResponse.fromJson(decoded);
        } else if (decoded is String) {
          model = UpdateProfileResponse.fromJsonString(decoded);
        }
        return NetworkResponse(
          statusCode: status,
          isSuccess: true,
          responseData: model ?? decoded,
        );
      } else if (status == 401) {
        _logger.e('401: Unauthorized: Token expired or invalid');
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
          responseData: decoded,
          errorMessage: "Session expired or logged out",
        );
      } else if (status == 500) {
        _logger.e('500: Server Error');
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
          responseData: decoded,
          errorMessage: "Server Error",
        );
      } else {
        // 4xx, 422 validation, etc.
        return NetworkResponse(
          statusCode: status,
          isSuccess: false,
          responseData: decoded,
          errorMessage: _extractErrorMessage(decoded),
        );
      }
    } catch (e) {
      _logger.e('Multipart POST Exception: $e');

      // Network-ish errors
      final isNetworky = e is http.ClientException ||
          e.toString().contains('Network') ||
          e.toString().contains('Socket') ||
          e.toString().contains('Connection');
      if (isNetworky) {
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

  /* ----------------------------- helpers ----------------------------- */

  Future<bool> _checkNetworkConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }
      try {
        final response = await http
            .get(Uri.parse('https://www.google.com'))
            .timeout(const Duration(seconds: 5));
        return response.statusCode == 200;
      } catch (_) {
        return false;
      }
    } catch (e) {
      _logger.e('Network check exception: $e');
      return false;
    }
  }

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

  String _extractErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      // Try common keys
      final message = responseData['message']?.toString();
      if (message != null && message.isNotEmpty) return message;

      // Validation errors (e.g., Laravel)
      final errors = responseData['errors'];
      if (errors is Map<String, dynamic>) {
        final first = errors.values.cast<dynamic>().firstOrNull;
        if (first is List && first.isNotEmpty) return first.first.toString();
        return errors.values.first.toString();
      }
    } else if (responseData is String && responseData.isNotEmpty) {
      return responseData;
    }
    return 'Something went wrong';
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
