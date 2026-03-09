import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/models/batch_enrollment_model.dart';
import 'package:medi_exam/data/services/batch_enrollment_service.dart';
import 'package:medi_exam/data/utils/auth_checker.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/widgets/enrollment_dialog.dart';

Future<void> onEnrollPressed({
  required String batchId,
  required String coursePackageId,
  required String batchPackageId,
  required String title,
  required String subTitle,
  required String imageUrl,
  required String time,
  required String days,
  required String startDate,
  required bool isFreeBatch,
}) async {
  final authed = await AuthChecker.to.isAuthenticated();

  if (!authed) {
    Get.snackbar(
      'Login Required',
      'Please log in to enroll in $title.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );

    final result = await Get.toNamed(
      RouteNames.login,
      arguments: {
        'popOnSuccess': true,
        'returnRoute': null,
        'returnArguments': null,
        'message': "You’re almost there! Join us to enroll in '$title'.",
      },
    );

    print('Login/Registration screen returned with result: $result');

    if (result == true) {
      await Future.delayed(const Duration(milliseconds: 500));

      final isNowAuthenticated = await AuthChecker.to.isAuthenticated();
      print('After auth flow, authentication status: $isNowAuthenticated');

      if (isNowAuthenticated) {
        await PaymentNavigator.go(
          batchId: batchId,
          coursePackageId: coursePackageId,
          batchPackageId: batchPackageId,
          title: title,
          subTitle: subTitle,
          imageUrl: imageUrl,
          time: time,
          days: days,
          startDate: startDate,
          isFreeBatch: isFreeBatch,
        );
      } else {
        print('User completed auth flow but authentication failed');
      }
    } else {
      print('User cancelled auth flow');
      return;
    }
  } else {
    await PaymentNavigator.go(
      batchId: batchId,
      coursePackageId: coursePackageId,
      batchPackageId: batchPackageId,
      title: title,
      subTitle: subTitle,
      imageUrl: imageUrl,
      time: time,
      days: days,
      startDate: startDate,
      isFreeBatch: isFreeBatch,
    );
  }
}

class PaymentNavigator {
  PaymentNavigator._();

  static Future<void> go({
    required String batchId,
    required String coursePackageId,
    required String batchPackageId,
    required String title,
    required String subTitle,
    required String imageUrl,
    required String time,
    required String days,
    required String startDate,
    required bool isFreeBatch,
  }) async {
    print('Starting enrollment process for batchPackageId: $batchPackageId');

    final dialogController = EnrollmentDialogController();

    Get.dialog(
      EnrollmentDialog(controller: dialogController),
      barrierDismissible: false,
    );

    try {
      dialogController.showLoading(
        title: 'Enrolling you…',
        subtitle: isFreeBatch
            ? "We're confirming your free seat 🎟️"
            : "We're reserving your seat 🎟️",
      );

      final service = BatchEnrollmentService();
      final response = await service.enrollInBatch(batchPackageId);

      bool? _asBool(dynamic v) {
        if (v is bool) return v;
        if (v is num) return v != 0;
        if (v is String) {
          final s = v.trim().toLowerCase();
          if (s == 'true' || s == 'yes' || s == '1') return true;
          if (s == 'false' || s == 'no' || s == '0') return false;
        }
        return null;
      }

      Map<String, dynamic>? _asMap(dynamic v) {
        if (v is Map<String, dynamic>) return v;
        if (v is String) {
          try {
            final decoded = jsonDecode(v);
            return decoded is Map<String, dynamic> ? decoded : null;
          } catch (_) {}
        }
        return null;
      }

      String? _asString(dynamic v) {
        if (v == null) return null;
        if (v is String) return v;
        return v.toString();
      }

      bool _containsIgnoreCase(String? haystack, List<String> needles) {
        if (haystack == null || haystack.isEmpty) return false;
        final h = haystack.toLowerCase();
        return needles.any((n) => h.contains(n.toLowerCase()));
      }

      String? _extractAdmissionId(dynamic v) {
        if (v is String && v.trim().isNotEmpty) return v.trim();
        if (v is num) return v.toString();

        final m = _asMap(v);
        if (m == null) return null;

        final fromAdmission = m['admission'];
        if (fromAdmission is Map) {
          final id = fromAdmission['id'];
          if (id != null && id.toString().isNotEmpty) {
            return id.toString();
          }
        }

        final direct = m['admission_id'] ?? m['id'];
        if (direct != null && direct.toString().isNotEmpty) {
          return direct.toString();
        }
        return null;
      }

      final dynamic data = response.responseData;

      bool? isEnroll;
      bool alreadyEnrolled = false;
      String? serverMessage;
      dynamic batchPackage;
      String? admissionId;

      if (data is BatchEnrollmentModel) {
        admissionId = data.admission?.id?.toString();
        isEnroll = true;
      } else {
        final map = _asMap(data);
        if (map != null) {
          isEnroll = _asBool(map['is_enroll']);
          alreadyEnrolled = _asBool(map['already_enrolled']) ?? false;
          serverMessage = _asString(map['message']);
          batchPackage = map['batch_package'];
          admissionId = _extractAdmissionId(map);
        } else {
          admissionId = _extractAdmissionId(data) ?? _asString(data);
        }
      }

      print(
        'Enrollment response - isEnroll: $isEnroll, admissionId: $admissionId, alreadyEnrolled: $alreadyEnrolled',
      );

      final looksAlreadyEnrolled = alreadyEnrolled ||
          _containsIgnoreCase(
            serverMessage,
            const [
              'already enrolled',
              'already filled admission form',
              'already registered',
            ],
          );

      if (looksAlreadyEnrolled) {
        dialogController.showInfo(
          title: "You're already enrolled",
          subtitle: serverMessage ??
              'Dear doctor, you have already filled admission form for this batch.',
        );
        await Future.delayed(const Duration(milliseconds: 2000));
        if (Get.isDialogOpen == true) Get.back();
        Get.offAllNamed(RouteNames.navBar, arguments: 0);
        return;
      }

      final noBatchPackageInfo =
          batchPackage == null || batchPackage.toString().isEmpty;

      if (isEnroll == false && noBatchPackageInfo) {
        dialogController.showFailure(
          title: 'Enrollment failed',
          subtitle: serverMessage ?? 'Something went wrong. Please try again.',
        );
        return;
      }

      if ((admissionId != null && admissionId.isNotEmpty) || isEnroll == true) {
        if (isFreeBatch) {
          dialogController.showSuccess(
            title: 'Enrollment completed! 🎉',
            subtitle:
            'This batch is free. No payment is needed. Taking you to home…',
          );

          await Future.delayed(const Duration(seconds: 2));

          if (Get.isDialogOpen == true) Get.back();

          await Future.delayed(const Duration(milliseconds: 150));

          Get.offAllNamed(RouteNames.navBar, arguments: 0);
          return;
        }

        dialogController.showSuccess(
          title: 'Enrollment done! 🎉',
          subtitle: 'Taking you to payment…',
        );

        await Future.delayed(const Duration(seconds: 2));

        if (Get.isDialogOpen == true) Get.back();

        await Future.delayed(const Duration(milliseconds: 150));

        final paymentData = {
          'admissionId': admissionId ?? '',
        };

        print('Navigating to payment with admissionId: $admissionId');
        Get.toNamed(
          RouteNames.makePayment,
          arguments: paymentData,
          preventDuplicates: true,
        );
        return;
      }

      dialogController.showFailure(
        title: 'Enrollment failed',
        subtitle: 'Please try again.',
      );

      print('Error: ${response.errorMessage}');
    } catch (e) {
      dialogController.showFailure(
        title: 'Something went wrong',
        subtitle: 'Please try again.',
      );

      print('Error: $e');
    }
  }
}