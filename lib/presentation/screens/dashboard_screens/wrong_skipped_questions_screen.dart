import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medi_exam/data/models/wrong_skipped_qus_details_model.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/services/wrong_skipped_qus_details_service.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';
import 'package:medi_exam/presentation/widgets/helpers/exam_questions_screen_helpers.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';

// Tiles
import 'package:medi_exam/presentation/widgets/wrong_skipped_mcq_review_tile.dart';
import 'package:medi_exam/presentation/widgets/wrong_skipped_sba_review_tile.dart';

class WrongSkippedQuestionsScreen extends StatefulWidget {
  const WrongSkippedQuestionsScreen({super.key});

  @override
  State<WrongSkippedQuestionsScreen> createState() =>
      _WrongSkippedQuestionsScreenState();
}

class _WrongSkippedQuestionsScreenState extends State<WrongSkippedQuestionsScreen>
    with SingleTickerProviderStateMixin {
  late final Map<String, dynamic> _args;

  late final String _type;
  late final String _examId;
  late final String _title;

  final _service = WrongSkippedQusDetailsService();

  bool _loading = true;
  String? _error;
  WrongSkippedQusDetailsModel? _model;

  late final TabController _tabController;

  /// Global toggle (overview card button)
  bool _showAllCorrect = false;

  @override
  void initState() {
    super.initState();
    _args = (Get.arguments is Map<String, dynamic>)
        ? Get.arguments
        : <String, dynamic>{};

    _type = (_args['type'] ?? _args['examType'] ?? _args['metaKey'] ?? '')
        .toString();
    _examId = (_args['examId'] ?? _args['id'] ?? '').toString();
    _title = (_args['title'] ?? _args['examTitle'] ?? 'Wrong & Skipped')
        .toString();

    _tabController = TabController(length: 2, vsync: this);

    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleAllCorrect() {
    setState(() => _showAllCorrect = !_showAllCorrect);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final NetworkResponse resp = await _service.fetchWrongSkippedQusDetails(
      type: _type,
      examId: _examId,
    );

    if (!mounted) return;

    if (resp.isSuccess) {
      try {
        WrongSkippedQusDetailsModel? model;

        final data = resp.responseData;
        if (data is WrongSkippedQusDetailsModel) {
          model = data;
        } else if (data is Map<String, dynamic>) {
          model = WrongSkippedQusDetailsModel.fromJson(data);
        } else if (data is String) {
          final decoded = jsonDecode(data);
          model = WrongSkippedQusDetailsModel.parse(decoded);
        }

        setState(() {
          _model = model;
          _loading = false;
        });
      } catch (e) {
        setState(() {
          _loading = false;
          _error = 'Failed to parse details: $e';
        });
      }
    } else {
      setState(() {
        _loading = false;
        _error = resp.errorMessage ?? 'Failed to load details';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: _title.isEmpty ? 'Wrong & Skipped' : _title,
      body: _loading
          ? const Center(child: LoadingWidget())
          : _error != null
          ? ErrorCardExam(message: _error!, onRetry: _load)
          : _buildContent(context),
    );
  }

  /// ✅ Whole screen scrollable AND TabBar scrolls away (not pinned/stuck)
  Widget _buildContent(BuildContext context) {
    final model = _model ?? const WrongSkippedQusDetailsModel();

    final maxWidth = MediaQuery.of(context).size.width < 720
        ? MediaQuery.of(context).size.width
        : 720.0;

    final wrongList =
        model.wrongQuestions ?? const <WrongSkippedQuestionAttempt>[];
    final skippedList =
        model.unansweredQuestions ?? const <WrongSkippedQuestionAttempt>[];

    return NestedScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: _overviewCard(
                    context,
                    model,
                    showAllCorrect: _showAllCorrect,
                    onToggleAllCorrect: _toggleAllCorrect,
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          /// ✅ TabBar is just a normal sliver now (no fixed height / no overflow)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _tabBarContainer(context),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListTab(
            context,
            maxWidth: maxWidth,
            items: wrongList,
            emptyTitle: 'No wrong answers',
            emptySubtitle: 'You have no wrong questions for this exam.',
            blobColor: Colors.red,
          ),
          _buildListTab(
            context,
            maxWidth: maxWidth,
            items: skippedList,
            emptyTitle: 'No skipped questions',
            emptySubtitle: 'You have no skipped questions for this exam.',
            blobColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _tabBarContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.18)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(6),
        labelColor: AppColor.primaryColor,
        unselectedLabelColor: AppColor.secondaryColor.withOpacity(0.75),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: Sizes.smallText(context),
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: Sizes.smallText(context),
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.cancel_rounded, size: 18),
            child: Center(
              child: Text(
                'Wrong\nQuestions',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w800, height: 1.05),
              ),
            ),
          ),
          Tab(
            icon: Icon(Icons.do_not_disturb_on_rounded, size: 18),
            child: Center(
              child: Text(
                'Skipped\nQuestions',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w800, height: 1.05),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// List tab (scrolls the whole page via NestedScrollView)
  Widget _buildListTab(
      BuildContext context, {
        required double maxWidth,
        required List<WrongSkippedQuestionAttempt> items,
        required String emptyTitle,
        required String emptySubtitle,
        required Color blobColor,
      }) {
    // ✅ Refresh works reliably per-tab
    return RefreshIndicator(
      onRefresh: _load,
      child: items.isEmpty
          ? ListView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          const SizedBox(height: 8),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox_rounded,
                          size: 44, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      Text(
                        emptyTitle,
                        style: TextStyle(
                          fontSize: Sizes.bodyText(context),
                          fontWeight: FontWeight.w900,
                          color: Colors.grey.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        emptySubtitle,
                        style: TextStyle(
                          fontSize: Sizes.smallText(context),
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      )
          : ListView.separated(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          final q = item.question;

          final idxLabel = '#${index + 1}';
          final title = (q?.title ?? '').trim();
          final titleHtml = title.isEmpty ? '—' : title;
          final keyBase = q?.id ?? index;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: item.isMcq
                  ? WrongSkippedMCQReviewTile(
                key: ValueKey('ws_mcq_$keyBase'),
                indexLabel: idxLabel,
                titleHtml: titleHtml,
                stems: item.stems ?? const [],
                questionId: q?.id,
                blobColor: blobColor,
                showAllCorrect: _showAllCorrect,
              )
                  : WrongSkippedSBAReviewTile(
                key: ValueKey('ws_sba_$keyBase'),
                indexLabel: idxLabel,
                titleHtml: titleHtml,
                options: q?.options ?? const <String, String>{},
                givenAnswer: item.givenAnswer,
                correctAnswer: item.correctAnswer,
                questionId: q?.id,
                blobColor: blobColor,
                showAllCorrect: _showAllCorrect,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _overviewCard(
      BuildContext context,
      WrongSkippedQusDetailsModel model, {
        required bool showAllCorrect,
        required VoidCallback onToggleAllCorrect,
      }) {
    final String title = (model.examTitle ?? 'Exam Details').trim();
    final int totalQ = model.computedTotalQuestions ?? 0;

    final double totalUnits =
        double.tryParse(model.computedTotalUnits.toString()) ?? 0.0;
    final double wrongUnits =
        double.tryParse(model.totalWrongAnswerUnits.toString()) ?? 0.0;
    final double skippedUnits =
        double.tryParse(model.totalUnansweredQuestionUnits.toString()) ?? 0.0;
    final double answeredUnits =
        double.tryParse(model.totalAnsweredQuestionUnits.toString()) ?? 0.0;

    double correctUnits = answeredUnits - wrongUnits;
    if (correctUnits < 0) correctUnits = 0;

    final Map<String, double> chartData = {
      "Correct": correctUnits,
      "Wrong": wrongUnits,
      "Skipped": skippedUnits,
    };

    final String tipText = showAllCorrect
        ? "Correct answers are visible"
        : "Want to check correct answers? Tap the eye";

    return CustomBlobBackground(
      backgroundColor: Colors.white,
      blobColor: Colors.lightBlueAccent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: Sizes.bodyText(context),
                          fontWeight: FontWeight.w900,
                          color: AppColor.primaryTextColor,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.list_alt_rounded,
                              size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            'Total $totalQ Questions',
                            style: TextStyle(
                              fontSize: Sizes.verySmallText(context),
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          _chartLegendItem(
                              context, 'Correct Units', Colors.green, correctUnits),
                          _chartLegendItem(
                              context, 'Wrong Units', Colors.red, wrongUnits),
                          _chartLegendItem(
                              context, 'Skipped Units', Colors.orange, skippedUnits),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 68,
                  height: 68,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(68, 68),
                        painter: _SimplePieChartPainter(
                          data: chartData,
                          colors: {
                            "Correct": Colors.green,
                            "Wrong": Colors.red,
                            "Skipped": Colors.orange,
                          },
                          width: 8,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatUnit(totalUnits),
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: AppColor.primaryColor,
                            ),
                          ),
                          Text(
                            "Units",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 9,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.15)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.tips_and_updates_rounded,
                          size: 16,
                          color: AppColor.indigo.withOpacity(0.75),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            tipText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: Sizes.verySmallText(context),
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: onToggleAllCorrect,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: showAllCorrect
                                    ? AppColor.primaryColor.withOpacity(0.10)
                                    : Colors.grey.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: showAllCorrect
                                      ? AppColor.primaryColor.withOpacity(0.18)
                                      : Colors.grey.withOpacity(0.12),
                                ),
                              ),
                              child: Icon(
                                showAllCorrect
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                size: 18,
                                color: showAllCorrect
                                    ? AppColor.primaryColor
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

// Helper for formatting units
String _formatUnit(double value) {
  if (value % 1 == 0) return value.toInt().toString();
  return value.toStringAsFixed(1);
}

// Legend item
Widget _chartLegendItem(
    BuildContext context,
    String label,
    Color color,
    double value,
    ) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 4),
      Text(
        '$label (${_formatUnit(value)})',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade700,
        ),
      ),
    ],
  );
}

/// Donut painter
class _SimplePieChartPainter extends CustomPainter {
  final Map<String, double> data;
  final Map<String, Color> colors;
  final double width;

  _SimplePieChartPainter({
    required this.data,
    required this.colors,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double total = data.values.fold(0, (sum, item) => sum + item);

    if (total == 0) {
      final paint = Paint()
        ..color = Colors.grey.shade200
        ..style = PaintingStyle.stroke
        ..strokeWidth = width;
      canvas.drawCircle(
        size.center(Offset.zero),
        (size.width / 2) - (width / 2),
        paint,
      );
      return;
    }

    double startRadian = -1.5708;
    final rect = Rect.fromLTWH(
      width / 2,
      width / 2,
      size.width - width,
      size.height - width,
    );

    data.forEach((key, value) {
      final sweepRadian = (value / total) * 2 * 3.14159;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.butt
        ..color = colors[key] ?? Colors.grey;

      canvas.drawArc(rect, startRadian, sweepRadian, false, paint);
      startRadian += sweepRadian;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
