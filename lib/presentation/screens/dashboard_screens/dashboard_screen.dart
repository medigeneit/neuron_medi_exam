import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medi_exam/data/models/all_enrolled_batches_model.dart';
import 'package:medi_exam/data/services/all_enrolled_batches_service.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/enrolled_courses_card_widget.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';
import 'package:medi_exam/presentation/widgets/notification_bell.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final AllEnrolledBatchesService _service = AllEnrolledBatchesService();
  late Future<List<EnrolledBatch>> _batchesFuture;
  bool _hasUnreadNotifications = false; // set true when your API says so


  @override
  void initState() {
    super.initState();
    _batchesFuture = _loadBatches();
  }

  Future<List<EnrolledBatch>> _loadBatches() async {
    final response = await _service.fetchAllEnrolledBatches();
    if (response.isSuccess == true && response.responseData != null) {
      final AllEnrolledBatchesModel model =
      response.responseData is AllEnrolledBatchesModel
          ? response.responseData
          : AllEnrolledBatchesModel.fromJson(
        response.responseData as List<dynamic>,
      );
      return model.enrolledBatches ?? <EnrolledBatch>[];
    }
    return <EnrolledBatch>[];
  }

  EnrolledBatch? _pickHighlight(List<EnrolledBatch> items) {
    String norm(String? s) => (s ?? '').trim().toLowerCase();

    EnrolledBatch? firstBy(String wanted) {
      for (final b in items) {
        if (norm(b.paymentStatus) == wanted) return b;
      }
      return null;
    }

    // Priority: completed → no payment → previous
    return firstBy('completed') ??
        firstBy('no payment') ??
        firstBy('previous');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // LEFT — heading texts
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: Sizes.subTitleText(context),
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Continue your learning journey',
                      style: TextStyle(
                        fontSize: Sizes.normalText(context),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                // RIGHT — notification bell
                NotificationBell(
                  hasUnread: _hasUnreadNotifications, // <- toggle this when API says there are unread items
                  onTap: () {
                   Get.snackbar(
                      'No Notifications',
                      "you don't have any notifications right now",
                      backgroundColor: AppColor.indigo,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.TOP,
                   );
                  },
                ),
              ],
            ),


            const SizedBox(height: 12),

            // Enrolled Courses section
            Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Enrolled Courses',
                        style: TextStyle(
                          fontSize: Sizes.bodyText(context),
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),

                      // SEE ALL — passes fetched data as GetX arguments
                      FutureBuilder<List<EnrolledBatch>>(
                        future: _batchesFuture,
                        builder: (context, snap) {
                          final loaded = snap.connectionState == ConnectionState.done;
                          final items = snap.data ?? const <EnrolledBatch>[];

                          return OutlinedButton(
                            onPressed: loaded && items.isNotEmpty
                                ? () {
                              Get.toNamed(
                                RouteNames.enrolledCourses,
                                arguments: items, // 👈 pass the whole fetched list
                              );
                            }
                                : null, // disabled until loaded (or empty)
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColor.primaryColor,
                              side: BorderSide(
                                color: AppColor.primaryColor.withOpacity(0.2),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                            ),
                            child: const Text(
                              'See All',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Highlight card / empty state
                  FutureBuilder<List<EnrolledBatch>>(
                    future: _batchesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          alignment: Alignment.center,
                          child: const LoadingWidget(),
                        );
                      }

                      final items = snapshot.data ?? const <EnrolledBatch>[];
                      final firstActiveCourse = _pickHighlight(items);

                      if (firstActiveCourse != null) {
                        return EnrolledCourseCard(batch: firstActiveCourse);
                      }

                      // Empty (same as your original look)
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No active courses',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
