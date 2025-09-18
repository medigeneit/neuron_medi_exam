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
}) async {
  // 1) Check auth
  final authed = await AuthChecker.to.isAuthenticated();

  // 2) If not authed, go to login and wait for a result
  if (!authed) {
    Get.snackbar('Login Required', 'Please log in to enroll in $title.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3));


    final result = await Get.toNamed(
      RouteNames.login,
      arguments: {
        'popOnSuccess': true,
        'returnRoute': null, // Explicitly set to null
        'returnArguments': null,
        'message': "You’re almost there! join us to enroll in '$title'.",
      },
    );



    print('Login/Registration screen returned with result: $result');

    // Check if user completed authentication successfully (either login OR registration)
    if (result == true) {
      // Give a small delay to ensure auth state is updated
      await Future.delayed(const Duration(milliseconds: 500));

      // Verify authentication was successful
      final isNowAuthenticated = await AuthChecker.to.isAuthenticated();
      print('After auth flow, authentication status: $isNowAuthenticated');

      if (isNowAuthenticated) {
        // User successfully authenticated (either login or registration)
        // Now proceed with enrollment
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
        );
      } else {
        print('User completed auth flow but authentication failed');
      }
    } else {
      print('User cancelled auth flow');
      return; // User cancelled or failed authentication
    }
  } else {
    // 3) User is already authenticated - proceed directly to enrollment
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
  }) async {
    print('Starting enrollment process for batchPackageId: $batchPackageId');

    final dialogController = EnrollmentDialogController();

    // One dialog shared by all states; stays centered.
    Get.dialog(
      EnrollmentDialog(controller: dialogController),
      barrierDismissible: false,
    );

    try {
      dialogController.showLoading(
          title: 'Enrolling you…',
          subtitle: "We're reserving your seat 🎟️",
      );

      final service = BatchEnrollmentService();
      final response = await service.enrollInBatch(batchPackageId);

      // -------- Helpers --------
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
        // Direct string or primitive id
        if (v is String && v.trim().isNotEmpty) return v.trim();
        if (v is num) return v.toString();

        // Map shapes: admission: { id }, or admission_id, or id
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

      // -------- Extract fields from response --------
      final dynamic data = response.responseData;

      bool? isEnroll;
      bool alreadyEnrolled = false;
      String? serverMessage;
      dynamic batchPackage;
      String? admissionId;

      if (data is BatchEnrollmentModel) {
        // Expected success model
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
          // Sometimes response may directly be an id or admission payload
          admissionId = _extractAdmissionId(data) ?? _asString(data);
        }
      }

      print('Enrollment response - isEnroll: $isEnroll, admissionId: $admissionId, alreadyEnrolled: $alreadyEnrolled');

      // -------- Branching logic --------

      // A) Already enrolled – flag or message hints
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

      // B) Wrong/unknown batchPackage or explicit negative enroll
      final noBatchPackageInfo = batchPackage == null || batchPackage.toString().isEmpty;
      if (isEnroll == false && noBatchPackageInfo) {
        dialogController.showFailure(
          title: 'Enrollment failed',
          subtitle: serverMessage ?? 'Something went wrong. Please try again.',
        );
        return;
      }

      // C) Success → we mainly need admissionId for payment
      if ((admissionId != null && admissionId.isNotEmpty) || isEnroll == true) {
        dialogController.showSuccess(
          title: 'Enrollment done! 🎉',
          subtitle: 'Taking you to payment…',
        );

        // ⏳ Give users time to read the success
        const successHold = Duration(seconds: 2);
        await Future.delayed(successHold);

        if (Get.isDialogOpen == true) Get.back();

        // Small gap so the route push feels smooth after the dialog closes
        await Future.delayed(const Duration(milliseconds: 150));

        final paymentData = {
          'admissionId': admissionId ?? '', // safe pass-through
        };

        print('Navigating to payment with admissionId: $admissionId');
        Get.toNamed(
          RouteNames.makePayment,
          arguments: paymentData,
          preventDuplicates: true,
        );
        return;
      }

      // D) Fallback failure
      dialogController.showFailure(
        title: 'Enrollment failed',
        subtitle: 'Please try again.',
      );

      // log
      print('Error: ${response.errorMessage}');
    } catch (e) {
      dialogController.showFailure(
        title: 'Something went wrong',
        subtitle: 'Please try again.',
      );

      // log
      print('Error: $e');
    }
  }
}