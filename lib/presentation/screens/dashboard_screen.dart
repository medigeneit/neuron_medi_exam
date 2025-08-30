import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/models/enrolled_course_item.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/enrolled_courses_card_widget.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the first active course
    final firstActiveCourse = DemoEnrolledCourses.activeCourses.isNotEmpty
        ? DemoEnrolledCourses.activeCourses.first
        : null;

    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
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

            const SizedBox(height: 12),

            // Enrolled Courses section header
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
                      OutlinedButton(
                        onPressed: () {
                          Get.toNamed(RouteNames.enrolledCourses);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColor.primaryColor,
                          side:  BorderSide(color: AppColor.primaryColor.withOpacity(0.2)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        ),
                        child: const Text(
                          'See All',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Display the first active course if available
                  if (firstActiveCourse != null)
                    EnrolledCourseCard(courseItem: firstActiveCourse)
                  else
                    Container(
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