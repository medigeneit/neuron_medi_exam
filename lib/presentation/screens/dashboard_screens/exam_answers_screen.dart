// lib/presentation/screens/exam_answers_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/models/exam_answers_model.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/services/exam_answers_service.dart';
import 'package:medi_exam/data/utils/urls.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';
import 'package:medi_exam/presentation/widgets/helpers/exam_questions_screen_helpers.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';
import 'package:medi_exam/presentation/widgets/mcq_answer_review_tile.dart';
import 'package:medi_exam/presentation/widgets/sba_answer_review_tile.dart';

class ExamAnswersScreen extends StatefulWidget {
  const ExamAnswersScreen({super.key});

  @override
  State<ExamAnswersScreen> createState() => _ExamAnswersScreenState();
}

class _ExamAnswersScreenState extends State<ExamAnswersScreen> {
  late final Map<String, dynamic> _args;
  late final String admissionId;
  late final String examId;
  late final bool isFreeExam;

  // Optional extras coming from the Result screen:
  dynamic _examInfo; // title, totalQuestion, fullMark
  dynamic
      _result; // obtainedMarkPercent, obtainedMark, correctMark, negativeMark, wrongAnswers, overallPosition, batchPosition

  final _service = ExamAnswersService();

  bool _loading = true;
  String? _error;
  List<ExamAnswerItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _args = Get.arguments ?? {};
    admissionId = (_args['admissionId'] ?? '').toString();
    examId = (_args['examId'] ?? '').toString();
    isFreeExam = (_args['isFreeExam'] ?? false) as bool;

    // These may be typed objects (from your models) OR Map<String, dynamic>.
    _examInfo = _args['examInfo'];
    _result = _args['result'];

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final url = isFreeExam
        ? Urls.freeExamAnswers(examId)
        : Urls.examAnswers(admissionId, examId);

    final NetworkResponse resp = await _service.fetchExamAnswers(url);

    if (!mounted) return;

