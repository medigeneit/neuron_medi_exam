// lib/presentation/screens/free_exam_list_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'package:medi_exam/data/models/free_exam_list_model.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/services/free_exam_list_service.dart';

import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/free_exam_item_widget.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';

// Reuse the SAME dialog + model + services you already have
import 'package:medi_exam/data/models/exam_property_model.dart';
import 'package:medi_exam/data/services/exam_property_service.dart';
import 'package:medi_exam/data/utils/urls.dart';
import 'package:medi_exam/presentation/widgets/exam_overview_dialog.dart';

// <<< IMPORTANT: bring in routeObserver just like your other screen >>>
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
  final ExamPropertyService _examPropertyService = ExamPropertyService();

  final ScrollController _scrollController = ScrollController();

  bool _loading = true;
  bool _refreshing = false;
  bool _loadingMore = false;

  String _error = '';

  int _currentPage = 1;
  int _lastPage = 1;

  final List<FreeExamListItem> _items = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
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
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
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

  Future<void> _initialLoad() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    await _loadPage(
      page: 1,
      replace: true,
      showLoading: true,
    );
  }

  Future<void> _refreshData({bool silent = false}) async {
    if (silent) {
      setState(() => _refreshing = true);
      await _loadPage(page: 1, replace: true, showLoading: false);
      if (!mounted) return;
      setState(() => _refreshing = false);
    } else {
      await _loadPage(page: 1, replace: true, showLoading: false);
    }
  }

  Future<void> _fetch() async {
    await _refreshData(silent: false);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_loading || _loadingMore) return;
    if (_currentPage >= _lastPage) return;

    final pos = _scrollController.position;
    const threshold = 260.0;
    if (pos.pixels >= (pos.maxScrollExtent - threshold)) {
      _loadNextPage();
    }
  }

  Future<void> _loadNextPage() async {
    if (_loadingMore || _loading) return;
    if (_currentPage >= _lastPage) return;

    setState(() => _loadingMore = true);

    final nextPage = _currentPage + 1;
    await _loadPage(page: nextPage, replace: false, showLoading: false);

    if (!mounted) return;
    setState(() => _loadingMore = false);
  }

  Future<void> _loadPage({
    required int page,
    required bool replace,
    required bool showLoading,
  }) async {
    if (showLoading) {
      setState(() {
        _loading = true;
        _error = '';
      });
    }

    final NetworkResponse res =
    await _service.fetchFreeExamList(pageNo: page.toString());

    if (!mounted) return;

    if (res.isSuccess && res.responseData is FreeExamListModel) {
      final model = res.responseData as FreeExamListModel;
      final newItems = model.items ?? const <FreeExamListItem>[];

      final newCurrent = model.pagination?.currentPage ?? page;
      final newLast = model.pagination?.lastPage ?? _lastPage;

      setState(() {
        _currentPage = newCurrent;
        _lastPage = newLast;

        if (replace) {
          _items
            ..clear()
            ..addAll(newItems);
        } else {
          // de-dup by exam_id
          final existingIds = _items
              .map((e) => e.examId)
              .whereType<int>()
              .toSet();
          for (final it in newItems) {
            final id = it.examId;
            if (id == null || !existingIds.contains(id)) {
              _items.add(it);
              if (id != null) existingIds.add(id);
            }
          }
        }

        _loading = false;
        _error = '';
      });
    } else {
      // If first page failed -> show full-screen error.
      // If next page failed -> keep current list and show snackbar.
      if (replace) {
        setState(() {
          _loading = false;
          _error = res.errorMessage ?? 'Failed to load free exams';
        });
      } else {
        Get.snackbar(
          'Failed',
          res.errorMessage ?? 'Failed to load next page',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.black,
        );
        _logger.e('Pagination error: ${res.errorMessage}');
      }
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
        examType: "freeExam",
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
    return CommonScaffold(
      title: 'Customized Exams',
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
              const Icon(Icons.error_outline_rounded,
                  color: Colors.redAccent, size: 42),
              const SizedBox(height: 12),
              Text(
                _error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _initialLoad,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return _EmptyState(onRetry: _fetch);
    }

    return RefreshIndicator(
      onRefresh: _fetch,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            sliver: SliverList.builder(
              itemCount: _items.length + (_loadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Center(child: LoadingWidget()),
                  );
                }

                final exam = _items[index];
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
