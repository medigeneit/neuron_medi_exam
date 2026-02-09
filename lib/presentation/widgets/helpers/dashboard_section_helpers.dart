import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:medi_exam/data/models/exam_property_model.dart';
import 'package:medi_exam/data/models/favourite_questions_list_model.dart';
import 'package:medi_exam/data/models/free_exam_list_model.dart';
import 'package:medi_exam/data/models/wrong_skipped_qus_model.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/services/exam_property_service.dart';
import 'package:medi_exam/data/services/favourite_questions_list_service.dart';
import 'package:medi_exam/data/services/free_exam_list_service.dart';
import 'package:medi_exam/data/services/wrong_skipped_qus_service.dart';
import 'package:medi_exam/data/utils/urls.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';
import 'package:medi_exam/presentation/widgets/exam_overview_dialog.dart';
import 'package:medi_exam/presentation/widgets/free_exam_item_widget.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';
import 'package:medi_exam/presentation/widgets/question_action_row.dart';
import 'package:medi_exam/presentation/widgets/units_vs_questions_dialog.dart';

import '../../../main.dart';

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
        model = ExamPropertyModel.fromJson(
            res.responseData as Map<String, dynamic>);
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
                              "Couldn't update right now. Showing last loaded items.",
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

////////////////--------------------------------------------------///////////////////////////////////////////
////////////////--------------------------------------------------///////////////////////////////////////////
////////////////--------------------------------------------------///////////////////////////////////////////

class DashboardWrongSkippedSection extends StatefulWidget {
  final void Function(WrongSkippedQusModel model)? onOpen;
  final void Function(WrongSkippedQusModel? model)? onModelLoaded;

  const DashboardWrongSkippedSection({
    super.key,
    this.onOpen,
    this.onModelLoaded,
  });

  @override
  State<DashboardWrongSkippedSection> createState() =>
      _DashboardWrongSkippedSectionState();
}

class _DashboardWrongSkippedSectionState
    extends State<DashboardWrongSkippedSection>
    with WidgetsBindingObserver, RouteAware {
  final WrongSkippedQusService _service = WrongSkippedQusService();

  bool _loading = true;
  bool _refreshing = false;
  String _error = '';
  WrongSkippedQusModel? _model;
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
    await _callApi(showLoading: true);
  }

  Future<void> _silentRefresh() async {
    if (!mounted) return;
    setState(() => _refreshing = true);
    await _callApi(showLoading: false);
    if (mounted) setState(() => _refreshing = false);
  }

  Future<void> _callApi({required bool showLoading}) async {
    if (!mounted) return;
    if (showLoading) {
      setState(() {
        _loading = true;
        _error = '';
      });
    }

    final res = await _service.fetchWrongSkippedQusSummary();
    if (!mounted) return;

    if (!res.isSuccess || res.responseData == null) {
      setState(() {
        _error = res.errorMessage ?? 'Sync failed';
        _loading = false;
      });
      return;
    }

    setState(() {
      _model = res.responseData is WrongSkippedQusModel
          ? res.responseData
          : WrongSkippedQusModel.parse(res.responseData);
      _error = '';
      _loading = false;
    });

    widget.onModelLoaded?.call(_model);
  }

  void _openTip() {
    UnitsVsQuestionsDialog.show(
      context,
      blobColor: AppColor.indigo,
      backgroundColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (_model != null) widget.onOpen?.call(_model!);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading && _model == null) {
      return const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final model = _model ?? const WrongSkippedQusModel();

    // Units-based (primary)
    final totalUnits = model.computedTotalQuestionUnits;
    final answeredUnits = model.totalAnsweredQuestionUnits ?? 0;
    final wrongUnits = model.totalWrongAnswerUnits ?? 0;
    final skippedUnits = model.totalUnansweredQuestionUnits ?? 0;
    final correctUnits = math.max(0, answeredUnits - wrongUnits);

    // Question-based (secondary)
    final totalQ = model.computedTotalQuestions;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            // Donut based on UNITS
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 70,
                  height: 70,
                  child: CustomPaint(
                    painter: _ModernDonutPainter(
                      correct: correctUnits,
                      wrong: wrongUnits,
                      skipped: skippedUnits,
                      total: totalUnits == 0 ? 1 : totalUnits,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$totalUnits',
                      style: TextStyle(
                        fontSize: Sizes.smallText(context),
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'TOTAL\nUnits',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: Sizes.extraSmallText(context),
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 20),

            // Information Side
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Performance',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: Color(0xFF2D3142),
                                ),
                              ),
                              const SizedBox(width: 6),

                              // ✅ Tip icon button
                              InkWell(
                                onTap: _openTip,
                                borderRadius: BorderRadius.circular(999),
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Icon(
                                    Icons.info_outline_rounded,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Total Question: $totalQ',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: Sizes.verySmallText(context),
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      if (_refreshing)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 1.5),
                        )
                      else
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: Colors.grey.shade400,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StatItem(
                        label: 'Correct\nUnits',
                        value: correctUnits,
                        color: Colors.green,
                      ),
                      _vDivider(),
                      _StatItem(
                        label: 'Wrong\nUnits',
                        value: wrongUnits,
                        color: Colors.red,
                      ),
                      _vDivider(),
                      _StatItem(
                        label: 'Skipped\nUnits',
                        value: skippedUnits,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_error.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _error,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ]
      ],
    );
  }

  Widget _vDivider() => Container(
        height: 15,
        width: 1,
        color: Colors.grey.shade200,
        margin: const EdgeInsets.symmetric(horizontal: 10),
      );
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: Sizes.smallText(context),
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: Sizes.extraSmallText(context),
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            height: 1.15,
          ),
        ),
      ],
    );
  }
}

