import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/presentation/utils/routes.dart';


class NetworkCaller {
  final Logger logger;

  NetworkCaller({required this.logger});
  String? token = LocalStorageService.getString(LocalStorageService.token);

  // GET Request
  Future<NetworkResponse> getRequest(
      String url, {
        String? token,
        Map<String, String>? headers,
      }) async {
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
      }
      else if (response.statusCode == 401) {
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
      }

/*      else if (response.statusCode == 423) {
        logger.e('423: Device not verified');
        Get.snackbar(
          "Device is not verified",
          "Please Verify your device",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );


        Get.offNamed(RouteNames.deviceVerification); // 👈 redirect to login
        return NetworkResponse(
          statusCode: 423,
          isSuccess: false,
          errorMessage: "Device is not verified",
        );
      }*/
      else if (response.statusCode == 500) {
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
      }
      else {
        logger.e('Error Response (${response.statusCode}): ${response.body}');

        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: response.body,
        );
      }
    } catch (e) {
      logger.e('GET Exception: $e');
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<NetworkResponse> postRequest(
      String url, {
        Map<String, dynamic>? body,
        String? token,
        Map<String, String>? headers,
      }) async {
    try {
      final combinedHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers, // ✅ allow override or addition
      };

      final encodedBody = jsonEncode(body);
      logger.i('POST: $url');
      logger.d('Request Body: $encodedBody');

      final response = await http.post(Uri.parse(url), headers: combinedHeaders, body: encodedBody);

      logger.i('Response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseData: decoded,
        );
      }
      else if (response.statusCode == 401) {
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


        Get.offAllNamed(RouteNames.login); // 👈 redirect to login
        return NetworkResponse(
          statusCode: 401,
          isSuccess: false,
          errorMessage: "Session expired or logged out",
        );
      }
      else if (response.statusCode == 500) {
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
          errorMessage: "Server Error",
        );
      }
      else {
        logger.e('Error Response (${response.statusCode}): ${response.body}');
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: response.body,
        );
      }
    } catch (e) {
      logger.e('POST Exception: $e');
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }
}
