// lib/presentation/screens/make_customize_question_screen.dart
//
// Route: RouteNames.makeCustomizeQuestion
//

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/header_info_container.dart';
import 'package:medi_exam/presentation/widgets/helpers/make_customize_question_helpers.dart';

class MakeCustomizeQuestionScreen extends StatefulWidget {
  const MakeCustomizeQuestionScreen({Key? key}) : super(key: key);

  @override
  State<MakeCustomizeQuestionScreen> createState() =>
      _MakeCustomizeQuestionScreenState();
}

class _MakeCustomizeQuestionScreenState
    extends State<MakeCustomizeQuestionScreen> {
  static const int _minExamQ = 10;
  static const int _freeMaxQ = 20; // free user max
  static const int _hardMaxQ = 200; // absolute cap

  // ---- args ----
  late String courseTitle;
  late int specialtyId;
  late String specialtyName;
  late int subjectId;
  late String subjectName;

  late List<Map<String, dynamic>> selectedChapters;
  late List<Map<String, dynamic>> selectedTopics;

  int selectedQuestionPool = 0; // total available from prev selections

  // ---- exam config ----
  int mcqCount = 10;
  int sbaCount = 0;

  // ---- user type (for now) ----
  bool isPremiumUser = false;

  @override
  void initState() {
    super.initState();

    final args = (Get.arguments as Map<String, dynamic>?) ?? {};

    courseTitle = (args['courseTitle'] ?? 'Customize Exam').toString();
    specialtyId = _asInt(args['specialtyId']) ?? 0;
    specialtyName = (args['specialtyName'] ?? '').toString();
    subjectId = _asInt(args['subjectId']) ?? 0;
    subjectName = (args['subjectName'] ?? '').toString();

    selectedChapters = (args['selectedChapters'] as List?)
        ?.cast<Map<String, dynamic>>() ??
        <Map<String, dynamic>>[];

    selectedTopics =
        (args['selectedTopics'] as List?)?.cast<Map<String, dynamic>>() ??
            <Map<String, dynamic>>[];

    isPremiumUser = (args['isPremiumUser'] == true);

    selectedQuestionPool =
        _asInt(args['selectedQuestionCount']) ?? _calcPoolFromTopics(selectedTopics);

    // initialize defaults (min 10, not exceeding plan cap)
    final cap = _maxAllowedByPlan;
    final initial = math.min(_freeMaxQ, cap);
    final safeInitial = math.max(_minExamQ, initial);
    mcqCount = safeInitial;
    sbaCount = 0;

    _normalizeCounts();
  }

  int _calcPoolFromTopics(List<Map<String, dynamic>> topics) {
    int s = 0;
    for (final t in topics) {
      s += _asInt(t['question_count']) ?? 0;
    }
    return s;
  }

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  int get totalSelected => mcqCount + sbaCount;

  int get _maxAllowedByPool => math.min(_hardMaxQ, selectedQuestionPool);

  int get _maxAllowedByPlan =>
      isPremiumUser ? _maxAllowedByPool : math.min(_freeMaxQ, _maxAllowedByPool);

  bool get meetsMin => totalSelected >= _minExamQ;
  bool get withinPool => totalSelected <= selectedQuestionPool;
  bool get lockedByFree => !isPremiumUser && totalSelected > _freeMaxQ;
  bool get withinPlan => totalSelected <= _maxAllowedByPlan;

  bool get canCreate => meetsMin && withinPool && withinPlan;

  void _normalizeCounts() {
    final cap = _maxAllowedByPlan;
    if (cap <= 0) {
      mcqCount = 0;
      sbaCount = 0;
      return;
    }

    mcqCount = mcqCount.clamp(0, cap);
    sbaCount = sbaCount.clamp(0, cap);

    final total = mcqCount + sbaCount;
    if (total > cap) {
      final overflow = total - cap;
      if (mcqCount >= sbaCount) {
        mcqCount = math.max(0, mcqCount - overflow);
      } else {
        sbaCount = math.max(0, sbaCount - overflow);
      }
    }
  }

  // ✅ increment/decrement by 5
  void _incMcq() => setState(() {
    mcqCount += 5;
    _normalizeCounts();
  });

  void _decMcq() => setState(() {
    mcqCount -= 5;
    _normalizeCounts();
  });

  void _incSba() => setState(() {
    sbaCount += 5;
    _normalizeCounts();
  });

  void _decSba() => setState(() {
    sbaCount -= 5;
    _normalizeCounts();
  });

  void _showSelectedContentDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (_) => SelectedContentDialog(
        isDark: isDark,
        courseTitle: courseTitle,
        specialtyName: specialtyName,
        subjectName: subjectName,
        selectedChapters: selectedChapters,
        selectedTopics: selectedTopics,
        totalPool: selectedQuestionPool,
      ),
    );
  }

  Map<String, dynamic> _buildCreatePayload() {
    return {
      'courseTitle': courseTitle,
      'specialtyId': specialtyId,
      'specialtyName': specialtyName,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'selectedChapters': selectedChapters,
      'selectedTopics': selectedTopics,
      'questionPoolCount': selectedQuestionPool,
      'mcqCount': mcqCount,
      'sbaCount': sbaCount,
      'totalExamQuestions': totalSelected,
      'minExamQuestions': _minExamQ,
      'freeMaxExamQuestions': _freeMaxQ,
      'hardMaxExamQuestions': _hardMaxQ,
      'isPremiumUser': isPremiumUser,
      'lockedByFree': lockedByFree,
    };
  }

  void _onCreateExam() {
    // final payload = _buildCreatePayload();

    if (!canCreate) {
      String msg;
      if (!withinPool) {
        msg = 'Your pool has only $selectedQuestionPool questions.';
      } else if (!meetsMin) {
        msg = 'Select at least $_minExamQ questions.';
      } else if (lockedByFree) {
        msg = 'More than $_freeMaxQ questions is a premium feature.';
      } else {
        msg = 'Please adjust your selection.';
      }

      Get.snackbar(
        'Cannot create exam',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFF7ED),
        colorText: const Color(0xFF111827),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // ✅ TODO: proceed to next route / start exam
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final pool = selectedQuestionPool;
    final poolCap = _maxAllowedByPool;
    final planCap = _maxAllowedByPlan;

    return CommonScaffold(
      title: 'Customize Exam',
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: HeaderInfoContainer(
                    title: courseTitle,
                    subtitle: 'Discipline/Faculty: $specialtyName',
                    additionalText: 'Subject: $subjectName',
                    color: AppColor.purple,
                    icon: Icons.tune_rounded,
                  ),
                ),
              ),

              // ✅ summary card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                  child: SelectionSummaryCompactCard(
                    isDark: isDark,
                    totalPool: pool,
                    poolCap: poolCap,
                    planCap: planCap,
                    chaptersCount: selectedChapters.length,
                    topicsCount: selectedTopics.length,
                    minExamQ: _minExamQ,
                    freeMaxExamQ: _freeMaxQ,
                    isPremiumUser: isPremiumUser,
                    onViewSelected: () => _showSelectedContentDialog(isDark),
                  ),
                ),
              ),

              // ✅ quantity card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                  child: ExamQuantityCard(
                    isDark: isDark,
                    mcqCount: mcqCount,
                    sbaCount: sbaCount,
                    total: totalSelected,
                    minTotal: _minExamQ,
                    planMax: planCap,
                    freeMax: _freeMaxQ,
                    isPremiumUser: isPremiumUser,
                    onMcqMinus: _decMcq,
                    onMcqPlus: _incMcq,
                    onSbaMinus: _decSba,
                    onSbaPlus: _incSba,
                    onPresetTap: (_) {}, // ✅ kept for signature, UI removed
                  ),
                ),
              ),

              // ✅ helper/status card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 92),
                  child: StatusHintCompactCard(
                    isDark: isDark,
                    pool: pool,
                    minRequired: _minExamQ,
                    freeMax: _freeMaxQ,
                    isPremiumUser: isPremiumUser,
                    totalSelected: totalSelected,
                  ),
                ),
              ),
            ],
          ),

          // ✅ bottom bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CreateExamBottomBarCompact(
              canCreate: canCreate,
              totalSelected: totalSelected,
              minRequired: _minExamQ,
              onPressed: _onCreateExam,
            ),
          ),
        ],
      ),
    );
  }
}