    if (resp.isSuccess) {
      try {
        final data = resp.responseData;
        ExamAnswersModel? model;

        if (data is ExamAnswersModel) {
          model = data;
        } else if (data is Map<String, dynamic>) {
          model = ExamAnswersModel.fromAny(data);
        } else if (data is List) {
          model = ExamAnswersModel.fromAny(data);
        } else if (data is String) {
          final decoded = jsonDecode(data);
          model = ExamAnswersModel.fromAny(decoded);
        }

        setState(() {
          _items = model?.items ?? const [];
          _loading = false;
        });
      } catch (e) {
        setState(() {
          _loading = false;
          _error = 'Failed to parse answers: $e';
        });
      }
    } else {
      setState(() {
        _loading = false;
        _error = resp.errorMessage ?? 'Failed to load answers';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'Answers',
      body: _loading
          ? const Center(child: LoadingWidget())
          : _error != null
              ? ErrorCardExam(message: _error!, onRetry: _load)
              : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth =
            constraints.maxWidth < 720 ? constraints.maxWidth : 720.0;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  children: [
                    // Title row
                    Row(
                      children: [
                        Icon(Icons.analytics_outlined,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Result Overview',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Overview block (pretty, compact)
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: _buildOverview(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.fact_check_outlined,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Answers Review',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    _legend(context),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Answers list
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.separated(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final idxLabel = '#${index + 1}';

                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: item.isMCQ
                          ? MCQAnswerReviewTile(
                        indexLabel: idxLabel,
                        titleHtml: item.questionTitle ?? '',
                        options: item.questionOption ?? const [],
                        doctorStates: item.doctorStates,
                        correctStates: item.correctStates,
                        questionId: item.questionId, // ✅ NEW
                      )
                          : SBAAnswerReviewTile(
                        indexLabel: idxLabel,
                        titleHtml: item.questionTitle ?? '',
                        options: item.questionOption ?? const [],
                        doctorIndex: item.doctorSbaIndex,
                        correctIndex: item.correctSbaIndex,
                        questionId: item.questionId, // ✅ NEW
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------- Overview (pretty + compact) ----------
  Widget _buildOverview(BuildContext context) {
    final percent = _toDouble(_readDyn(
            _result,
            (d) => (d as dynamic).obtainedMarkPercent,
            ['obtainedMarkPercent', 'obtained_mark_percent'])) ??
        0.0;

    final totalQ = _toInt(_readDyn(
        _examInfo,
        (d) => (d as dynamic).totalQuestion,
        ['totalQuestion', 'total_question']));
    final fullMark = _toInt(_readDyn(
        _examInfo, (d) => (d as dynamic).fullMark, ['fullMark', 'full_mark']));

    final obtained = _toDouble(_readDyn(_result,
        (d) => (d as dynamic).obtainedMark, ['obtainedMark', 'obtained_mark']));
    final correct = _toDouble(_readDyn(_result,
        (d) => (d as dynamic).correctMark, ['correctMark', 'correct_mark']));
    final negative = _toDouble(_readDyn(_result,
        (d) => (d as dynamic).negativeMark, ['negativeMark', 'negative_mark']));
    final wrong = _toInt(_readDyn(_result, (d) => (d as dynamic).wrongAnswers,
        ['wrongAnswers', 'wrong_answers']));

    final overallPos = _toInt(_readDyn(
        _result,
        (d) => (d as dynamic).overallPosition,
        ['overallPosition', 'overall_position']));
    final batchPos = _toInt(_readDyn(
        _result,
        (d) => (d as dynamic).batchPosition,
        ['batchPosition', 'batch_position']));

    final title = _toString(
            _readDyn(_examInfo, (d) => (d as dynamic).title, ['title'])) ??
        '—';

    return CustomBlobBackground(
      backgroundColor: Colors.white,
      blobColor: AppColor.indigo,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + ring
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title & two compact metrics (obtained / full)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.assignment_outlined,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColor.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _pillMetric('Total Qs', _fmtInt(totalQ)),
                          _pillMetric('Full Mark', _fmtInt(fullMark)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Grid-ish metrics (responsive wrap)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _metricCard(
                  icon: Icons.assignment_turned_in_rounded,
                  label: 'Obtained',
                  value: fullMark == null
                      ? _fmtDouble(obtained)
                      : '${_fmtDouble(obtained)} / ${_fmtInt(fullMark)}',
                ),
                _metricCard(
                  icon: Icons.check_circle_outline,
                  label: 'Correct',
                  value: _fmtDouble(correct),
                ),
                _metricCard(
                  icon: Icons.remove_circle_outline,
                  label: 'Negative',
                  value: _fmtDouble(negative),
                ),
                _metricCard(
                  icon: Icons.rule_folder_outlined,
                  label: 'Wrong',
                  value: _fmtInt(wrong),
                ),
/*                _metricCard(
                  icon: Icons.leaderboard_rounded,
                  label: 'Overall Pos',
                  value: _fmtInt(overallPos),
                ),
                _metricCard(
                  icon: Icons.groups_rounded,
                  label: 'Batch Pos',
                  value: _fmtInt(batchPos),
                ),*/
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ----- Pretty bits -----
  Widget _pillMetric(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColor.indigo.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColor.indigo.withOpacity(0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: AppColor.primaryTextColor,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: AppColor.primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.black12),
              ),
              child: Icon(icon, size: 18, color: Colors.black87),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColor.primaryTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Small legend to explain colors
  Widget _legend(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _legendPill('Correct', Colors.green),
        _legendPill('Wrong', Colors.red),
        _legendPill('Answers', AppColor.indigo),
      ],
    );
  }

  Widget _legendPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColor.primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Safe readers / formatters ----------
  dynamic _readDyn(
    dynamic obj,
    dynamic Function(dynamic d) dynGet,
    List<String> mapKeys,
  ) {
    if (obj == null) return null;
    // Try dynamic property access (works if a typed model was passed).
    try {
      final v = dynGet(obj);
      if (v != null) return v;
    } catch (_) {}
    // Fallback to Map
    if (obj is Map) {
      for (final k in mapKeys) {
        if (obj.containsKey(k) && obj[k] != null) return obj[k];
      }
    }
    return null;
  }

  String? _toString(dynamic v) => v?.toString();

  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim());
    return null;
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim());
    return null;
  }

  String _fmtInt(int? v) => v == null ? '—' : v.toString();

  String _fmtDouble(double? v) => v == null
      ? '—'
      : v.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');

  Color _getProgressColor(double percent) {
    if (percent >= 80) return Colors.green;
    if (percent >= 60) return Colors.yellow;
    if (percent >= 40) return Colors.orange;
    return Colors.red;
  }
}
