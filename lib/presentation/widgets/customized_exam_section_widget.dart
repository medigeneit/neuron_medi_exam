// lib/presentation/widgets/customized_exam_section_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'package:medi_exam/data/models/free_exam_list_model.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/services/free_exam_list_service.dart';

import 'package:medi_exam/data/models/exam_property_model.dart';
import 'package:medi_exam/data/services/exam_property_service.dart';
import 'package:medi_exam/data/utils/urls.dart';

import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';

import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';
import 'package:medi_exam/presentation/widgets/exam_overview_dialog.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';

import 'package:medi_exam/presentation/widgets/free_exam_item_widget.dart';

class CustomizedExamSectionWidget extends StatefulWidget {
  final int maxItems;
  final bool showSeeAll;
  final VoidCallback? onSeeAll;

  const CustomizedExamSectionWidget({
    super.key,
    this.maxItems = 2,
    this.showSeeAll = true,
    this.onSeeAll,
  });

  @override
  State<CustomizedExamSectionWidget> createState() =>
      _CustomizedExamSectionWidgetState();
}

class _CustomizedExamSectionWidgetState extends State<CustomizedExamSectionWidget> {
  final _logger = Logger();

  final FreeExamListService _service = FreeExamListService();
  final ExamPropertyService _examPropertyService = ExamPropertyService();

  late Future<List<FreeExamListItem>> _future;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _future = _loadTopItems();
  }

  Future<void> _refresh() async {
    setState(() {
      _error = '';
      _future = _loadTopItems();
    });
    await _future;
  }

  Future<List<FreeExamListItem>> _loadTopItems() async {
    _error = '';
    final NetworkResponse res = await _service.fetchFreeExamList(pageNo: "1");

    if (!res.isSuccess || res.responseData == null) {
      _error = res.errorMessage ?? 'Failed to load customized exams';
      return <FreeExamListItem>[];
    }

    try {
      final FreeExamListModel model = res.responseData is FreeExamListModel
          ? (res.responseData as FreeExamListModel)
          : FreeExamListModel.parse(res.responseData);

      final items = model.items ?? const <FreeExamListItem>[];
      if (items.isEmpty) return <FreeExamListItem>[];

      final take = items.take(widget.maxItems).toList();
      return take;
    } catch (e) {
      _error = 'Failed to parse customized exams: $e';
      return <FreeExamListItem>[];
    }
  }

  void _handleItemTap(FreeExamListItem exam, FreeExamStatus status) async {
    switch (status) {
      case FreeExamStatus.created:
      case FreeExamStatus.running:
        await _freeExamOverview(exam);
        break;

      case FreeExamStatus.completed:
        final examId = exam.examId;
        if (examId != null && examId.toString().isNotEmpty) {
          final data = {
            'admissionId': '',
            'examId': examId.toString(),
            'examType': 'freeExam',
          };
          Get.toNamed(
            RouteNames.examResult,
            arguments: data,
            preventDuplicates: true,
          );
        }
        break;

      case FreeExamStatus.unknown:
      // no-op
        break;
    }
  }

  Future<void> _freeExamOverview(FreeExamListItem exam) async {
    Get.dialog(
      const Center(
        child: CustomBlobBackground(
          backgroundColor: AppColor.whiteColor,
          blobColor: AppColor.purple,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: LoadingWidget(),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final String examId = exam.examId?.toString() ?? '';
      if (examId.isEmpty) {
        throw Exception('Unable to determine exam id for this free exam.');
      }

      final String url = Urls.freeExamProperty(examId);
      final NetworkResponse res = await _examPropertyService.fetchExamProperty(
        url,
      );

      if (!res.isSuccess) {
        throw Exception(res.errorMessage ?? 'Failed to load exam property.');
      }

      late final ExamPropertyModel model;
      if (res.responseData is ExamPropertyModel) {
        model = res.responseData as ExamPropertyModel;
      } else if (res.responseData is Map<String, dynamic>) {
        model = ExamPropertyModel.fromJson(res.responseData as Map<String, dynamic>);
      } else {
        throw Exception('Unexpected response data type: ${res.responseData.runtimeType}');
      }

      if (Get.isDialogOpen == true) Get.back();

      await showExamOverviewDialog(
        context,
        model: model,
        url: Urls.freeExamQuestion(examId),
        examType: 'freeExam',
        admissionId: '',
      );
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      Get.snackbar(
        'Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
      _logger.e('Error loading FREE exam property: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 2, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Customized Exam',
                    style: TextStyle(
                      fontSize: Sizes.bodyText(context),
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  if (widget.showSeeAll)
                    OutlinedButton(
                      onPressed: widget.onSeeAll,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColor.primaryColor,
                        side: BorderSide(
                          color: AppColor.primaryColor.withOpacity(0.2),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
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
                    ),
                ],
              ),
            ),
            const SizedBox(height: 2),

            FutureBuilder<List<FreeExamListItem>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: const LoadingWidget(),
                  );
                }

                final items = snapshot.data ?? const <FreeExamListItem>[];

                if (_error.isNotEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.withOpacity(0.18)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: Colors.redAccent, size: 30),
                        const SizedBox(height: 8),
                        Text(
                          _error,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _refresh,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (items.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
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
                          Icons.quiz_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No customized exams',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    for (final exam in items)
                      FreeExamItemWidget(
                        exam: exam,
                        onTap: _handleItemTap,
                      ),
                    const SizedBox(height: 4),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
