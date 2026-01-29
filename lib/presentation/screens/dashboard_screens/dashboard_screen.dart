// lib/presentation/screens/dashboard.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'package:medi_exam/main.dart'; // ✅ routeObserver

import 'package:medi_exam/data/models/all_enrolled_batches_model.dart';
import 'package:medi_exam/data/models/exam_property_model.dart';
import 'package:medi_exam/data/models/free_exam_list_model.dart';
import 'package:medi_exam/data/network_response.dart';

import 'package:medi_exam/data/services/all_enrolled_batches_service.dart';
import 'package:medi_exam/data/services/exam_property_service.dart';
import 'package:medi_exam/data/services/free_exam_list_service.dart';
import 'package:medi_exam/data/utils/urls.dart';

import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';

import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';
import 'package:medi_exam/presentation/widgets/enrolled_courses_card_widget.dart';
import 'package:medi_exam/presentation/widgets/exam_overview_dialog.dart';
import 'package:medi_exam/presentation/widgets/free_exam_item_widget.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';
import 'package:medi_exam/presentation/widgets/notification_bell.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with WidgetsBindingObserver, RouteAware {
  final AllEnrolledBatchesService _service = AllEnrolledBatchesService();
  late Future<List<EnrolledBatch>> _batchesFuture;

  bool _hasUnreadNotifications = false;
  bool _refreshing = false;

  bool _subscribed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _batchesFuture = _loadBatches();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_subscribed) return;
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
      _subscribed = true;
    }
  }

  @override
  void dispose() {
    if (_subscribed) routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _silentRefresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _silentRefresh();
    }
  }

  Future<void> _silentRefresh() async {
    if (!mounted) return;
    setState(() => _refreshing = true);

    // recreate the Future so FutureBuilder rebuilds silently
    setState(() => _batchesFuture = _loadBatches());

    try {
      await _batchesFuture;
    } catch (_) {}

    if (mounted) setState(() => _refreshing = false);
  }

  Future<List<EnrolledBatch>> _loadBatches() async {
    final response = await _service.fetchAllEnrolledBatches();
    if (response.isSuccess == true && response.responseData != null) {
      final AllEnrolledBatchesModel model = response.responseData
      is AllEnrolledBatchesModel
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

    return firstBy('completed') ?? firstBy('no payment') ?? firstBy('previous');
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset + 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
/*            // ✅ No big loader during lifecycle/route refresh. Just a tiny hint.
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _refreshing
                  ? Row(
                key: const ValueKey('refreshingRow'),
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Updating…',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
                  : const SizedBox(height: 14, key: ValueKey('spacer')),
            ),

            const SizedBox(height: 10),*/

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                NotificationBell(
                  hasUnread: _hasUnreadNotifications,
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

            // Enrolled Courses
            GlassCard(
              child: Padding(
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
                        FutureBuilder<List<EnrolledBatch>>(
                          future: _batchesFuture,
                          builder: (context, snap) {
                            final loaded =
                                snap.connectionState == ConnectionState.done;
                            final items = snap.data ?? const <EnrolledBatch>[];

                            return OutlinedButton(
                              onPressed: loaded && items.isNotEmpty
                                  ? () {
                                Get.toNamed(
                                  RouteNames.enrolledCourses,
                                  arguments: items,
                                );
                              }
                                  : null,
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

                    FutureBuilder<List<EnrolledBatch>>(
                      future: _batchesFuture,
                      builder: (context, snapshot) {
                        // ✅ Only show loading on very first load (when there's no data yet)
                        final isWaiting =
                            snapshot.connectionState == ConnectionState.waiting;

                        final items = snapshot.data ?? const <EnrolledBatch>[];

                        if (isWaiting && items.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            alignment: Alignment.center,
                            child: const LoadingWidget(),
                          );
                        }

                        final firstActiveCourse = _pickHighlight(items);

                        if (firstActiveCourse != null) {
                          return EnrolledCourseCard(batch: firstActiveCourse);
                        }

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
            ),

            const SizedBox(height: 16),

            // ✅ Customized Exam section MOVED INTO THIS FILE (silent on lifecycle/route)
            DashboardCustomizedExamSection(
              maxItems: 1,
              showSeeAll: true,
              onSeeAll: () {
                Get.toNamed(
                  RouteNames.freeExamList,
                  preventDuplicates: true,
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// ✅ Customized Exam section (moved here)
/// ✅ On RouteAware / lifecycle refresh it will NOT show the big LoadingWidget,
/// it will silently update and (optionally) show a tiny spinner in the header.
class DashboardCustomizedExamSection extends StatefulWidget {
  final int maxItems;
  final bool showSeeAll;
  final VoidCallback? onSeeAll;

  const DashboardCustomizedExamSection({
    super.key,
    this.maxItems = 2,
    this.showSeeAll = true,
    this.onSeeAll,
  });

  @override
  State<DashboardCustomizedExamSection> createState() =>
      _DashboardCustomizedExamSectionState();
}

class _DashboardCustomizedExamSectionState
    extends State<DashboardCustomizedExamSection>
    with WidgetsBindingObserver, RouteAware {
  final _logger = Logger();

  final FreeExamListService _service = FreeExamListService();
  final ExamPropertyService _examPropertyService = ExamPropertyService();

  bool _loading = true; // only for FIRST load
  bool _refreshing = false; // silent refresh indicator
  String _error = '';
  List<FreeExamListItem> _items = const [];

  bool _subscribed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialLoad();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_subscribed) return;
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
      _subscribed = true;
    }
  }

  @override
  void dispose() {
    if (_subscribed) routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _silentRefresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _silentRefresh();
    }
  }

  Future<void> _initialLoad() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    await _callApi(showLoading: true);
  }

  // ✅ This is the key: silent refresh does NOT flip _loading to true
  Future<void> _silentRefresh() async {
    if (!mounted) return;
    if (_items.isEmpty && _error.isNotEmpty) {
      // If we only have error + no items, still keep it silent
    }
    setState(() => _refreshing = true);
    await _callApi(showLoading: false);
    if (mounted) setState(() => _refreshing = false);
  }

  Future<void> _retry() async {
    // manual retry can show loading
    await _callApi(showLoading: true);
  }

  Future<void> _callApi({required bool showLoading}) async {
    if (!mounted) return;

    if (showLoading) {
      setState(() {
        _loading = true;
        _error = '';
      });
    } else {
      // keep UI as-is, just clear error if you want to keep old content visible
      // (we keep error until success, so user knows)
    }

    final NetworkResponse res = await _service.fetchFreeExamList(pageNo: "1");
    if (!mounted) return;

    if (!res.isSuccess || res.responseData == null) {
      setState(() {
        _error = res.errorMessage ?? 'Failed to load customized exams';
        _loading = false; // first load ends
      });
      return;
    }

    try {
      final FreeExamListModel model = res.responseData is FreeExamListModel
          ? (res.responseData as FreeExamListModel)
          : FreeExamListModel.parse(res.responseData);

      final items = model.items ?? const <FreeExamListItem>[];
      final take = items.take(widget.maxItems).toList();

      setState(() {
        _items = take;
        _error = '';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to parse customized exams: $e';
        _loading = false;
      });
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
      final NetworkResponse res =
      await _examPropertyService.fetchExamProperty(url);

      if (!res.isSuccess) {
        throw Exception(res.errorMessage ?? 'Failed to load exam property.');
      }

      late final ExamPropertyModel model;
      if (res.responseData is ExamPropertyModel) {
        model = res.responseData as ExamPropertyModel;
      } else if (res.responseData is Map<String, dynamic>) {
        model =
            ExamPropertyModel.fromJson(res.responseData as Map<String, dynamic>);
      } else {
        throw Exception(
            'Unexpected response data type: ${res.responseData.runtimeType}');
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
              padding:
              const EdgeInsets.only(left: 12, right: 12, bottom: 2, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Customized Exam',
                        style: TextStyle(
                          fontSize: Sizes.bodyText(context),
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // ✅ tiny spinner ONLY during silent refresh (no big loader)
                      if (_refreshing)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
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

            // ✅ Only show LoadingWidget on FIRST load (when no previous content)
            if (_loading && _items.isEmpty && _error.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                child: const LoadingWidget(),
              )
            else if (_error.isNotEmpty && _items.isEmpty)
              Container(
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
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (_items.isEmpty)
                Container(
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
                )
              else
                Column(
                  children: [
                    for (final exam in _items)
                      FreeExamItemWidget(
                        exam: exam,
                        onTap: _handleItemTap,
                      ),
                    const SizedBox(height: 4),

                    // ✅ if refresh failed silently, keep old items and show small error note
                    if (_error.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 16, color: Colors.orange[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Couldn’t update right now. Showing last loaded items.',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange[800],
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _retry,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
