import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medi_exam/data/models/subject_wise_chapter_topics_model.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/services/subject_wise_chapter_topics_service.dart';
import 'package:medi_exam/data/utils/auth_checker.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/header_info_container.dart';
import 'package:medi_exam/presentation/widgets/helpers/subject_wise_chapter_topics_helpers.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';

class SubjectWiseChapterTopicsScreen extends StatefulWidget {
  const SubjectWiseChapterTopicsScreen({super.key});

  @override
  State<SubjectWiseChapterTopicsScreen> createState() =>
      _SubjectWiseChapterTopicsScreenState();
}

class _SubjectWiseChapterTopicsScreenState
    extends State<SubjectWiseChapterTopicsScreen> {
  // ✅ Visible requirement
  static const int _minRequiredTopics = 5;

  // ✅ Hidden internal requirement (do NOT show counts in UI)
  static const int _minRequiredQuestionsHidden = 10;

  // ✅ resume keys (unique to avoid collision)
  static const String _kResumeNext = '__resume_next';
  static const String _kResumePayload = '__resume_payload';

  // -------- args --------
  late String courseTitle;
  late IconData icon;

  late int specialtyId;
  late String specialtyName;

  late int subjectId;
  late String subjectName;

  // -------- service/state --------
  final SubjectWiseChapterTopicsService _service =
  SubjectWiseChapterTopicsService();

  bool _loading = true;
  String? _error;
  SubjectWiseChapterTopicsModel? _model;

  // -------- search --------
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  Timer? _debounce;
  String _query = '';

  // -------- selection --------
  final Set<int> _selectedTopicIds = <int>{};

  @override
  void initState() {
    super.initState();

    final args = (Get.arguments as Map<String, dynamic>?) ?? {};

    courseTitle = (args['courseTitle'] ?? 'Subject Wise Topics').toString();
    icon = Icons.menu_book_rounded;

    specialtyId = _asInt(args['specialtyId']) ?? 0;
    specialtyName = (args['specialtyName'] ?? '').toString();

    subjectId = _asInt(args['subjectId']) ?? 0;
    subjectName = (args['subjectName'] ?? '').toString();

    _searchCtrl.addListener(_onQueryChanged);
    _fetch();

    // ✅ if returned from login, auto-resume after first frame
    final bool shouldResume = args[_kResumeNext] == true;
    final dynamic payloadDyn = args[_kResumePayload];

    if (shouldResume && payloadDyn is Map) {
      final resumePayload = Map<String, dynamic>.from(payloadDyn);

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final authed = await AuthChecker.to.isAuthenticated();
        if (!authed) return;
        _goToCustomize(resumePayload);
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.removeListener(_onQueryChanged);
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  void _onQueryChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () {
      final q = _searchCtrl.text.trim();
      if (!mounted) return;
      if (q != _query) setState(() => _query = q);
    });
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final NetworkResponse res = await _service.fetchSubjectWiseChapterTopics(
      specialtyId: specialtyId.toString(),
      subjectId: subjectId.toString(),
    );

    if (!mounted) return;

    if (res.isSuccess) {
      final SubjectWiseChapterTopicsModel m =
      (res.responseData is SubjectWiseChapterTopicsModel)
          ? (res.responseData as SubjectWiseChapterTopicsModel)
          : SubjectWiseChapterTopicsModel.fromJson(
        (res.responseData as Map<String, dynamic>? ?? {}),
      );

      setState(() {
        _model = m;
        _loading = false;
      });
    } else {
      setState(() {
        _error = res.errorMessage ?? 'Failed to load chapters/topics.';
        _loading = false;
      });
    }
  }

  // -------- derived data (FILTER OUT count==0, but NOT showing in UI) --------

  List<Chapter> get _chapters {
    final raw = _model?.chapters ?? <Chapter>[];

    final List<Chapter> cleaned = [];
    for (final c in raw) {
      final cQ = c.questionCount ?? 0;
      if (cQ <= 0) continue;

      final topics = (c.topics ?? <Topic>[])
          .where((t) => (t.questionCount ?? 0) > 0)
          .toList();

      if (topics.isEmpty) continue;

      cleaned.add(
        Chapter(
          chapterId: c.chapterId,
          chapterName: c.chapterName,
          questionCount: c.questionCount,
          topics: topics,
        ),
      );
    }
    return cleaned;
  }

  List<Chapter> get _filteredChapters {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _chapters;

    bool matches(String s) => s.toLowerCase().contains(q);

    final List<Chapter> out = [];
    for (final c in _chapters) {
      final chapterName = (c.chapterName ?? '');
      final topics = c.topics ?? <Topic>[];

      final chapterMatch = matches(chapterName) ||
          (c.chapterId?.toString().toLowerCase().contains(q) ?? false);

      final matchedTopics = topics.where((t) {
        final tn = (t.topicName ?? '');
        return matches(tn) ||
            (t.topicId?.toString().toLowerCase().contains(q) ?? false);
      }).toList();

      if (chapterMatch || matchedTopics.isNotEmpty) {
        out.add(
          Chapter(
            chapterId: c.chapterId,
            chapterName: c.chapterName,
            questionCount: c.questionCount,
            topics: chapterMatch ? topics : matchedTopics,
          ),
        );
      }
    }
    return out;
  }

  int get _selectedTopicsCount => _selectedTopicIds.length;

  // ✅ hidden question sum (used only for validation; never shown in UI)
  int get _selectedQuestionCountHidden {
    int sum = 0;
    for (final c in _chapters) {
      for (final t in (c.topics ?? <Topic>[])) {
        final tid = t.topicId;
        if (tid == null) continue;
        if (_selectedTopicIds.contains(tid)) {
          sum += (t.questionCount ?? 0);
        }
      }
    }
    return sum;
  }

  bool get _meetsTopicRequirement => _selectedTopicsCount >= _minRequiredTopics;

  bool get _canProceed =>
      _meetsTopicRequirement &&
          _selectedQuestionCountHidden >= _minRequiredQuestionsHidden;

  // -------- selection helpers --------

  bool _isTopicSelected(Topic t) {
    final id = t.topicId;
    if (id == null) return false;
    return _selectedTopicIds.contains(id);
  }

  (bool, bool) _chapterSelectionState(Chapter c) {
    final topics = c.topics ?? <Topic>[];
    final ids = topics.map((e) => e.topicId).whereType<int>().toList();
    if (ids.isEmpty) return (false, true);

    final selected = ids.where(_selectedTopicIds.contains).length;
    final allSelected = selected == ids.length;
    final noneSelected = selected == 0;
    return (allSelected, noneSelected);
  }

  void _toggleTopic(Chapter chapter, Topic topic, bool value) {
    final tid = topic.topicId;
    if (tid == null) return;

    setState(() {
      if (value) {
        _selectedTopicIds.add(tid);
      } else {
        _selectedTopicIds.remove(tid);
      }
    });
  }

  void _toggleChapter(Chapter chapter, bool value) {
    final topics = chapter.topics ?? <Topic>[];
    final ids = topics.map((e) => e.topicId).whereType<int>().toList();
    if (ids.isEmpty) return;

    setState(() {
      if (value) {
        _selectedTopicIds.addAll(ids);
      } else {
        _selectedTopicIds.removeAll(ids);
      }
    });
  }

  Map<String, dynamic> _buildNextPayload() {
    final List<Map<String, dynamic>> selectedTopics = [];
    final List<Map<String, dynamic>> selectedChapters = [];

    for (final c in _chapters) {
      final cid = c.chapterId;
      final cName = (c.chapterName ?? '').trim();
      final cCount = c.questionCount ?? 0;

      final topics = c.topics ?? <Topic>[];

      final (allSelected, _) = _chapterSelectionState(c);

      if (cid != null && allSelected) {
        selectedChapters.add({
          'chapter_id': cid,
          'chapter_name': cName,
          'question_count': cCount,
        });
      }

      for (final t in topics) {
        final tid = t.topicId;
        if (tid == null) continue;
        if (!_selectedTopicIds.contains(tid)) continue;

        selectedTopics.add({
          'topic_id': tid,
          'topic_name': (t.topicName ?? '').trim(),
          'question_count': t.questionCount ?? 0,
          'chapter_id': cid,
          'chapter_name': cName,
        });
      }
    }

    return {
      'courseTitle': courseTitle,
      'specialtyId': specialtyId,
      'specialtyName': specialtyName,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'specialty': _model?.specialty?.toJson() ?? {},
      'subject': _model?.subject?.toJson() ?? {},

      'selectedChapters': selectedChapters,
      'selectedTopics': selectedTopics,

      // ✅ for downstream screens / API
      'selectedTopicsCount': _selectedTopicsCount,
      'selectedQuestionCount': _selectedQuestionCountHidden,
      'minRequiredTopics': _minRequiredTopics,
      'minRequiredQuestionCount': _minRequiredQuestionsHidden,
    };
  }

  void _showNeedMoreTopicsSnack() {
    final need = _minRequiredTopics - _selectedTopicsCount;
    Get.snackbar(
      'Pick a Few More Topics',
      'Select at least $_minRequiredTopics topics to continue.\nAdd ${need < 0 ? 0 : need} more topic${need == 1 ? '' : 's'}.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFFFF7ED),
      colorText: const Color(0xFF111827),
      duration: const Duration(seconds: 3),
    );
  }

  void _showNeedMoreCoverageSnack() {
    Get.snackbar(
      'Almost There',
      'Your selected topics don’t have enough practice items yet.\nPlease add a few more topics to continue.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFFFF7ED),
      colorText: const Color(0xFF111827),
      duration: const Duration(seconds: 3),
    );
  }

  void _goToCustomize(Map<String, dynamic> payload) {
    Get.toNamed(
      RouteNames.makeCustomizeQuestion,
      arguments: payload,
    );
  }

  Map<String, dynamic> _buildReturnArgsForResume(Map<String, dynamic> payload) {
    return {
      'courseTitle': courseTitle,
      'specialtyId': specialtyId,
      'specialtyName': specialtyName,
      'subjectId': subjectId,
      'subjectName': subjectName,

      // icon serialize
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'iconFontPackage': icon.fontPackage,
      'iconMatchTextDirection': icon.matchTextDirection,

      // resume flags
      _kResumeNext: true,
      _kResumePayload: payload,
    };
  }

  Future<void> _onNextWithAuthCheckAndResume() async {
    if (_loading) return;

    // ✅ Step-1: must pick at least 5 topics
    if (!_meetsTopicRequirement) {
      _showNeedMoreTopicsSnack();
      return;
    }

    // ✅ Step-2: hidden validation (don’t show question counts, just ask for more topics)
    if (_selectedQuestionCountHidden < _minRequiredQuestionsHidden) {
      _showNeedMoreCoverageSnack();
      return;
    }

    final payload = _buildNextPayload();

    bool authed = false;
    try {
      authed = await AuthChecker.to.isAuthenticated();
    } catch (_) {
      authed = false;
    }

    if (authed) {
      _goToCustomize(payload);
      return;
    }

    Get.snackbar(
      'Login Required',
      'Please log in to continue',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );

    final String returnRoute = Get.currentRoute;

    await Get.toNamed(
      RouteNames.login,
      arguments: {
        'popOnSuccess': false,
        'returnRoute': returnRoute,
        'returnArguments': _buildReturnArgsForResume(payload),
        'message': "You’re one step away! Log in to continue.",
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 380;

    final filtered = _filteredChapters;

    return CommonScaffold(
      title: 'Chapters & Topics',
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: HeaderInfoContainer(
                    title: courseTitle,
                    subtitle: 'Discipline/Faculty: $specialtyName',
                    additionalText: 'Subject: $subjectName',
                    color: AppColor.purple,
                    icon: icon,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
                  child: ChapterTopicSearchBar(
                    controller: _searchCtrl,
                    focusNode: _searchFocus,
                    isCompact: isCompact,
                    hintText: 'Search chapter or topic...',
                    onClear: () {
                      _searchCtrl.clear();
                      _searchFocus.requestFocus();
                    },
                    onSubmitted: (_) => _searchFocus.unfocus(),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      if (_query.trim().isEmpty)
                        TinyInfoChip(
                          icon: Icons.layers_rounded,
                          label: 'Showing ${_chapters.length} chapters',
                        )
                      else
                        TinyInfoChip(
                          icon: Icons.search_rounded,
                          label:
                          '${filtered.length} match${filtered.length == 1 ? '' : 'es'} for "$_query"',
                        ),
                      const SizedBox(width: 6),

                      // ✅ requirement shown as TOPICS only
                      RequirementChip(
                        minTopics: _minRequiredTopics,
                        selectedTopics: _selectedTopicsCount,
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 6)),

              if (_error != null && !_loading)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                    child: ErrorCardModern(
                      message: _error!,
                      onRetry: _fetch,
                    ),
                  ),
                ),

              if (!_loading && _error == null && filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyModernState(
                    query: _query,
                    titleWhenEmpty: 'No chapters found',
                    subtitleWhenEmpty:
                    'No data available for this subject right now.',
                    onBack: () => Navigator.maybePop(context),
                    onClear: () {
                      _searchCtrl.clear();
                      _searchFocus.requestFocus();
                    },
                  ),
                ),

              if (!_loading && _error == null && filtered.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 112),
                  sliver: SliverList.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final chapter = filtered[index];
                      final topics = chapter.topics ?? <Topic>[];

                      final (allSelected, noneSelected) =
                      _chapterSelectionState(chapter);
                      final isIndeterminate = !allSelected && !noneSelected;

                      final topicIds =
                      topics.map((e) => e.topicId).whereType<int>();
                      final selectedInThisChapter =
                          topicIds.where(_selectedTopicIds.contains).length;

                      return ChapterTopicsCard(
                        chapterTitle:
                        (chapter.chapterName ?? 'Unknown Chapter').trim(),
                        topicsCount: topics.length,
                        selectedTopicsCount: selectedInThisChapter,
                        chapterChecked: allSelected,
                        chapterIndeterminate: isIndeterminate,
                        onToggleChapter: (v) => _toggleChapter(chapter, v),
                        isChapterSelected: !noneSelected,
                        topics: topics.map((t) {
                          final tn = (t.topicName ?? 'Unknown Topic').trim();
                          return TopicRowData(
                            id: t.topicId ?? -1,
                            title: tn,
                            checked: _isTopicSelected(t),
                            onChanged: (v) =>
                                _toggleTopic(chapter, t, v ?? false),
                          );
                        }).toList(),
                        isDark: isDark,
                      );
                    },
                  ),
                ),
            ],
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNextBar(
              selectedTopicsCount: _selectedTopicsCount,
              minTopics: _minRequiredTopics,
              buttonText: 'Next',
              onPressed: _onNextWithAuthCheckAndResume,
              gradientColors: const [AppColor.indigo, AppColor.purple],
            ),
          ),

          if (_loading)
            const Positioned.fill(
              child: AbsorbPointer(
                absorbing: true,
                child: Center(child: LoadingWidget()),
              ),
            ),
        ],
      ),
    );
  }
}