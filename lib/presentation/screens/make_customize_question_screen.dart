// lib/presentation/screens/make_customize_question_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'package:medi_exam/data/models/free_exam_quota_model.dart';
import 'package:medi_exam/data/services/free_exam_quota_service.dart';

import 'package:medi_exam/data/services/free_exam_create_service.dart';
import 'package:medi_exam/data/models/free_exam_create_model.dart';

import 'package:medi_exam/data/utils/auth_checker.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/header_info_container.dart';
import 'package:medi_exam/presentation/widgets/helpers/make_customize_question_helpers.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';

// ✅ SAME imports used by FreeExamListScreen for overview flow
import 'package:medi_exam/data/models/exam_property_model.dart';
import 'package:medi_exam/data/services/exam_property_service.dart';
import 'package:medi_exam/data/utils/urls.dart';
import 'package:medi_exam/presentation/widgets/exam_overview_dialog.dart';

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

  final _logger = Logger();

  // ✅ SAME service used by FreeExamListScreen
  final ExamPropertyService _examPropertyService = ExamPropertyService();

  // ---- args ----
  late String courseTitle;
  late int specialtyId;
  late String specialtyName;
  late int subjectId;
  late String subjectName;

  late List<Map<String, dynamic>> selectedChapters;
  late List<Map<String, dynamic>> selectedTopics;

  int selectedQuestionPool = 0; // internal only

  // ---- exam config ----
  int mcqCount = 5;
  int sbaCount = 5;

  // ---- user type ----
  bool isPremiumUser = false;

  // ✅ FREE QUOTA
  final FreeExamQuotaService _quotaService = FreeExamQuotaService();
  bool _quotaLoading = true;
  String? _quotaError;
  FreeExamQuotaModel? _quota;

  // ✅ CREATE EXAM API
  final FreeExamCreateService _createService = FreeExamCreateService();
  bool _creatingExam = false;

  @override
  void initState() {
    super.initState();

    final args = (Get.arguments as Map<String, dynamic>?) ?? {};

    courseTitle = (args['courseTitle'] ?? 'Customize Exam').toString();
    specialtyId = _asInt(args['specialtyId']) ?? 0;
    specialtyName = (args['specialtyName'] ?? '').toString();
    subjectId = _asInt(args['subjectId']) ?? 0;
    subjectName = (args['subjectName'] ?? '').toString();

    selectedChapters =
        (args['selectedChapters'] as List?)?.cast<Map<String, dynamic>>() ??
            <Map<String, dynamic>>[];

    selectedTopics =
        (args['selectedTopics'] as List?)?.cast<Map<String, dynamic>>() ??
            <Map<String, dynamic>>[];

    isPremiumUser = (args['isPremiumUser'] == true);

    selectedQuestionPool =
        _asInt(args['selectedQuestionCount']) ?? _calcPoolFromTopics(selectedTopics);

    // initialize defaults (min 10, not exceeding plan cap)
    final cap = _maxAllowedByPlan; // while quota loading: provisional cap
    final safeInitial = math.max(_minExamQ, math.min(_freeMaxQ, cap)).toInt();
    mcqCount = safeInitial;
    sbaCount = 0;

    _normalizeCounts();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchQuota();
    });
  }

  // ------------------ UI: No questions dialog ------------------

  void _showNoQuestionsDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: CustomBlobBackground(
            backgroundColor: AppColor.whiteColor,
            blobColor: AppColor.purple,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      size: 30,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "No questions available",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Looks like there aren’t any questions available for this selection right now.\nTry selecting more topics/chapters or choose a different subject.",
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context); // close dialog
                            Get.back(); // go back to topic selection
                          },
                          child: const Text(
                            "Go back",
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: AppColor.indigo,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Okay",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ------------------ QUOTA API ------------------

  Future<void> _fetchQuota() async {
    if (isPremiumUser) {
      if (mounted) {
        setState(() {
          _quotaLoading = false;
          _quotaError = null;
          _quota = null;
        });
      }
      return;
    }

    setState(() {
      _quotaLoading = true;
      _quotaError = null;
      _quota = null;
    });

    try {
      final authed = await AuthChecker.to.isAuthenticated();
      if (!authed) {
        setState(() {
          _quotaLoading = false;
          _quotaError = 'Login required to check free exam quota.';
        });
        _normalizeCounts();
        return;
      }

      final res = await _quotaService.fetchFreeExamQuota();

      if (res.isSuccess && res.responseData != null) {
        final model = res.responseData as FreeExamQuotaModel;

        setState(() {
          _quota = model;
          _quotaLoading = false;
          _quotaError = null;
        });

        _normalizeCounts();

        if (_maxAllowedByPlan > 0 && totalSelected == 0) {
          setState(() {
            mcqCount = _maxAllowedByPlan;
            sbaCount = 0;
            _normalizeCounts();
          });
        }
      } else {
        setState(() {
          _quotaLoading = false;
          _quotaError = res.errorMessage ?? 'Failed to load free exam quota.';
        });
        _normalizeCounts();
      }
    } catch (e) {
      setState(() {
        _quotaLoading = false;
        _quotaError = 'Quota check failed: ${e.toString()}';
      });
      _normalizeCounts();
    }
  }

  int get _remainingToday => _quota?.remainingQuestions ?? 0;

  bool get _quotaAllowsCreate {
    if (isPremiumUser) return true;
    if (_quotaLoading) return false;
    if (_quotaError != null) return false;
    if (_quota?.canCreateExam != true) return false;
    if (_remainingToday < _minExamQ) return false;
    return true;
  }

  // ------------------ CORE LOGIC ------------------

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

  int get _maxAllowedByPlan {
    final poolCap = _maxAllowedByPool;

    if (isPremiumUser) return poolCap;

    if (_quotaLoading) return math.min(_freeMaxQ, poolCap);

    if (_quota?.canCreateExam != true) return 0;

    return math.min(_freeMaxQ, math.min(_remainingToday, poolCap));
  }

  bool get meetsMin => totalSelected >= _minExamQ;
  bool get withinPool => totalSelected <= selectedQuestionPool;
  bool get lockedByFree => !isPremiumUser && totalSelected > _freeMaxQ;
  bool get withinPlan => totalSelected <= _maxAllowedByPlan;

  bool get canCreate =>
      _quotaAllowsCreate && meetsMin && withinPool && withinPlan;

  int _floorTo5(int v) {
    if (v <= 0) return 0;
    return (v ~/ 5) * 5;
  }

  void _normalizeCounts() {
    final cap = _maxAllowedByPlan;

    if (cap <= 0) {
      mcqCount = 0;
      sbaCount = 0;
      return;
    }

    mcqCount = _floorTo5(mcqCount);
    sbaCount = _floorTo5(sbaCount);

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

    mcqCount = _floorTo5(mcqCount);
    sbaCount = _floorTo5(sbaCount);
  }

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
        totalPool: selectedQuestionPool, // internal only (dialog hides it)
      ),
    );
  }

  // ------------------ ✅ API PAYLOAD BUILDER ------------------

  List<int> _extractChapterIds() {
    final ids = <int>[];
    for (final c in selectedChapters) {
      final id = _asInt(c['id'] ?? c['chapter_id']);
      if (id != null && id > 0) ids.add(id);
    }
    return ids;
  }

  List<int> _extractTopicIds() {
    final ids = <int>[];
    for (final t in selectedTopics) {
      final id = _asInt(t['id'] ?? t['topic_id']);
      if (id != null && id > 0) ids.add(id);
    }
    return ids;
  }

  FreeExamCreateRequestModel _buildCreateRequestModel() {
    final chapterIds = _extractChapterIds();
    final topicIds = _extractTopicIds();

    final sets = <FreeExamCreateQuestionSetRequest>[];

    if (mcqCount > 0) {
      sets.add(
        FreeExamCreateQuestionSetRequest(
          freeExamTypeId: 1,
          totalQuestions: mcqCount,
        ),
      );
    }
    if (sbaCount > 0) {
      sets.add(
        FreeExamCreateQuestionSetRequest(
          freeExamTypeId: 2,
          totalQuestions: sbaCount,
        ),
      );
    }

    return FreeExamCreateRequestModel(
      subjectId: subjectId,
      specialtyId: specialtyId,
      chapterIds: chapterIds,
      topicIds: topicIds,
      questionSets: sets,
    );
  }

  // ===========================================================
  // ✅ SAME functionality as FreeExamListScreen._freeExamOverview
  // ===========================================================
  Future<void> _openFreeExamOverviewByExamId(String examId) async {
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
      if (examId.trim().isEmpty) {
        throw Exception('Unable to determine exam id for this free exam.');
      }

      final String url = Urls.freeExamProperty(examId);
      final res = await _examPropertyService.fetchExamProperty(url);

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
          'Unexpected response data type: ${res.responseData.runtimeType}',
        );
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
      _logger.e('Error loading FREE exam property (created exam): $e');
    }
  }

  // ------------------ ✅ CREATE EXAM ACTION ------------------

  Future<void> _onCreateExam() async {
    if (_creatingExam) return;

    // ✅ NEW: if pool has no questions, show dialog (even if button is tapped)
    if (selectedQuestionPool <= 0) {
      _showNoQuestionsDialog();
      return;
    }

    if (!isPremiumUser) {
      if (_quotaLoading) {
        Get.snackbar(
          'Please wait',
          'Checking free exam quota...',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEFF6FF),
          colorText: const Color(0xFF111827),
          duration: const Duration(seconds: 2),
        );
        return;
      }

      if (_quotaError != null) {
        Get.snackbar(
          'Quota unavailable',
          _quotaError!,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFFF7ED),
          colorText: const Color(0xFF111827),
          duration: const Duration(seconds: 3),
        );
        return;
      }

      if (_quota?.canCreateExam != true) {
        Get.snackbar(
          'Free exam limit reached',
          'You already used your free Subject-wise exam for today.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFFF7ED),
          colorText: const Color(0xFF111827),
          duration: const Duration(seconds: 3),
        );
        return;
      }

      if (_remainingToday < _minExamQ) {
        Get.snackbar(
          'Not enough free quota',
          'You don’t have enough remaining quota to create an exam right now.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFFF7ED),
          colorText: const Color(0xFF111827),
          duration: const Duration(seconds: 3),
        );
        return;
      }
    }

    if (!canCreate) {
      String msg;
      if (!withinPool) {
        msg = 'Your selection exceeds the available pool.';
      } else if (!meetsMin) {
        msg = 'Select at least $_minExamQ questions.';
      } else if (lockedByFree) {
        msg = 'More than $_freeMaxQ questions is a premium feature.';
      } else if (!withinPlan) {
        msg = isPremiumUser
            ? 'Please adjust within your available pool.'
            : 'Please adjust your selection within today’s free limit.';
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

    setState(() => _creatingExam = true);

    try {
      final requestModel = _buildCreateRequestModel();
      final res = await _createService.createFreeExam(requestModel);

      if (res.isSuccess && res.responseData != null) {
        final model = res.responseData as FreeExamCreateResponseModel;

        if (!mounted) return;
        setState(() => _creatingExam = false);

        final createdExamId = model.exam?.examId?.toString() ?? '';

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => FreeExamCreatedDialog(
            examId: createdExamId,
            totalQuestions: model.exam?.totalQuestions ?? totalSelected,
            todayMax: _maxAllowedByPlan <= 0 ? _freeMaxQ : _maxAllowedByPlan,
            onAttendNow: () async {
              Get.back();

              if (createdExamId.trim().isEmpty) {
                Get.snackbar(
                  'Failed',
                  'Exam created but exam id is missing.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.shade100,
                  colorText: Colors.black,
                  duration: const Duration(seconds: 3),
                );
                return;
              }

              await _openFreeExamOverviewByExamId(createdExamId);
            },
            onAttendLater: () {
              Get.back();
              Get.offNamed(RouteNames.freeExamList);
            },
          ),
        );
      } else {
        setState(() => _creatingExam = false);
        Get.snackbar(
          'Failed',
          res.errorMessage ?? 'Exam creation failed.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFFF7ED),
          colorText: const Color(0xFF111827),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      setState(() => _creatingExam = false);
      Get.snackbar(
        'Error',
        'Exam creation failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFF7ED),
        colorText: const Color(0xFF111827),
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: HeaderInfoContainer(
                    title: courseTitle,
                    subtitle: 'Discipline/Faculty: $specialtyName',
                    additionalText: 'Subject: $subjectName',
                    color: AppColor.purple,
                    icon: Icons.tune_rounded,
                  ),
                ),
              ),

              if (!isPremiumUser)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                    child: QuotaStatusBanner(
                      isDark: isDark,
                      loading: _quotaLoading,
                      error: _quotaError,
                      quota: _quota,
                      minRequired: _minExamQ,
                      todayMax: planCap,
                    ),
                  ),
                ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                  child: SelectionSummaryCompactCard(
                    isDark: isDark,
                    totalPool: pool,
                    poolCap: poolCap,
                    planCap: planCap,
                    selectedChapters: selectedChapters,
                    selectedTopics: selectedTopics,
                    topicsCount: selectedTopics.length,
                    minExamQ: _minExamQ,
                    freeMaxExamQ: _freeMaxQ,
                    isPremiumUser: isPremiumUser,
                    onViewSelected: () => _showSelectedContentDialog(isDark),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                  child: ExamQuantityCard(
                    isDark: isDark,
                    pool: pool,
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
                    onPresetTap: (_) {},
                  ),
                ),
              ),

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

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CreateExamBottomBarCompact(
              canCreate: canCreate,
              isLoading: _creatingExam,
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

// ===========================================================
// ✅ dialog (same as before)
// ===========================================================
class FreeExamCreatedDialog extends StatelessWidget {
  final String examId;
  final int totalQuestions;
  final int todayMax;

  final Future<void> Function() onAttendNow;
  final VoidCallback onAttendLater;

  const FreeExamCreatedDialog({
    Key? key,
    required this.examId,
    required this.totalQuestions,
    required this.todayMax,
    required this.onAttendNow,
    required this.onAttendLater,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: CustomBlobBackground(
        backgroundColor: AppColor.whiteColor,
        blobColor: AppColor.indigo,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 34,
                  color: Color(0xFF16A34A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Exam Created ✅",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Your exam is ready. Start now or attend later anytime.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: onAttendLater,
                      child: Text(
                        "Attend Later",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppColor.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        onAttendNow();
                      },
                      child: const Text(
                        "Attend Now",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}