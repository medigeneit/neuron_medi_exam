import 'package:flutter/material.dart';

import 'package:medi_exam/data/models/easy_finder_keywords_model.dart';
import 'package:medi_exam/data/models/easy_finder_questions_model.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/services/easy_finder_keywords_service.dart';
import 'package:medi_exam/data/services/easy_finder_questions_service.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';

import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';
import 'package:medi_exam/presentation/widgets/helpers/exam_questions_screen_helpers.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';

import 'package:medi_exam/presentation/widgets/easy_finder_search_bar_card.dart';
import 'package:medi_exam/presentation/widgets/easy_finder_subject_group_widget.dart';

class EasyFinderScreen extends StatefulWidget {
  const EasyFinderScreen({super.key});

  @override
  State<EasyFinderScreen> createState() => _EasyFinderScreenState();
}

class _EasyFinderScreenState extends State<EasyFinderScreen> {
  final EasyFinderQuestionsService _service = EasyFinderQuestionsService();
  final EasyFinderKeywordsService _keywordService = EasyFinderKeywordsService();

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  // Search results
  bool _loading = false;
  String? _error;

  String _lastQuery = '';
  bool _searchedOnce = false;

  EasyFinderQuestionsModel? _model;

  /// Subject -> Chapter -> Topic -> List<Question>
  Map<String, Map<String, Map<String, List<EasyFinderQuestionItem>>>> _grouped =
  {};

  /// For #1, #2 ... (based on API order)
  Map<int, String> _indexLabelById = {};

  /// Global answer toggle (appbar)
  bool _showAllAnswers = false;

  /// ✅ Persisted recent queries (last 5)
  final List<String> _recentQueries = <String>[];

  /// ✅ Keywords (suggestion)
  bool _keywordsLoading = true;
  String? _keywordsError;
  List<String> _allKeywords = <String>[];
  List<String> _suggestions = <String>[];

  final ScrollController _suggestionScrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();

    _loadRecentQueries();
    _loadKeywords();

