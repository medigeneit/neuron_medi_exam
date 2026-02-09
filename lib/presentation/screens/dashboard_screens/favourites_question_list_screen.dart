import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medi_exam/data/models/favourite_questions_list_model.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/services/favourite_questions_list_service.dart';

import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';
import 'package:medi_exam/presentation/widgets/helpers/exam_questions_screen_helpers.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';

// ✅ Reusable tiles
import 'package:medi_exam/presentation/widgets/favourites_mcq_review_tile.dart';
import 'package:medi_exam/presentation/widgets/favourites_sba_review_tile.dart';
import 'package:medi_exam/presentation/widgets/question_action_row.dart';

class FavouriteQuestionsListScreen extends StatefulWidget {
  const FavouriteQuestionsListScreen({super.key});

  @override
  State<FavouriteQuestionsListScreen> createState() =>
      _FavouriteQuestionsListScreenState();
}

class _FavouriteQuestionsListScreenState extends State<FavouriteQuestionsListScreen>
    with SingleTickerProviderStateMixin {
  final _service = FavouriteQuestionsListService();

  bool _loading = true;
  String? _error;

  FavouriteQuestionsListModel? _model;
  List<FavouriteQuestionItem> _items = <FavouriteQuestionItem>[];

  late final TabController _tabController;

  /// Global toggle (overview card button)
  bool _showAllAnswers = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleAllAnswers() {
    setState(() => _showAllAnswers = !_showAllAnswers);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final NetworkResponse resp = await _service.fetchAllFavouriteQuestions();

    if (!mounted) return;

    if (resp.isSuccess) {
      try {
        FavouriteQuestionsListModel? model;

        final data = resp.responseData;
        if (data is FavouriteQuestionsListModel) {
          model = data;
        } else if (data is Map<String, dynamic>) {
          model = FavouriteQuestionsListModel.fromJson(data);
        } else if (data is String) {
          final decoded = jsonDecode(data);
          model = FavouriteQuestionsListModel.parse(decoded);
        } else {
          model = FavouriteQuestionsListModel.parse(data);
        }

        setState(() {
          _model = model;
          _items = (model?.data ?? const <FavouriteQuestionItem>[]).toList();
          GlobalFavouriteCache.setLoadedIds(
            _items.map((e) => e.id).whereType<int>(),
          );
          _loading = false;
        });
      } catch (e) {
        setState(() {
          _loading = false;
          _error = 'Failed to parse favourites: $e';
        });
      }
    } else {
      setState(() {
        _loading = false;
        _error = resp.errorMessage ?? 'Failed to load favourites';
      });
    }
  }

  void _removeFromList(int questionId) {
    setState(() {
      _items.removeWhere((e) => e.id == questionId);
      _model = (_model ?? const FavouriteQuestionsListModel()).copyWith(data: _items);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'My Favourites',
      body: _loading
          ? const Center(child: LoadingWidget())
          : _error != null
          ? ErrorCardExam(message: _error!, onRetry: _load)
          : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width < 720
        ? MediaQuery.of(context).size.width
        : 720.0;

    final mcqList = _items.where((e) => e.isMcq).toList();
    final sbaList = _items.where((e) => e.isSba).toList();

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
                    total: _items.length,
                    mcq: mcqList.length,
                    sba: sbaList.length,
                    showAllAnswers: _showAllAnswers,
                    onToggleAllAnswers: _toggleAllAnswers,
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _tabBarContainer(context, mcqCount: mcqList.length, sbaCount: sbaList.length),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMcqTab(
            context,
            maxWidth: maxWidth,
            items: mcqList,
          ),
          _buildSbaTab(
            context,
            maxWidth: maxWidth,
            items: sbaList,
          ),
        ],
      ),
    );
  }

  Widget _tabBarContainer(BuildContext context, {required int mcqCount, required int sbaCount}) {
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
        tabs: [
          Tab(
            icon: const Icon(Icons.checklist_rounded, size: 18),
            child: Center(
              child: Text(
                'MCQ\n($mcqCount)',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800, height: 1.05),
              ),
            ),
          ),
          Tab(
            icon: const Icon(Icons.check_circle_outline, size: 18),
            child: Center(
              child: Text(
                'SBA\n($sbaCount)',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800, height: 1.05),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMcqTab(
      BuildContext context, {
        required double maxWidth,
        required List<FavouriteQuestionItem> items,
      }) {
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
                      Icon(Icons.inbox_rounded, size: 44, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      Text(
                        'No MCQ favourites',
                        style: TextStyle(
                          fontSize: Sizes.bodyText(context),
                          fontWeight: FontWeight.w900,
                          color: Colors.grey.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Save some MCQ questions to see them here.',
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
          final q = items[index];
          final idxLabel = '#${index + 1}';

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: FavouritesMCQReviewTile(
                key: ValueKey('fav_mcq_${q.id ?? index}'),
                indexLabel: idxLabel,
                titleHtml: (q.title ?? '').trim().isEmpty ? '—' : (q.title ?? ''),
                options: q.options ?? const <FavouriteQuestionOption>[],
                answerScript: q.answerScript,
                questionId: q.id,
                blobColor: AppColor.purple,
                showAllAnswers: _showAllAnswers,
                onRemovedFromFavourites: (id) => _removeFromList(id),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSbaTab(
      BuildContext context, {
        required double maxWidth,
        required List<FavouriteQuestionItem> items,
      }) {
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
                      Icon(Icons.inbox_rounded, size: 44, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      Text(
                        'No SBA favourites',
                        style: TextStyle(
                          fontSize: Sizes.bodyText(context),
                          fontWeight: FontWeight.w900,
                          color: Colors.grey.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Save some SBA questions to see them here.',
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
          final q = items[index];
          final idxLabel = '#${index + 1}';

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: FavouritesSBAReviewTile(
                key: ValueKey('fav_sba_${q.id ?? index}'),
                indexLabel: idxLabel,
                titleHtml: (q.title ?? '').trim().isEmpty ? '—' : (q.title ?? ''),
                options: q.options ?? const <FavouriteQuestionOption>[],
                answerScript: q.answerScript,
                questionId: q.id,
                blobColor: AppColor.indigo,
                showAllAnswers: _showAllAnswers,
                onRemovedFromFavourites: (id) => _removeFromList(id),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _overviewCard(
      BuildContext context, {
        required int total,
        required int mcq,
        required int sba,
        required bool showAllAnswers,
        required VoidCallback onToggleAllAnswers,
      }) {
    final chartData = {
      "MCQ": mcq.toDouble(),
      "SBA": sba.toDouble(),
    };

    final tipText = showAllAnswers
        ? "Answers are visible"
        : "Want to check answers? Tap the eye";

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
                    children: [
                      Text(
                        'Saved Favourites',
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
                          Icon(Icons.bookmark_rounded, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            'Total $total Questions',
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
                          _chartLegendItem(context, 'MCQ', AppColor.purple, mcq.toDouble()),
                          _chartLegendItem(context, 'SBA', AppColor.indigo, sba.toDouble()),
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
                            "MCQ": AppColor.purple,
                            "SBA": AppColor.indigo,
                          },
                          width: 8,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$total',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: AppColor.primaryColor,
                            ),
                          ),
                          Text(
                            "Saved",
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

            const SizedBox(height: 10),

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
                            onTap: onToggleAllAnswers,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: showAllAnswers
                                    ? AppColor.primaryColor.withOpacity(0.10)
                                    : Colors.grey.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: showAllAnswers
                                      ? AppColor.primaryColor.withOpacity(0.18)
                                      : Colors.grey.withOpacity(0.12),
                                ),
                              ),
                              child: Icon(
                                showAllAnswers
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                size: 18,
                                color: showAllAnswers
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
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(
        '$label ($value)',
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
