import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/models/all_enrolled_batches_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';

import 'fancy_card_background.dart';
import 'dart:math' as math;

class EnrolledCourseCard extends StatelessWidget {
  final EnrolledBatch batch;

  const EnrolledCourseCard({
    super.key,
    required this.batch,
  });

  // --- Helpers: status mapping ---
  String get _status => (batch.paymentStatus ?? '').trim().toLowerCase();

  bool get _isCompleted => _status == 'completed';
  bool get _isNoPayment => _status == 'no payment';
  bool get _isPrevious => _status == 'previous';

  // Fallback title: batchName → courseName → 'Unnamed Batch'
  String get _title {
    if ((batch.batchName ?? '').isNotEmpty) return batch.batchName!;
    if ((batch.courseName ?? '').isNotEmpty) return batch.courseName!;
    return 'Unnamed Batch';
    // If your model exposed displayName getter, you could use it here instead.
  }

  double get _progress {
    final p = (batch.progressCount ?? 0).toDouble();
    // assume 0..100
    return (math.max(0, math.min(100, p))) / 100.0;
  }

  // --- UI style mapping ---
  Gradient get _gradient {
    if (_isCompleted) return AppColor.secondaryGradient;
    if (_isNoPayment) return AppColor.warningGradient;
    return AppColor.silverGradient; // previous / default
  }

  Color get _statusColor {
    if (_isCompleted) return AppColor.purple;
    if (_isNoPayment) return AppColor.orangeColor;
    return AppColor.greyColor; // previous / default
  }

  Color get _textColor {
    if (_isCompleted) return AppColor.whiteColor;
    if (_isNoPayment) return AppColor.whiteColor;
    return Colors.black54; // previous
  }

  // --- Actions ---
  Widget _buildActionButton(BuildContext context) {
    if (_isCompleted) {
      return OutlinedButton(
        onPressed: () {
          // TODO: route to continue learning screen
          // e.g., Get.toNamed(RouteNames.batchDetails, arguments: batch);
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColor.whiteColor.withOpacity(0.7)),
          foregroundColor: AppColor.whiteColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: AppColor.whiteColor,
          ),
        ),
      );
    }

    if (_isNoPayment) {
      return OutlinedButton(
        onPressed: () {
          // TODO: route to payment screen
          final paymentData = {
            'admissionId': batch!.id ?? '', // safe pass-through
          };
          Get.toNamed(
            RouteNames.makePayment,
            arguments: paymentData,
            preventDuplicates: true,
          );
          // e.g., Get.toNamed(RouteNames.payment, arguments: batch);
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColor.whiteColor.withOpacity(0.7)),
          foregroundColor: AppColor.whiteColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: const Text(
          'Pay Now',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: AppColor.whiteColor,
          ),
        ),
      );
    }

    // previous
    return OutlinedButton(
      onPressed: () {
        // TODO: open result screen
        // e.g., Get.toNamed(RouteNames.result, arguments: batch);
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: _textColor.withOpacity(0.7)),
        foregroundColor: _textColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        'Check Result',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: _textColor,
        ),
      ),
    );
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
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                ),
                child: CustomBlobBackground(
                  blobColor: _statusColor,
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
                                    color: _statusColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.school_rounded,
                                    color: _statusColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                 Text(
                                  'Batch Details',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.primaryTextColor,
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

                        _buildDetailCard(
                          icon: Icons.class_rounded,
                          label: 'Course',
                          value: (batch.courseName ?? '—'),
                          color: _statusColor,
                        ),
                        const SizedBox(height: 16),

                        _buildDetailCard(
                          icon: Icons.layers_rounded,
                          label: 'Discipline/Faculty',
                          value: (batch.coursePackageName ?? '—'),
                          color: _statusColor,
                        ),
                        const SizedBox(height: 16),

                /*                      _buildDetailCard(
                          icon: Icons.group_rounded,
                          label: 'Batch',
                          value: (batch.batchName ?? '—'),
                          color: _statusColor,
                        ),
                        const SizedBox(height: 16),*/

                        _buildDetailCard(
                          icon: Icons.calendar_today_rounded,
                          label: 'Session',
                          value: (batch.year ?? '—'),
                          color: _statusColor,
                        ),
                        const SizedBox(height: 16),

                        _buildDetailCard(
                          icon: Icons.confirmation_number_rounded,
                          label: 'Reg No',
                          value: (batch.regNo ?? '—'),
                          color: _statusColor,
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
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
            child: Icon(icon, color: color, size: 18),
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
      gradient: _gradient,
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
                  _title,
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(Icons.info_outline_rounded, color: _textColor, size: 20),
                onPressed: () => _showCourseDetails(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Registration number
          Text(
            'Reg: ${batch.regNo ?? '—'}',
            style: TextStyle(
              color: _textColor,
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
                      color: _textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(_progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: _textColor,
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
                        width: constraints.maxWidth * _progress,
                        decoration: BoxDecoration(
                          color: _textColor,
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            if (!_isPrevious)
                              BoxShadow(
                                color: _textColor.withOpacity(0.5),
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
            child: _buildActionButton(context),
          ),
        ],
      ),
    );
  }
}
