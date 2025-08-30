import 'package:flutter/material.dart';
import 'package:medi_exam/data/models/enrolled_course_item.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';

import 'fancy_card_background.dart';

class EnrolledCourseCard extends StatelessWidget {
  final EnrolledCourseItem courseItem;

  const EnrolledCourseCard({
    super.key,
    required this.courseItem,
  });

  Gradient _getGradientByStatus(CourseStatus status) {
    switch (status) {
      case CourseStatus.active:
        return AppColor.secondaryGradient;
      case CourseStatus.unpaid:
        return AppColor.warningGradient;
      case CourseStatus.previous:
        return AppColor.silverGradient;
    }
  }

  Color _getStatusColor(CourseStatus status) {
    switch (status) {
      case CourseStatus.active:
        return AppColor.primaryColor;
      case CourseStatus.unpaid:
        return AppColor.purple;
      case CourseStatus.previous:
        return AppColor.greyColor;
    }
  }
  Color _getTextColor(CourseStatus status) {
    switch (status) {
      case CourseStatus.active:
        return AppColor.whiteColor;
      case CourseStatus.unpaid:
        return AppColor.whiteColor;
      case CourseStatus.previous:
        return Colors.black54;
    }
  }

  Widget _buildActionButton(CourseStatus status, BuildContext context) {
    switch (status) {
      case CourseStatus.active:
        return OutlinedButton(
          onPressed: courseItem.onContinue,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColor.whiteColor.withOpacity(0.7)),
            foregroundColor: AppColor.whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text(
            'Continue',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppColor.whiteColor),
          ),
        );
      case CourseStatus.unpaid:
        return OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColor.whiteColor.withOpacity(0.7)),
            foregroundColor: AppColor.whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text(
            'Pay Now',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppColor.whiteColor),
          ),
        );
      case CourseStatus.previous:
        return OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: _getTextColor(courseItem.status).withOpacity(0.7)),
            foregroundColor: _getTextColor(courseItem.status),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(
            'Check Result',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: _getTextColor(courseItem.status)),
          ),
        );
    }
  }

  void _showCourseDetails(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      barrierDismissible: true,
      barrierLabel: 'Course Details',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: animation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(20),
              child: CustomBlobBackground(
                blobColor: _getStatusColor(courseItem.status),
                backgroundColor: AppColor.whiteColor,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with icon and title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(courseItem.status)
                                      .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.school_rounded,
                                  color: _getStatusColor(courseItem.status),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Batch Details',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 20),
                            ),
                            onPressed: () => Navigator.pop(context),
                            color: AppColor.greyColor,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Course info with improved styling
                      _buildDetailCard(
                        icon: Icons.class_rounded,
                        label: 'Course',
                        value: courseItem.courseName,
                        color: _getStatusColor(courseItem.status),
                      ),

                      const SizedBox(height: 16),

                      _buildDetailCard(
                        icon: Icons.medical_services_rounded,
                        label: 'Discipline',
                        value: courseItem.disciplineName,
                        color: _getStatusColor(courseItem.status),
                      ),

                      const SizedBox(height: 16),

                      _buildDetailCard(
                        icon: Icons.schedule_rounded,
                        label: 'Session',
                        value: courseItem.sessionName,
                        color: _getStatusColor(courseItem.status),
                      ),

                      const SizedBox(height: 16),

                      _buildDetailCard(
                        icon: Icons.confirmation_number_rounded,
                        label: 'Reg No',
                        value: courseItem.regNo,
                        color: _getStatusColor(courseItem.status),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

// Enhanced detail row with card style
  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return FancyBackground(
      gradient: _getGradientByStatus(courseItem.status),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with title and info button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  courseItem.title,
                  style: TextStyle(
                    color:  _getTextColor(courseItem.status),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon:  Icon(Icons.info_outline_rounded,
                    color: _getTextColor(courseItem.status), size: 20),
                onPressed: () => _showCourseDetails(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Registration number
          Text(
            'Reg: ${courseItem.regNo}',
            style: TextStyle(
              color: _getTextColor(courseItem.status),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 16),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(
                      color: _getTextColor(courseItem.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(courseItem.progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: _getTextColor(courseItem.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Stack(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) => Container(
                        width: constraints.maxWidth * courseItem.progress,
                        decoration: BoxDecoration(
                          color: courseItem.status == CourseStatus.previous
                              ? _getTextColor(courseItem.status)
                              : _getTextColor(courseItem.status),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            if (courseItem.status != CourseStatus.previous)
                              BoxShadow(
                                color: _getTextColor(courseItem.status).withOpacity(0.5),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Align(
              alignment: Alignment.center,
              child: _buildActionButton(courseItem.status, context)),
        ],
      ),
    );
  }
}
