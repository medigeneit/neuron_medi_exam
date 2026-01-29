// open_exam_list_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'package:medi_exam/data/models/open_exam_list_model.dart';
import 'package:medi_exam/data/services/open_exam_list_service.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/presentation/utils/routes.dart';

import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';

// ▼ Reuse the SAME dialog + model + colors you already have
import 'package:medi_exam/data/models/exam_property_model.dart';
import 'package:medi_exam/data/services/exam_property_service.dart';
import 'package:medi_exam/data/utils/urls.dart';
import 'package:medi_exam/presentation/widgets/exam_overview_dialog.dart';

import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';

// <<< IMPORTANT: bring in routeObserver just like your DoctorScheduleScreen >>>
import 'package:medi_exam/main.dart';

// item widget
import 'package:medi_exam/presentation/widgets/open_exam_item_widget.dart';

class OpenExamListScreen extends StatefulWidget {
  const OpenExamListScreen({Key? key}) : super(key: key);

  @override
  State<OpenExamListScreen> createState() => _OpenExamListScreenState();
}

class _OpenExamListScreenState extends State<OpenExamListScreen>
    with WidgetsBindingObserver, RouteAware {
  final _logger = Logger();
  final _service = OpenExamListService();

  // Reuse the same service to fetch the free exam property via URL
  final ExamPropertyService _examPropertyService = ExamPropertyService();

  String url = '';

  bool _loading = true;
  bool _refreshing = false; // background (silent) refresh flag
  String _error = '';
  OpenExamListModel _model = OpenExamListModel(items: const []);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _readArgs();
    _initialLoad();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Called when coming back to this screen (e.g., popped next route)
  @override
  void didPopNext() {
    _refreshData(silent: true);
  }

  // App comes back to foreground -> silent refresh
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData(silent: true);
    }
  }

  void _readArgs() {
    final args = Get.arguments ?? {};
    url = (args['url'] ?? '').toString();
  }

  // initial load (shows loading)
  Future<void> _initialLoad() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    await _callApi();
  }

  // background refresh helper
  Future<void> _refreshData({bool silent = false}) async {
    if (silent) {
      setState(() {
        _refreshing = true;
      });
      await _callApi();
      if (!mounted) return;
      setState(() {
        _refreshing = false;
      });
    } else {
      await _callApi();
    }
  }

  // Pure API call
  Future<void> _callApi() async {
    final NetworkResponse res = await _service.fetchFreeExamList(url);
    if (!mounted) return;

    if (res.isSuccess && res.responseData is OpenExamListModel) {
      setState(() {
        _model = res.responseData as OpenExamListModel;
        _loading = false;
        _error = '';
      });
    } else {
      setState(() {
        _loading = false;
        _error = res.errorMessage ?? 'Failed to load exams';
      });
    }
  }

  Future<void> _fetch() async {
    await _refreshData(silent: false);
  }

  void _handleItemTap(OpenExamModel exam, OpenExamStatus status) async {
    switch (status) {
      case OpenExamStatus.available:
      case OpenExamStatus.continueExam:
        await _openFreeExamOverview(exam);
        break;

      case OpenExamStatus.checkResult:
        final examId = exam.examId;
        if (examId != null && examId.toString().isNotEmpty) {
          final data = {
            'admissionId': '',
            'examId': examId.toString(),
            'examType': 'openExam',
          };
          Get.toNamed(
            RouteNames.examResult,
            arguments: data,
            preventDuplicates: true,
          );
          return;
        }
        break;
    }
  }

  Future<void> _openFreeExamOverview(OpenExamModel exam) async {
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

      final String url = Urls.openExamProperty(examId);
      final NetworkResponse res =
      await _examPropertyService.fetchExamProperty(url);

      if (!res.isSuccess) {
        throw Exception(res.errorMessage ?? 'Failed to load exam property.');
      }

      late final ExamPropertyModel model;
      if (res.responseData is ExamPropertyModel) {
        model = res.responseData as ExamPropertyModel;
      } else if (res.responseData is Map<String, dynamic>) {
        model = ExamPropertyModel.fromJson(
            res.responseData as Map<String, dynamic>);
      } else {
        throw Exception(
            'Unexpected response data type: ${res.responseData.runtimeType}');
      }

      if (Get.isDialogOpen == true) Get.back();

      final bool? started = await showExamOverviewDialog(
        context,
        model: model,
        url: Urls.openExamQuestion(exam.examId?.toString() ?? ''),
        examType: 'openExam',
        admissionId: '',
      );

      if (started == true) {
        // no-op
      }
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
    return CommonScaffold(
      title: 'Free Exams',
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: LoadingWidget());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded,
                  color: Colors.redAccent, size: 42),
              const SizedBox(height: 12),
              Text(
                _error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetch,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_model.isEmpty) {
      return _EmptyState(onRetry: _fetch);
    }

    return RefreshIndicator(
      onRefresh: _fetch,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ✅ REMOVED: Top courseName glass card section بالكامل

          SliverPadding(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            sliver: SliverList.builder(
              itemCount: _model.items.length,
              itemBuilder: (context, index) {
                final exam = _model.items[index];
                return OpenExamItemWidget(
                  exam: exam,
                  onTap: _handleItemTap,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRetry;
  const _EmptyState({Key? key, required this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF3AC2FF), Color(0xFF7B61FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.psychology_alt_rounded,
                  color: Colors.white, size: 44),
            ),
            const SizedBox(height: 18),
            Text(
              'No Free Exams',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no free exams available yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