    _controller.addListener(_onQueryChanged);
    _focus.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onQueryChanged);
    _focus.removeListener(_onFocusChanged);
    _suggestionScrollCtrl.dispose();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // Recent searches (persist)
  // ------------------------------------------------------------
  void _loadRecentQueries() {
    final list = LocalStorageService.getStringList(
      LocalStorageService.easyFinderRecentSearches,
    );

    setState(() {
      _recentQueries
        ..clear()
        ..addAll(list.take(5));
    });
  }

  Future<void> _saveRecentQueries() async {
    await LocalStorageService.setStringList(
      LocalStorageService.easyFinderRecentSearches,
      _recentQueries.take(5).toList(),
    );
  }

  void _addToRecent(String query) {
    final q = query.trim();
    if (q.isEmpty) return;

    _recentQueries.removeWhere((e) => e.toLowerCase() == q.toLowerCase());
    _recentQueries.insert(0, q);

    if (_recentQueries.length > 5) {
      _recentQueries.removeRange(5, _recentQueries.length);
    }

    _saveRecentQueries();
  }

  Future<void> _clearRecent() async {
    setState(() => _recentQueries.clear());
    await LocalStorageService.remove(LocalStorageService.easyFinderRecentSearches);
  }

  // ------------------------------------------------------------
  // Keywords (suggestions)
  // ------------------------------------------------------------
  Future<void> _loadKeywords() async {
    setState(() {
      _keywordsLoading = true;
      _keywordsError = null;
      _allKeywords = <String>[];
      _suggestions = <String>[];
    });

    final NetworkResponse res = await _keywordService.fetchAllKeywords();

    if (!mounted) return;

    if (!res.isSuccess || res.responseData == null) {
      setState(() {
        _keywordsLoading = false;
        _keywordsError = res.errorMessage ?? 'Failed to load keywords';
      });
      return;
    }

    try {
      final data = res.responseData;
      final EasyFinderKeywordsModel model = data is EasyFinderKeywordsModel
          ? data
          : EasyFinderKeywordsModel.fromAny(data);

      final items = model.items ?? const <String>[];

      setState(() {
        _allKeywords = items;
        _keywordsLoading = false;
      });

      _updateSuggestions();
    } catch (e) {
      setState(() {
        _keywordsLoading = false;
        _keywordsError = 'Failed to parse keywords: $e';
      });
    }
  }

  void _onQueryChanged() {
    _updateSuggestions();
  }

  void _onFocusChanged() {
    if (!_focus.hasFocus) {
      if (_suggestions.isNotEmpty) setState(() => _suggestions = <String>[]);
    } else {
      _updateSuggestions();
    }
  }

  String _normalize(String s) => s.trim().toLowerCase();

  void _updateSuggestions() {
    if (!_focus.hasFocus) return;

    final q = _controller.text.trim();
    if (q.isEmpty || _allKeywords.isEmpty) {
      if (_suggestions.isNotEmpty) setState(() => _suggestions = <String>[]);
      return;
    }

    final nq = _normalize(q);

    final starts = <String>[];
    final contains = <String>[];

    for (final k in _allKeywords) {
      final nk = _normalize(k);
      if (nk.isEmpty) continue;

      if (nk.startsWith(nq)) {
        starts.add(k);
      } else if (nk.contains(nq)) {
        contains.add(k);
      }
    }

    final merged = <String>[]..addAll(starts)..addAll(contains);

    final out = <String>[];
    final seen = <String>{};

    for (final s in merged) {
      final key = s.toLowerCase();
      if (seen.contains(key)) continue;
      seen.add(key);
      out.add(s);
      if (out.length >= 20) break; // ✅ allow more before scrolling
    }

    final same = out.length == _suggestions.length &&
        List.generate(out.length, (i) => out[i] == _suggestions[i])
            .every((x) => x);

    if (!same) setState(() => _suggestions = out);
  }

  // ------------------------------------------------------------
  // Search
  // ------------------------------------------------------------
  Future<void> _search(String q, {required bool saveToHistory}) async {
    final query = q.trim();
    if (query.isEmpty) return;

    if (_suggestions.isNotEmpty) {
      setState(() => _suggestions = <String>[]);
    }

    setState(() {
      _loading = true;
      _error = null;
      _searchedOnce = true;
      _lastQuery = query;
    });

    final NetworkResponse res = await _service.fetchEasyFinderQuestions(query);

    if (!mounted) return;

    if (!res.isSuccess || res.responseData == null) {
      setState(() {
        _loading = false;
        _error = res.errorMessage ?? 'Failed to load search results';
      });
      return;
    }

    try {
      final data = res.responseData;
      final EasyFinderQuestionsModel model = data is EasyFinderQuestionsModel
          ? data
          : EasyFinderQuestionsModel.fromAny(data);

      final items = model.items ?? const <EasyFinderQuestionItem>[];

      final grouped =
      <String, Map<String, Map<String, List<EasyFinderQuestionItem>>>>{};
      final indexMap = <int, String>{};

      for (int i = 0; i < items.length; i++) {
        final e = items[i];
        final id = e.safeId;
        if (id != 0) indexMap[id] = '#${i + 1}';

        final subject = (e.subject?.safeName.isNotEmpty ?? false)
            ? e.subject!.safeName
            : 'Unknown Subject';
        final chapter = (e.chapter?.safeName.isNotEmpty ?? false)
            ? e.chapter!.safeName
            : 'Unknown Chapter';
        final topic = (e.topic?.safeName.isNotEmpty ?? false)
            ? e.topic!.safeName
            : 'Unknown Topic';

        grouped.putIfAbsent(subject, () => {});
        grouped[subject]!.putIfAbsent(chapter, () => {});
        grouped[subject]![chapter]!.putIfAbsent(topic, () => []);
        grouped[subject]![chapter]![topic]!.add(e);
      }

      setState(() {
        _model = model;
        _grouped = grouped;
        _indexLabelById = indexMap;
        _loading = false;

        if (saveToHistory) _addToRecent(query);
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Failed to parse results: $e';
      });
    }
  }

  Future<void> _refresh() async {
    if (_lastQuery.trim().isEmpty) return;
    await _search(_lastQuery, saveToHistory: false);
  }

  void _toggleAllAnswers() {
    setState(() => _showAllAnswers = !_showAllAnswers);
  }

  void _tapRecentChip(String query) {
    _controller.text = query;
    _controller.selection = TextSelection.collapsed(offset: query.length);
    _focus.unfocus();
    _search(query, saveToHistory: true);
  }

  void _tapSuggestion(String keyword) {
    _controller.text = keyword;
    _controller.selection = TextSelection.collapsed(offset: keyword.length);
    _focus.unfocus();
    _search(keyword, saveToHistory: true);
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final bool showSuggestions =
        _focus.hasFocus && _controller.text.trim().isNotEmpty && _suggestions.isNotEmpty;

    return CommonScaffold(
      title: 'Smart Search',
      actions: [
        IconButton(
          tooltip: _showAllAnswers ? 'Hide answers' : 'Show answers',
          onPressed: _toggleAllAnswers,
          icon: Icon(
            _showAllAnswers ? Icons.visibility_off_rounded : Icons.visibility_rounded,
          ),
        ),
      ],
      body: Column(
        children: [
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: EasyFinderSearchBarCard(
              controller: _controller,
              focusNode: _focus,
              onSearch: (text) => _search(text, saveToHistory: true),
              hintText: 'Search any question (title / option)...',
            ),
          ),

          const SizedBox(height: 10),

          // ✅ NEW: If suggestions are showing, they take the full remaining space.
          if (showSuggestions)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _suggestionsCard(context),
              ),
            )
          else ...[
            // Recent (only when input empty)
            if (_recentQueries.isNotEmpty && _controller.text.trim().isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _recentChipsCard(context),
              ),
            const SizedBox(height: 10),

            // Results
            Expanded(child: _buildBody(context)),
          ],
        ],
      ),
    );
  }

  Widget _suggestionsCard(BuildContext context) {
    final q = _controller.text.trim();

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header
            Row(
              children: [
                Icon(Icons.auto_awesome_rounded,
                    size: 16, color: AppColor.purple.withOpacity(0.85)),
                const SizedBox(width: 8),
                Text(
                  'Suggestions',
                  style: TextStyle(
                    fontSize: Sizes.verySmallText(context),
                    fontWeight: FontWeight.w900,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                if (_keywordsLoading)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // ✅ Scrollbar + scrollable list
            Expanded(
              child: Scrollbar(
                controller: _suggestionScrollCtrl,
                thumbVisibility: true, // ✅ always show thumb
                radius: const Radius.circular(12),
                thickness: 4,
                child: ListView.separated(
                  controller: _suggestionScrollCtrl,
                  padding: EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, __) => Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    color: Colors.grey.withOpacity(0.10),
                  ),
                  itemBuilder: (context, i) {
                    final s = _suggestions[i];
                    return _SuggestionRow(
                      text: s,
                      query: q,
                      onTap: () => _tapSuggestion(s),
                    );
                  },
                ),
              ),
            ),

            if (_keywordsError != null && _allKeywords.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _keywordsError!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _recentChipsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history_rounded,
                  size: 16, color: AppColor.indigo.withOpacity(0.8)),
              const SizedBox(width: 8),
              Text(
                'Recent',
                style: TextStyle(
                  fontSize: Sizes.verySmallText(context),
                  fontWeight: FontWeight.w900,
                  color: Colors.grey.shade800,
                ),
              ),
              const Spacer(),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: _clearRecent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.red.withOpacity(0.16)),
                    ),
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.red.shade700,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentQueries
                .take(5)
                .map((q) => _SearchChip(text: q, onTap: () => _tapRecentChip(q)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) return const Center(child: LoadingWidget());

    if (_error != null) {
      return ErrorCardExam(message: _error!, onRetry: _refresh);
    }

    // if user typed something but didn’t search yet, show nothing
    if (!_searchedOnce) {
      final typing = _controller.text.trim().isNotEmpty;
      if (typing) {
        return const SizedBox.shrink();
      }

      return _emptyState(
        context,
        icon: Icons.manage_search_rounded,
        title: 'Search anything',
        subtitle: 'Type a keyword and press search.',
      );
    }

    final allItems = _model?.items ?? const <EasyFinderQuestionItem>[];
    if (allItems.isEmpty) {
      return _emptyState(
        context,
        icon: Icons.search_off_rounded,
        title: 'No results',
        subtitle: 'Try another keyword.',
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColor.primaryColor,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: _grouped.keys.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final subjectName = _grouped.keys.elementAt(index);
          final chapters = _grouped[subjectName] ?? {};

          return EasyFinderSubjectGroupWidget(
            subjectName: subjectName,
            chapters: chapters,
            indexLabelById: _indexLabelById,
            showAllAnswers: _showAllAnswers,
          );
        },
      ),
    );
  }

  Widget _emptyState(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
      }) {
    return ListView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        const SizedBox(height: 8),
        GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 44, color: Colors.grey.shade400),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: Sizes.bodyText(context),
                    fontWeight: FontWeight.w900,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
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
      ],
    );
  }
}

