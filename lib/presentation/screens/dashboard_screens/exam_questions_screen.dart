// lib/presentation/screens/exam_questions_screen.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/models/exam_question_model.dart';
import 'package:medi_exam/data/services/exam_feedback_service.dart';
import 'package:medi_exam/data/services/exam_questions_service.dart';
import 'package:medi_exam/data/services/finish_exam_service.dart';
import 'package:medi_exam/data/services/single_answer_submit_service.dart';
import 'package:medi_exam/data/utils/urls.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/exam_timer.dart';
import 'package:medi_exam/presentation/widgets/helpers/exam_questions_screen_helpers.dart';
import 'package:medi_exam/presentation/widgets/helpers/payment_screen_helpers.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';
import 'package:medi_exam/presentation/widgets/mcq_question_tile.dart';
import 'package:medi_exam/presentation/widgets/sba_question_tile.dart';

class ExamQuestionsScreen extends StatefulWidget {
  const ExamQuestionsScreen({super.key});

  @override
  State<ExamQuestionsScreen> createState() => _ExamQuestionsScreenState();
}

class _ExamQuestionsScreenState extends State<ExamQuestionsScreen>
    with SingleTickerProviderStateMixin {
  late Map<String, dynamic> args;
  late String examQuestionUrl;
  late String admissionId;
  late String examId;
  late bool isFreeExam;
  final _examService = ExamQuestionsService();
  final _submitService = SingleAnswerSubmitService();
  final _finishService = FinishExamService();

  ExamQuestionModel? _model;
  bool _loading = true;
  String? _loadError;

  late TabController _tabController;

  // Timer
  Timer? _ticker;
  int _secondsLeft = 0; // logic
  final ValueNotifier<int> _secondsVN = ValueNotifier<int>(0); // UI
  bool get _timeUp => _secondsLeft <= 0;

  // Local state caches
  // MCQ: per statement T/F/null, LENGTH = number of statements for that MCQ
  final Map<int, List<bool?>> _mcqStates = {};
  // Per-statement in-flight guards (length matches statement count)
  final Map<int, List<bool>> _mcqBusy = {};

  // SBA: selected letter
  final Map<int, String?> _sbaSelected = {};
  // In-flight guard per SBA question
  final Set<int> _sbaBusy = {};

  List<int> get _allQuestionIds {
    final q = _model?.questions;
    if (q == null || q.isEmpty) return const [];
    final ids = q.keys.toList()..sort();
    return ids;
  }

  Set<int> get _answeredIds {
    final m = _model?.submittedAnswers;
    if (m == null || m.isEmpty) return {};
    return m.keys.toSet();
  }

  Set<int> get _partialIdsFromServer {
    final list = _model?.partialAnsweredQuestionIds;
    if (list == null || list.isEmpty) return {};
    return list.toSet();
  }

  /// Locally compute partial MCQ questions:
  /// partial = at least one answered AND at least one unanswered among N statements.
  Set<int> get _partialIdsComputed {
    final out = <int>{};
    _mcqStates.forEach((qId, states) {
      if (states.isEmpty) return;
      final anyAnswered = states.any((e) => e != null);
      final anyUnanswered = states.any((e) => e == null);
      if (anyAnswered && anyUnanswered) out.add(qId);
    });
    return out;
  }

  /// Is the question still partial now (based on local MCQ states)?
  bool _isStillPartialNow(int qId) {
    final states = _mcqStates[qId] ?? const <bool?>[];
    if (states.isEmpty) return false;
    final answered = states.where((e) => e != null).length;
    return answered > 0 && answered < states.length;
  }

  /// Final list for the Partial tab: server-marked and still partial locally, union locally computed.
  List<int> get _partialIds {
    final filteredServer =
    _partialIdsFromServer.where(_isStillPartialNow).toSet();
    final computed = _partialIdsComputed;
    final list = (filteredServer..addAll(computed)).toList()..sort();
    return list;
  }

  List<int> get _unansweredIds {
    final answered = _answeredIds;
    return _allQuestionIds.where((id) => !answered.contains(id)).toList();
  }

  @override
  void initState() {
    super.initState();
    args = Get.arguments ?? {};
    examQuestionUrl = (args['url'] ?? '').toString();
    admissionId = (args['admissionId'] ?? '').toString();
    examId = (args['examId'] ?? '').toString();
    isFreeExam = (args['isFreeExam'] ?? false) as bool;
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _tabController.dispose();
    _secondsVN.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final resp = await _examService.fetchExamQuestions(examQuestionUrl);

      if (!resp.isSuccess) {
        setState(() {
          _loading = false;
          _loadError = resp.errorMessage ?? 'Failed to load questions';
        });
        return;
      }

      final raw = resp.responseData;

      ExamQuestionModel? model;
      if (raw is ExamQuestionModel) {
        model = raw;
      } else if (raw is Map<String, dynamic>) {
        model = ExamQuestionModel.fromJson(raw);
      } else if (raw is String) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) {
            model = ExamQuestionModel.fromJson(decoded);
          }
        } catch (_) {}
      }

      if (model == null) {
        setState(() {
          _loading = false;
          _loadError = 'Invalid response format';
        });
        return;
      }

      _primeLocalState(model);

      final duration = model.duration ?? 0;
      _startTimer(duration);

      setState(() {
        _model = model;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _loadError = e.toString();
      });
    }
  }

  void _primeLocalState(ExamQuestionModel model) {
    _mcqStates.clear();
    _mcqBusy.clear();
    _sbaSelected.clear();
    _sbaBusy.clear();

    final questions = model.questions ?? {};
    final submitted = model.submittedAnswers ?? {};

    for (final entry in questions.entries) {
      final qId = entry.key;
      final q = entry.value;

      if (q.isMCQ) {
        final int len = (q.questionOption?.length ?? 0).clamp(0, 1000);
        // decode any server answer and normalize to `len`
        final ans = submitted[qId]?.answer;
        final states = _parseMcq(ans, expectedLen: len);
        _mcqStates[qId] = states;
        _mcqBusy[qId] = List<bool>.filled(len, false);
      } else if (q.isSBA) {
        final ans = submitted[qId]?.answer;
        final letter =
        (ans ?? '').trim().isEmpty ? null : ans!.trim().toUpperCase();
        _sbaSelected[qId] = letter;
      }
    }
  }

  void _startTimer(int seconds) {
    _ticker?.cancel();
    _secondsLeft = seconds;
    _secondsVN.value = seconds;
    if (_secondsLeft <= 0) return;

    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        _secondsLeft = 0;
        _secondsVN.value = 0;
        setState(() {});
      } else {
        _secondsLeft -= 1;
        _secondsVN.value = _secondsLeft;
      }
    });
  }

  // ---------- MCQ helpers (dynamic length) ----------
  List<bool?> _parseMcq(String? input, {required int expectedLen}) {
    if (expectedLen <= 0) return const <bool?>[];
    final out = List<bool?>.filled(expectedLen, null);
    if (input == null || input.isEmpty) return out;

    // We accept any length the server sent; map into expectedLen
    final upper = input.toUpperCase();
    final limit = upper.length < expectedLen ? upper.length : expectedLen;
    for (var i = 0; i < limit; i++) {
      final c = upper[i];
      if (c == 'T') {
        out[i] = true;
      } else if (c == 'F') {
        out[i] = false;
      } else {
        out[i] = null;
      }
    }
    return out;
  }

  String _buildMcq(List<bool?> states) {
    final buf = StringBuffer();
    for (var i = 0; i < states.length; i++) {
      final v = states[i];
      if (v == null) {
        buf.write('.');
      } else {
        buf.write(v ? 'T' : 'F');
      }
    }
    return buf.toString();
  }

  // ---------- Interactions ----------
  Future<void> _onSelectSBA({
    required int questionId,
    required String examQuestionId,
    required String optionLetter, // 'A'..'Z'
  }) async {
    if (_timeUp) return;
    if (_sbaBusy.contains(questionId)) return;

    _sbaBusy.add(questionId);

    final prev = _sbaSelected[questionId];
    setState(() {
      _sbaSelected[questionId] = optionLetter;
    });

    final resp = await _submitService.submitSingleAnswer(
      isFreeExam: isFreeExam,
      admissionId: admissionId,
      examId: examId,
      questionId: '$questionId',
      examQuestionId: examQuestionId,
      questionTypeId: '2',
      answer: optionLetter,
      endDuration: _secondsLeft.toString(),
    );

    if (!mounted) return;

    if (resp.isSuccess) {
      setState(() {
        _model?.submittedAnswers?.putIfAbsent(
          questionId,
              () => SubmittedAnswer(
            examQuestionId: int.tryParse(examQuestionId),
            answer: optionLetter,
            questionTypeId: 2,
          ),
        );
        _model?.submittedAnswers?[questionId] =
            (_model?.submittedAnswers?[questionId] ?? const SubmittedAnswer())
                .copyWith(answer: optionLetter, questionTypeId: 2);
      });
    } else {
      setState(() {
        _sbaSelected[questionId] = prev;
      });
      _showSnack(resp.errorMessage ?? 'Failed to submit answer');
    }

    _sbaBusy.remove(questionId);
    if (mounted) setState(() {});
  }

  Future<void> _onSelectMCQ({
    required int questionId,
    required String examQuestionId,
    required int index, // 0..N-1
    required bool value, // true for 'T', false for 'F'
  }) async {
    if (_timeUp) return;

    // Create/access busy list for this question; size must match statements length
    final currentLen = _mcqStates[questionId]?.length ?? 0;
    final busyList = _mcqBusy.putIfAbsent(
      questionId,
          () => List<bool>.filled(currentLen, false),
    );

    if (index < 0 || index >= currentLen) return;
    if (busyList[index] == true) return;

    busyList[index] = true;

    final states = List<bool?>.from(
      _mcqStates.putIfAbsent(questionId, () => List<bool?>.filled(0, null)),
    );
    final prev = states[index];
    states[index] = value;
    final answerStr = _buildMcq(states);

    setState(() {
      _mcqStates[questionId] = states;
    });

    final resp = await _submitService.submitSingleAnswer(
      isFreeExam: isFreeExam,
      admissionId: admissionId,
      examId: examId,
      questionId: '$questionId',
      examQuestionId: examQuestionId,
      questionTypeId: '1',
      answer: answerStr,
      endDuration: _secondsLeft.toString(),
    );

    if (!mounted) return;

    if (resp.isSuccess) {
      setState(() {
        _model?.submittedAnswers?.putIfAbsent(
          questionId,
              () => SubmittedAnswer(
            examQuestionId: int.tryParse(examQuestionId),
            answer: answerStr,
            questionTypeId: 1,
          ),
        );
        _model?.submittedAnswers?[questionId] =
            (_model?.submittedAnswers?[questionId] ?? const SubmittedAnswer())
                .copyWith(answer: answerStr, questionTypeId: 1);
      });
    } else {
      final revertedStates = List<bool?>.from(states)..[index] = prev;
      setState(() {
        _mcqStates[questionId] = revertedStates;
      });
      _showSnack(resp.errorMessage ?? 'Failed to submit answer');
    }

    busyList[index] = false;
    if (mounted) setState(() {});
  }

  Future<void> _onFinishExam() async {
    if (_timeUp == false) {
      final sure = await _askConfirm(
        title: 'Finish Exam?',
        message: 'Are you sure you want to finish the exam now?',
        positive: 'Finish',
      );
      if (sure != true) return;
    }

    final url = isFreeExam
        ? Urls.finishFreeExam(examId)
        : Urls.finishExam(admissionId, examId);

    final resp = await _finishService.fetchFinishExam(url);

    if (!mounted) return;

    if (resp.isSuccess) {
      final msg = (resp.responseData is Map &&
          (resp.responseData as Map)['message'] != null)
          ? (resp.responseData as Map)['message'].toString()
          : 'Exam finished successfully';

      final bool navigated =
          await _showFinishFeedbackDialog(successMessage: msg) ?? false;

      if (!navigated && mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
      _showSnack(resp.errorMessage ?? 'Failed to finish exam');
    }
  }

  Future<bool?> _showFinishFeedbackDialog(
      {required String successMessage}) async {
    final theme = Theme.of(context);
    final grad = AppColor.secondaryGradient;
    final Color accent =
    grad is LinearGradient ? grad.colors.first : theme.colorScheme.primary;

    final TextEditingController _feedbackCtrl = TextEditingController();
    final service = ExamFeedbackService();

    bool submitting = false;

    return showGeneralDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      barrierDismissible: false,
      barrierLabel: 'Exam Finished',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return CustomBlobBackground(
                      backgroundColor: Colors.white,
                      blobColor: accent,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                          Icons.check_circle_rounded,
                                          color: Colors.green,
                                          size: 24),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Exam Finished',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.primaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              successMessage,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            CalculatingRow(accent: accent),
                            const SizedBox(height: 16),
                            Text(
                              'Your Feedback',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _feedbackCtrl,
                              maxLines: 4,
                              minLines: 3,
                              textInputAction: TextInputAction.newline,
                              decoration: const InputDecoration(
                                hintText: 'Share your thoughts about the exam…',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                              enabled: !submitting,
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: submitting
                                      ? null
                                      : () async {
                                    setState(() => submitting = true);
                                    try {
                                      final fb =
                                      _feedbackCtrl.text.trim();

                                      final url = isFreeExam
                                          ? Urls.freeExamFeedback(
                                        examId,
                                      )
                                          : Urls.examFeedback(
                                        admissionId,
                                        examId,
                                      );

                                      final resp = await service
                                          .submitExamFeedback(
                                        url: url,
                                        feedback: fb,
                                      );
                                      if (!mounted) return;

                                      if (resp.isSuccess) {
                                        Get.snackbar(
                                          'Thanks!',
                                          'Your feedback has been submitted.',
                                          snackPosition:
                                          SnackPosition.BOTTOM,
                                          backgroundColor: Colors.green,
                                          colorText: Colors.white,
                                        );
                                        Navigator.pop(context, true);
                                        final data = {
                                          'admissionId':
                                          (admissionId).toString() ??
                                              '',
                                          'examId': (examId).toString(),
                                          'isFreeExam': isFreeExam,
                                        };
                                        Get.offNamed(
                                          RouteNames.examResult,
                                          arguments: data,
                                        );
                                      } else {
                                        Get.snackbar(
                                          'Error',
                                          resp.errorMessage ??
                                              'Failed to submit feedback',
                                          snackPosition:
                                          SnackPosition.BOTTOM,
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                        );
                                      }
                                    } catch (e) {
                                      if (!mounted) return;
                                      Get.snackbar(
                                        'Error',
                                        'Failed to submit feedback',
                                        snackPosition:
                                        SnackPosition.BOTTOM,
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                    } finally {
                                      if (mounted) {
                                        setState(
                                                () => submitting = false);
                                      }
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      gradient: AppColor.secondaryGradient,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColor.purple
                                              .withOpacity(0.28),
                                          blurRadius: 16,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (submitting)
                                          const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        else
                                          const Icon(Icons.send_rounded,
                                              color: Colors.white, size: 18),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Submit Feedback',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.2,
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
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _blockBack,
      child: CommonScaffold(
        title: 'Exam',
        body: _loading
            ? const Center(child: LoadingWidget())
            : _loadError != null
            ? ErrorCard(message: _loadError!, onRetry: _load)
            : _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final examTitle = _model?.exam?.title ?? '—';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          child: Row(
            children: [
              Icon(Icons.assignment_outlined,
                  size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  examTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: Sizes.titleText(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<int>(
                  valueListenable: _secondsVN,
                  builder: (_, v, __) => ExamTimer(
                    secondsLeft: v,
                    isTimeUp: _timeUp,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 46,
                decoration: BoxDecoration(
                  gradient: AppColor.warningGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (AppColor.warningGradient is LinearGradient
                          ? (AppColor.warningGradient as LinearGradient)
                          .colors
                          .first
                          : Colors.black)
                          .withOpacity(0.28),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _onFinishExam,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Finish Exam',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: AppColor.indigo.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: Sizes.smallText(context),
            ),
            tabs: [
              Tab(text: 'All (${_allQuestionIds.length})'),
              Tab(text: 'Unanswered (${_unansweredIds.length})'),
              Tab(text: 'Partial (${_partialIds.length})'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildList(_allQuestionIds, const PageStorageKey('all')),
              _buildList(_unansweredIds, const PageStorageKey('unanswered')),
              _buildList(_partialIds, const PageStorageKey('partial')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildList(List<int> questionIds, Key key) {
    final qMap = _model?.questions ?? {};
    if (qMap.isEmpty) {
      return const Center(child: Text('No questions'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth =
        constraints.maxWidth < 720 ? constraints.maxWidth : 720.0;
        return ListView.separated(
          key: key,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: questionIds.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final qId = questionIds[i];
            final q = qMap[qId];
            if (q == null) return const SizedBox.shrink();

            final indexLabel = '#${i + 1}';
            final enabled = !_timeUp;

            if (q.isSBA) {
              final selected = _sbaSelected[qId];
              final isBusy = _sbaBusy.contains(qId);
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: SBAQuestionTile(
                    indexLabel: indexLabel,
                    questionId: qId,
                    examQuestionId: (q.examQuestionId ?? qId).toString(),
                    titleHtml: q.questionTitle ?? '',
                    options: (q.questionOption ?? const []),
                    selectedLetter: selected,
                    enabled: enabled && !isBusy,
                    isBusy: isBusy,
                    onChanged: (letter) {
                      _onSelectSBA(
                        questionId: qId,
                        examQuestionId: (q.examQuestionId ?? qId).toString(),
                        optionLetter: letter,
                      );
                    },
                  ),
                ),
              );
            } else {
              // MCQ: dynamic statement count from question options
              final int len = (q.questionOption?.length ?? 0).clamp(0, 1000);

              // Ensure state length matches `len`
              var states = _mcqStates[qId] ?? List<bool?>.filled(len, null);
              if (states.length != len) {
                final newStates = List<bool?>.filled(len, null);
                final copy = states.length < len ? states.length : len;
                for (var k = 0; k < copy; k++) {
                  newStates[k] = states[k];
                }
                states = newStates;
                _mcqStates[qId] = states;
              }

              // Keep busy list in sync as well
              var busy = _mcqBusy[qId] ?? List<bool>.filled(len, false);
              if (busy.length != len) {
                final newBusy = List<bool>.filled(len, false);
                final copy = busy.length < len ? busy.length : len;
                for (var k = 0; k < copy; k++) {
                  newBusy[k] = busy[k];
                }
                busy = newBusy;
                _mcqBusy[qId] = busy;
              }

              // No locks (answers can change)
              final locks = List<bool>.filled(len, false);

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: MCQQuestionTile(
                    indexLabel: indexLabel,
                    questionId: qId,
                    examQuestionId: (q.examQuestionId ?? qId).toString(),
                    titleHtml: q.questionTitle ?? '',
                    options: (q.questionOption ?? const []),
                    states: states,
                    locks: locks,
                    busy: busy,
                    enabled: enabled,
                    onSelect: (statementIdx, value) {
                      _onSelectMCQ(
                        questionId: qId,
                        examQuestionId: (q.examQuestionId ?? qId).toString(),
                        index: statementIdx,
                        value: value,
                      );
                    },
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  Future<bool> _blockBack() async {
    await _showInfo(
      'Action blocked',
      'You cannot go back until you finish the exam.',
      positive: 'OK',
    );
    return false;
  }

  Future<bool?> _askConfirm({
    required String title,
    required String message,
    String positive = 'OK',
    String negative = 'Cancel',
  }) {
    final theme = Theme.of(context);
    final grad = AppColor.warningGradient;
    final Color accent =
    grad is LinearGradient ? grad.colors.first : AppColor.purple;

    return showGeneralDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      barrierDismissible: true,
      barrierLabel: title,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        final curved =
        CurvedAnimation(parent: animation, curve: Curves.easeOutBack);

        return ScaleTransition(
          scale: curved,
          child: FadeTransition(
            opacity: animation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: CustomBlobBackground(
                  backgroundColor: Colors.white,
                  blobColor: accent,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: accent.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.warning_amber_rounded,
                                      color: accent, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.primaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context, false),
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 20),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.pop(context, true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: grad,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accent.withOpacity(0.28),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Finish Exam',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.2,
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
                ),
              ),
            ),
          ),
        );
      },
    ).then((value) => value);
  }

  Future<void> _showInfo(String title, String message,
      {String positive = 'OK'}) {
    return showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(positive),
          )
        ],
      ),
    );
  }

  void _showSnack(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