class _ModernDonutPainter extends CustomPainter {
  final int correct, wrong, skipped, total;

  _ModernDonutPainter({
    required this.correct,
    required this.wrong,
    required this.skipped,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final strokeWidth = 8.0;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - (strokeWidth / 2),
    );

    final bgPaint = Paint()
      ..color = Colors.grey.shade100
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - (strokeWidth / 2), bgPaint);

    final safeTotal = total <= 0 ? 1 : total;

    double startAngle = -math.pi / 2;
    _drawSegment(canvas, rect, startAngle, (correct / safeTotal), Colors.green,
        strokeWidth);
    startAngle += (correct / safeTotal) * 2 * math.pi;

    _drawSegment(
        canvas, rect, startAngle, (wrong / safeTotal), Colors.red, strokeWidth);
    startAngle += (wrong / safeTotal) * 2 * math.pi;

    _drawSegment(canvas, rect, startAngle, (skipped / safeTotal), Colors.orange,
        strokeWidth);
  }

  void _drawSegment(
    Canvas canvas,
    Rect rect,
    double start,
    double sweepPerc,
    Color color,
    double width,
  ) {
    if (sweepPerc <= 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      start + 0.05,
      (sweepPerc * 2 * math.pi) - 0.1,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

////////////////--------------------------------------------------///////////////////////////////////////////
//////////////// ✅ NEW: FAVOURITES SECTION ///////////////////////////////////////////
////////////////--------------------------------------------------///////////////////////////////////////////

class DashboardFavouritesSection extends StatefulWidget {
  final void Function(FavouriteQuestionsListModel model)? onOpen;

  const DashboardFavouritesSection({
    super.key,
    this.onOpen,
  });

  @override
  State<DashboardFavouritesSection> createState() =>
      _DashboardFavouritesSectionState();
}

class _DashboardFavouritesSectionState extends State<DashboardFavouritesSection>
    with
        SingleTickerProviderStateMixin,
        WidgetsBindingObserver,
        RouteAware {
  final FavouriteQuestionsListService _service = FavouriteQuestionsListService();

  bool _loading = true;
  bool _refreshing = false;
  String _error = '';
  FavouriteQuestionsListModel? _model;
  bool _subscribed = false;

  late final AnimationController _iconController;
  late final Animation<double> _iconScale;
  int _lastTotal = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);



    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _iconScale = Tween<double>(begin: 1, end: 1.18).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeOutBack),
    );

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
    _iconController.dispose();
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
    await _callApi(showLoading: true);

  }

  Future<void> _silentRefresh() async {
    if (!mounted) return;
    setState(() => _refreshing = true);
    _playIconPulse();
    await _callApi(showLoading: false);
    if (mounted) setState(() => _refreshing = false);
  }

  void _playIconPulse() {
    if (!_iconController.isAnimating) {
      _iconController.forward(from: 0).then((_) {
        if (mounted) _iconController.reverse();
      });
    }
  }

  Future<void> _callApi({required bool showLoading}) async {
    if (!mounted) return;
    if (showLoading) {
      setState(() {
        _loading = true;
        _error = '';
      });
    }

    final res = await _service.fetchAllFavouriteQuestions();
    if (!mounted) return;

    if (!res.isSuccess || res.responseData == null) {
      setState(() {
        _error = res.errorMessage ?? 'Failed to load favourites';
        _loading = false;
      });
      return;
    }

    final parsed = res.responseData is FavouriteQuestionsListModel
        ? res.responseData as FavouriteQuestionsListModel
        : FavouriteQuestionsListModel.parse(res.responseData);

    // ✅ IMPORTANT: Sync GlobalFavouriteCache from dashboard API result
    final favItems = parsed.data ?? const <FavouriteQuestionItem>[];
    GlobalFavouriteCache.setLoadedIds(
      favItems.map((e) => e.id).whereType<int>(),
    );


    final newTotal = parsed.data?.length ?? 0;
    if (_lastTotal != -1 && newTotal != _lastTotal) {
      _playIconPulse();
    }
    _lastTotal = newTotal;

    setState(() {
      _model = parsed;
      _error = '';
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            AppColor.primaryColor.withOpacity(0.05),
            AppColor.purple.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColor.primaryColor.withOpacity(0.12),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (_model != null) {
                _playIconPulse();
                widget.onOpen?.call(_model!);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading && _model == null) {
      return const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final model = _model ?? const FavouriteQuestionsListModel();
    final totalQuestions = model.data?.length ?? 0;
    final sbaCount = _countByType(model, isSba: true);
    final mcqCount = _countByType(model, isSba: false);

    return Row(
      children: [
        // ✅ Bookmark icon (animated) + tiny badge
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColor.primaryColor,
                AppColor.purple,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColor.primaryColor.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ScaleTransition(
                scale: _iconScale,
                child: const Icon(
                  Icons.bookmark_rounded,
                  size: 28,
                  color: Colors.white,
                ),
              ),

              if (totalQuestions > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
            /*            Icon(
                          Icons.bookmark_rounded,
                          size: 9,
                          color: AppColor.primaryColor,
                        ),
                        const SizedBox(width: 2),*/
                        Text(
                          totalQuestions > 99 ? '99+' : '$totalQuestions',
                          style: TextStyle(
                            fontSize: totalQuestions > 99 ? 7 : 8,
                            fontWeight: FontWeight.w900,
                            color: AppColor.primaryColor,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'My Favourites',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: Sizes.smallText(context),
                          color: AppColor.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (_refreshing)
                        const SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(strokeWidth: 1.5),
                        ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: AppColor.primaryColor.withOpacity(0.6),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // ✅ NOW includes icons for Total / SBA / MCQ
              Row(
                children: [
                  _MiniStat(
                    icon: Icons.bookmark_border_outlined, // total icon
                    iconColor: AppColor.primaryColor,
                    label: 'Total',
                    value: totalQuestions,
                    valueColor: AppColor.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Container(width: 1, height: 12, color: Colors.grey.shade300),
                  const SizedBox(width: 8),
                  _MiniStat(
                    icon: Icons.check_circle_outline, // SBA icon
                    iconColor: Colors.indigo,
                    label: 'SBA',
                    value: sbaCount,
                    valueColor: Colors.indigo,
                  ),
                  const SizedBox(width: 8),
                  Container(width: 1, height: 12, color: Colors.grey.shade300),
                  const SizedBox(width: 8),
                  _MiniStat(
                    icon: Icons.checklist_rounded, // MCQ icon
                    iconColor: Colors.purple,
                    label: 'MCQ',
                    value: mcqCount,
                    valueColor: Colors.purple,
                  ),
                ],
              ),

              if (_error.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  _error,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  int _countByType(FavouriteQuestionsListModel model, {required bool isSba}) {
    final items = model.data ?? [];
    return items.where((item) => isSba ? item.isSba : item.isMcq).length;
  }
}

/// ✅ Tiny stat widget with icon + value + label
class _MiniStat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final int value;
  final Color valueColor;

  const _MiniStat({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: iconColor),
        const SizedBox(width: 4),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: valueColor,
            height: 1,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
            height: 1,
          ),
        ),
      ],
    );
  }
}



