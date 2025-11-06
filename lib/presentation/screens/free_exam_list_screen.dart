// free_exam_list_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'package:medi_exam/data/models/free_exam_list_model.dart';
import 'package:medi_exam/data/services/free_exam_list_service.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/presentation/utils/routes.dart';

import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';
import 'package:medi_exam/presentation/widgets/free_exam_item_widget.dart';
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

class FreeExamListScreen extends StatefulWidget {
  const FreeExamListScreen({Key? key}) : super(key: key);

  @override
  State<FreeExamListScreen> createState() => _FreeExamListScreenState();
}

class _FreeExamListScreenState extends State<FreeExamListScreen>
    with WidgetsBindingObserver, RouteAware {
  final _logger = Logger();
  final _service = FreeExamListService();

  // Reuse the same service to fetch the free exam property via URL
  final ExamPropertyService _examPropertyService = ExamPropertyService();

  String _courseId = '';
  String _courseName = '';

  bool _loading = true;
  bool _refreshing = false; // NEW: background (silent) refresh flag
  String _error = '';
  FreeExamListModel _model = FreeExamListModel(items: const []);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // NEW
    _readArgs();
    _initialLoad(); // NEW: same pattern as DoctorScheduleScreen
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe for RouteAware callbacks
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    // Unsubscribe + remove observer
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Called when coming back to this screen (e.g., popped next route)
  @override
  void didPopNext() {
    _refreshData(silent: true); // NEW: silent background refresh
  }

  // App comes back to foreground -> silent refresh
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData(silent: true); // NEW
    }
  }

  void _readArgs() {
    final args = Get.arguments ?? {};
    _courseId = (args['courseId'] ?? '').toString();
    _courseName = (args['courseName'] ?? '').toString();
  }

  // ===== NEW: initial load (shows loading)
  Future<void> _initialLoad() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    await _callApi();
  }

  // ===== NEW: background refresh helper
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
      // Manual / pull-to-refresh path should not change your UI design
      await _callApi();
    }
  }

  // ===== NEW: Pure API call (mirrors DoctorScheduleScreen’s _callApi)
  Future<void> _callApi() async {
    if (_courseId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Missing courseId';
      });
      return;
    }

    final NetworkResponse res = await _service.fetchFreeExamList(_courseId);
    if (!mounted) return;

    if (res.isSuccess && res.responseData is FreeExamListModel) {
      setState(() {
        _model = res.responseData as FreeExamListModel;
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

  // Keep your existing name used in UI, but route it to the new refresh helper
  Future<void> _fetch() async {
    await _refreshData(silent: false);
  }

  void _handleItemTap(FreeExamModel exam, FreeExamStatus status) async {
    switch (status) {
      case FreeExamStatus.available:
      case FreeExamStatus.continueExam:
      // EXACT same behavior as ExamListSection: open overview dialog by
      // fetching ExamProperty first — only difference: we call the URL-based method.
        await _openFreeExamOverview(exam);
        break;

      case FreeExamStatus.checkResult:
        final examId = exam.examId;
        if (examId != null && examId.toString().isNotEmpty) {
          final data = {
            'admissionId': '',
            'examId': examId.toString(),
            'isFreeExam': true,
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

  Future<void> _openFreeExamOverview(FreeExamModel exam) async {
    // (1) loader overlay
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

      // (2) Build the free exam URL and fetch through the SAME service
      final String url = Urls.freeExamProperty(examId);
      final NetworkResponse res = await _examPropertyService.fetchExamProperty(url);

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

      // (3) close loader
      if (Get.isDialogOpen == true) Get.back();

      // (4) Show the SAME overview dialog
      final bool? started = await showExamOverviewDialog(
        context,
        model: model,
        url: Urls.freeExamQuestion(exam.examId?.toString() ?? ''),
        isFreeExam: true,
        admissionId: '',
      );

      // (5) If user tapped "Start exam" — your existing behavior applies
      if (started == true) {
        // no-op / navigate if you add a route later
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
    final title = 'Free Exams';

    return CommonScaffold(
      title: title,
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
              Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 42),
              const SizedBox(height: 12),
              Text(
                _error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetch, // unchanged public method
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_model.isEmpty) {
      return _EmptyState(onRetry: _fetch); // unchanged behavior
    }

    return RefreshIndicator(
      onRefresh: _fetch, // unchanged behavior; now routes to _refreshData(silent: false)
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // --- TOP: Course name on GlassCard ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: GlassCard(
                opacity: 0.15,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Accent round icon with gradient
                      Container(
                        width: Sizes.bigIcon(context),
                        height: Sizes.bigIcon(context),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColor.secondaryGradient,
                        ),
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white,
                          size: Sizes.extraSmallIcon(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Centered text (wrap with Flexible to avoid overflow on small screens)
                      Flexible(
                        child: Text(
                          _courseName.isNotEmpty ? _courseName : 'Course',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: Sizes.smallText(context),
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- Exams list ---
          SliverPadding(
            padding: const EdgeInsets.only(top: 4, bottom: 24),
            sliver: SliverList.builder(
              itemCount: _model.items.length,
              itemBuilder: (context, index) {
                final exam = _model.items[index];
                return FreeExamItemWidget(
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
            // Decorative gradient circle
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
                fontSize: Sizes.bigText(context),
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no free exams available for this course yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Sizes.smallText(context),
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