// ------------------------------------------------------------
// Small UI pieces
// ------------------------------------------------------------
class _SuggestionRow extends StatelessWidget {
  final String text;
  final String query;
  final VoidCallback onTap;

  const _SuggestionRow({
    required this.text,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = text;
    final q = query.trim().toLowerCase();
    final low = t.toLowerCase();
    final idx = q.isEmpty ? -1 : low.indexOf(q);

    TextSpan span;
    if (idx >= 0 && q.isNotEmpty) {
      span = TextSpan(
        children: [
          TextSpan(text: t.substring(0, idx)),
          TextSpan(
            text: t.substring(idx, idx + q.length),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          TextSpan(text: t.substring(idx + q.length)),
        ],
      );
    } else {
      span = TextSpan(text: t);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.search_rounded,
                  size: 16, color: AppColor.primaryColor.withOpacity(0.85)),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: Sizes.smallText(context),
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade800,
                      height: 1.0,
                    ),
                    children: span.children ?? [span],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.north_west_rounded,
                  size: 16, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SearchChip({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: AppColor.primaryColor.withOpacity(0.08),
            border: Border.all(color: AppColor.primaryColor.withOpacity(0.14)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history_rounded,
                  size: 14, color: AppColor.primaryColor.withOpacity(0.9)),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: Sizes.verySmallText(context),
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade800,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}