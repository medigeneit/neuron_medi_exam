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
  const ExamQuestionsScreen({
    super.key,
  });

  @override
  State<ExamQuestionsScreen> createState() => _ExamQuestionsScreenState();
}

class _ExamQuestionsScreenState extends State<ExamQuestionsScreen>
    with SingleTickerProviderStateMixin {
  late Map<String, dynamic> args;
  late String admissionId;
  late String examId;
  final _examService = ExamQuestionsService();
  final _submitService = SingleAnswerSubmitService();
  final _finishService = FinishExamService();

  ExamQuestionModel? _model;
  bool _loading = true;
  String? _loadError;

  late TabController _tabController;

  // Timer
  Timer? _ticker;
  int _secondsLeft = 0; // used for logic (unchanged)
  final ValueNotifier<int> _secondsVN = ValueNotifier<int>(0); // used for UI
  bool get _timeUp => _secondsLeft <= 0;

  // Local state caches
  final Map<int, List<bool?>> _mcqStates = {};
  final Map<int, List<bool>> _mcqLocks = {};

  // NEW: in-flight tap/request guards per MCQ statement
  // true = this statement's pair (T/F) is busy (ignores subsequent taps immediately)
  final Map<int, List<bool>> _mcqBusy = {};

  final Map<int, String?> _sbaSelected = {};
  final Set<int> _sbaLocked = {};

  // NEW: SBA in-flight guard to prevent ultra-fast double taps
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
  /// partial = at least one answered AND at least one unanswered (among 5 statements).
  Set<int> get _partialIdsComputed {
    final out = <int>{};
    _mcqStates.forEach((qId, states) {
      final anyAnswered = states.any((e) => e != null);
      final anyUnanswered = states.any((e) => e == null);
      if (anyAnswered && anyUnanswered) out.add(qId);
    });
    return out;
  }

  /// Helper to check current local partial state for a questionId.
  bool _isStillPartialNow(int qId) {
    final states = _mcqStates[qId] ?? const [null, null, null, null, null];
    final answered = states.where((e) => e != null).length;
    return answered > 0 && answered < 5;
  }

  /// FINAL list for the Partial tab:
  /// Keep only server-marked partials that are STILL partial locally, union with locally computed.
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
    admissionId = (args['admissionId'] ?? '').toString();
    examId = (args['examId'] ?? '').toString();
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
      final resp = await _examService.fetchExamQuestions(
        admissionId,
        examId,
      );

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
        } catch (_) {
          /* ignore */
        }
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
    _mcqLocks.clear();
    _mcqBusy.clear();
    _sbaSelected.clear();
    _sbaLocked.clear();
    _sbaBusy.clear();

    final questions = model.questions ?? {};
    final submitted = model.submittedAnswers ?? {};

    for (final entry in questions.entries) {
      final qId = entry.key;
      final q = entry.value;
      if (q.isMCQ) {
        final ans = submitted[qId]?.answer;
        final states = _parseMcq(ans);
        _mcqStates[qId] = states;
        _mcqLocks[qId] = List<bool>.generate(5, (i) => states[i] != null);
        _mcqBusy[qId] = List<bool>.filled(5, false);
      } else if (q.isSBA) {
        final ans = submitted[qId]?.answer;
        final letter =
        (ans ?? '').trim().isEmpty ? null : ans!.trim().toUpperCase();
        _sbaSelected[qId] = letter;
        if (letter != null) {
          _sbaLocked.add(qId);
        }
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
        // Only now do a setState so the UI disables interactions.
        setState(() {});
      } else {
        _secondsLeft -= 1;
        _secondsVN.value = _secondsLeft; // updates timer UI only
      }
    });
  }

  // ---------- MCQ helpers ----------
  List<bool?> _parseMcq(String? input) {
    const len = 5;
    final out = List<bool?>.filled(len, null);
    if (input == null || input.isEmpty) return out;
    for (var i = 0; i < len && i < input.length; i++) {
      final c = input[i].toUpperCase();
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
    for (var i = 0; i < 5; i++) {
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
    required String optionLetter, // 'A'..'E'
  }) async {
    if (_timeUp) return;
    if (_sbaLocked.contains(questionId)) return;
    if (_sbaBusy.contains(questionId)) return;

    _sbaBusy.add(questionId); // guard immediately

    final prev = _sbaSelected[questionId];
    setState(() {
      _sbaSelected[questionId] = optionLetter;
      // Optimistic lock: disable instantly
      _sbaLocked.add(questionId);
    });

    final resp = await _submitService.submitSingleAnswer(
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
            (_model?.submittedAnswers?[questionId] ??
                const SubmittedAnswer())
                .copyWith(answer: optionLetter, questionTypeId: 2);
      });

      // ✅ Force rebuild to refresh tab counts
      if (mounted) setState(() {});

    } else {
      setState(() {
        // revert lock & selection on failure
        _sbaSelected[questionId] = prev;
        _sbaLocked.remove(questionId);
      });
      _showSnack(resp.errorMessage ?? 'Failed to submit answer');
    }

    _sbaBusy.remove(questionId);
  }

  Future<void> _onSelectMCQ({
    required int questionId,
    required String examQuestionId,
    required int index, // 0..4
    required bool value, // true for 'T', false for 'F'
  }) async {
    if (_timeUp) return;

    // Create/access busy list for this question
    final busyList = _mcqBusy.putIfAbsent(
      questionId,
          () => List<bool>.filled(5, false),
    );

    // If this statement is already busy or locked, ignore
    if (busyList[index] == true) return;

    final locks =
    _mcqLocks.putIfAbsent(questionId, () => List<bool>.filled(5, false));
    if (locks[index] == true) return;

    // Mark busy immediately to guard against ultra-fast double taps
    busyList[index] = true;

    // Prepare local state
    final states = List<bool?>.from(
      _mcqStates.putIfAbsent(questionId, () => List<bool?>.filled(5, null)),
    );
    final prev = states[index];
    states[index] = value;
    final answerStr = _buildMcq(states);

    // Optimistic lock: disable the pair instantly
    final newLocks = List<bool>.from(locks)..[index] = true;

    setState(() {
      _mcqStates[questionId] = states;
      _mcqLocks[questionId] = newLocks;
    });

    final resp = await _submitService.submitSingleAnswer(
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
            (_model?.submittedAnswers?[questionId] ??
                const SubmittedAnswer())
                .copyWith(answer: answerStr, questionTypeId: 1);
      });

      // ✅ Force rebuild to refresh tab counts
      if (mounted) setState(() {});
      // Keep lock true on success
    } else {
      // Revert state & unlock on failure
      final revertedStates = List<bool?>.from(states)..[index] = prev;
      final revertedLocks = List<bool>.from(newLocks)..[index] = false;

      setState(() {
        _mcqStates[questionId] = revertedStates;
        _mcqLocks[questionId] = revertedLocks;
      });

      _showSnack(resp.errorMessage ?? 'Failed to submit answer');
    }

    // Clear busy (lock controls future interaction anyway, but this is clean)
    busyList[index] = false;
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

    final resp = await _finishService.fetchFinishExam(
      admissionId.toString(),
      examId.toString(),
    );

    if (!mounted) return;

    if (resp.isSuccess) {
      final msg = (resp.responseData is Map &&
          (resp.responseData as Map)['message'] != null)
          ? (resp.responseData as Map)['message'].toString()
          : 'Exam finished successfully';

      // ⬇️ Dialog returns true if it already navigated to results.
      final bool navigated =
          await _showFinishFeedbackDialog(successMessage: msg) ?? false;

      if (!navigated && mounted) {
        // If the user skipped/closed without navigation, fall back to previous behavior:
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
                            // Header
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
                            // ⬇️ from helpers
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
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                ),
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
                                      final resp = await service
                                          .submitExamFeedback(
                                        admissionId:
                                        admissionId.toString(),
                                        examId: examId.toString(),
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

                                        // Close the dialog, returning "navigated = true"
                                        Navigator.pop(context, true);

                                        final data = {
                                          'admissionId':
                                          (admissionId).toString(),
                                          'examId': (examId).toString(),
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
                                          color:
                                          AppColor.purple.withOpacity(0.28),
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
            ? ErrorCard(
            message: _loadError!, onRetry: _load) // ⬅️ from helpers
            : _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final examTitle = _model?.exam?.title ?? '—';

    return Column(
      children: [
        // Title
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
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700, fontSize: Sizes.titleText(context)),
                ),
              ),
            ],
          ),
        ),

        // Timer + Finish button row
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

        // Tabs
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
              final locked = _sbaLocked.contains(qId);
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
                    enabled: enabled && !locked,
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
              final states =
                  _mcqStates[qId] ?? List<bool?>.filled(5, null);
              final locks =
                  _mcqLocks[qId] ?? List<bool>.filled(5, false);
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
                        // Header
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

                        // Message
                        Text(
                          message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.9),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Actions
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
                            // Gradient primary action (uses warningGradient)
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
    ).then((value) {
      return value;
    });
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
              onPressed: () => Navigator.pop(context), child: Text(positive))
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
