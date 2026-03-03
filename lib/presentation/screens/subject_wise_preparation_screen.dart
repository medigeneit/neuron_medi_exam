// lib/presentation/screens/subject_wise_preparation_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/models/active_course_specialties_subjects_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/header_info_container.dart';

class SubjectWisePreparationScreen extends StatefulWidget {
  const SubjectWisePreparationScreen({Key? key}) : super(key: key);

  @override
  State<SubjectWisePreparationScreen> createState() =>
      _SubjectWisePreparationScreenState();
}

class _SubjectWisePreparationScreenState
    extends State<SubjectWisePreparationScreen> {
  // ---- args ----
  late String courseTitle;
  late IconData icon;
  late int specialtyId;
  late String specialtyName;
  late List<Subject> subjects;

  // ---- search (on-query, debounce) ----
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  String _query = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>? ?? {};

    courseTitle = (args['courseTitle'] ?? 'Subject Wise Preparation').toString();
    icon = (args['icon'] is IconData) ? args['icon'] : Icons.school_rounded;

    specialtyId = _asInt(args['specialtyId']) ?? 0;
    specialtyName = (args['specialtyName'] ?? '').toString();

    subjects = (args['subjects'] as List<Subject>?) ?? <Subject>[];

    _searchCtrl.addListener(_onQueryChanged);
  }

  void _onQueryChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () {
      final q = _searchCtrl.text.trim();
      if (!mounted) return;
      if (q != _query) setState(() => _query = q);
    });
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

  bool _isOpen(Subject s) => (s.isOpen ?? false) == true;

  // ✅ Filter + SORT: open first, then locked
  List<Subject> get _filtered {
    final q = _query.trim();
    final low = q.toLowerCase();

    final list = (q.isEmpty)
        ? [...subjects]
        : subjects.where((s) {
      final name = (s.subjectName ?? '').toLowerCase();
      final idStr = (s.subjectId ?? '').toString().toLowerCase();
      return name.contains(low) || idStr.contains(low);
    }).toList();

    // ✅ open first (stable secondary sort by name/id for a consistent order)
    list.sort((a, b) {
      final ao = _isOpen(a);
      final bo = _isOpen(b);
      if (ao != bo) return ao ? -1 : 1;

      final an = (a.subjectName ?? '').toLowerCase();
      final bn = (b.subjectName ?? '').toLowerCase();
      final c = an.compareTo(bn);
      if (c != 0) return c;

      return (a.subjectId ?? 0).compareTo(b.subjectId ?? 0);
    });

    return list;
  }

  int get _lockedCount =>
      subjects.where((s) => (s.isOpen ?? false) == false).length;

  int get _openCount => subjects.where((s) => _isOpen(s)).length;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 380;

    return CommonScaffold(
      title: 'Subject Wise Preparation',
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ---- header card (course + specialty) ----
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: HeaderInfoContainer(
                title: courseTitle,
                subtitle: 'Discipline/Faculty: $specialtyName',
                additionalText: 'Select a subject to start preparing',
                color: AppColor.purple,
                icon: icon,
              ),
            ),
          ),

          // ---- search bar ----
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
              child: _SearchBarWidget(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                isCompact: isCompact,
                onClear: () {
                  _searchCtrl.clear();
                  _searchFocus.requestFocus();
                },
                onSubmitted: (_) => _searchFocus.unfocus(),
              ),
            ),
          ),

          // ---- count row ----
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  if (_query.trim().isEmpty)
                    _TinyChip(
                      icon: Icons.menu_book_rounded,
                      label: '$_openCount open • $_lockedCount locked',
                    )
                  else
                    _TinyChip(
                      icon: Icons.search_rounded,
                      label:
                      '${_filtered.length} match${_filtered.length == 1 ? '' : 'es'} for "$_query"',
                    ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 6)),

          // ---- body: empty OR grid ----
          if (_filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptySubjectsState(
                query: _query,
                onBack: () => Navigator.maybePop(context),
                onClear: () {
                  _searchCtrl.clear();
                  _searchFocus.requestFocus();
                },
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.35,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final s = _filtered[index];
                    final canOpen = _isOpen(s);

                    return _SubjectGridCard(
                      subject: s,
                      canTap: canOpen,
                      highlight: canOpen, // ✅ highlighted if open
                      onTap: () {
                        Get.toNamed(
                          RouteNames.subjectWiseChapterTopics,
                          arguments: {
                            'courseTitle': courseTitle,
                            'icon': Icons.menu_book_rounded,
                            'specialtyId': specialtyId,
                            'specialtyName': specialtyName,
                            'subjectId': s.subjectId,
                            'subjectName': s.subjectName,
                          },
                        );
                      },
                      onLockedTap: () {
                        // optional friendly hint
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "This subject is locked. Get Premium to unlock everything.",
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    );
                  },
                  childCount: _filtered.length,
                ),
              ),
            ),

          // ---- tip banner (locked items) ----
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: _LockedTipBanner(
                lockedCount: _lockedCount,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- UI widgets ----------------

class _LockedTipBanner extends StatelessWidget {
  final int lockedCount;

  const _LockedTipBanner({
    required this.lockedCount,
  });

  @override
  Widget build(BuildContext context) {
    if (lockedCount <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded,
              size: 18, color: Color(0xFF6B7280)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Some subjects are locked. Unlock them anytime with a Premium package.",
              style: TextStyle(
                fontSize: Sizes.verySmallText(context),
                height: 1.25,
                color: const Color(0xFF374151),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectGridCard extends StatefulWidget {
  final Subject subject;
  final bool canTap;
  final bool highlight;
  final VoidCallback onTap;
  final VoidCallback? onLockedTap;

  const _SubjectGridCard({
    required this.subject,
    required this.canTap,
    required this.highlight,
    required this.onTap,
    this.onLockedTap,
  });

  @override
  State<_SubjectGridCard> createState() => _SubjectGridCardState();
}

class _SubjectGridCardState extends State<_SubjectGridCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final gradientColors = [AppColor.indigo, AppColor.purple];
    const double borderRadius = 16;

    final title = widget.subject.subjectName?.trim().isNotEmpty == true
        ? widget.subject.subjectName!.trim()
        : 'Unknown Subject';

    final canTap = widget.canTap;

    // ✅ open subjects look "more premium"
    final openGlow = widget.highlight;

    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: _pressed ? 0.985 : 1.0,
      child: Opacity(
        opacity: canTap ? 1.0 : 0.72,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius + 2),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            boxShadow: openGlow
                ? [
              BoxShadow(
                color: gradientColors[0].withOpacity(0.28),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ]
                : null,
          ),
          padding: const EdgeInsets.all(1.5),
          child: Material(
            color: isDark ? const Color(0xFF121416) : Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: canTap ? widget.onTap : widget.onLockedTap,
              onHighlightChanged: (v) {
                if (!canTap) return;
                setState(() => _pressed = v);
              },
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    _IconBubble(highlight: openGlow),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: Sizes.smallText(context),
                          color: isDark ? Colors.white : Colors.black,
                          height: 1.15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      canTap ? Icons.arrow_forward_rounded : Icons.lock_rounded,
                      size: 18,
                      color: canTap
                          ? (isDark
                          ? Colors.white70
                          : const Color(0xFF4B5563))
                          : const Color(0xFF6B7280),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  final bool highlight;

  const _IconBubble({this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final gradientColors = [AppColor.indigo, AppColor.purple];

    return Container(
      height: Sizes.veryExtraSmallIcon(context) + 16,
      width: Sizes.veryExtraSmallIcon(context) + 16,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(highlight ? 0.35 : 0.22),
            blurRadius: highlight ? 14 : 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(
        Icons.menu_book_rounded,
        size: Sizes.veryExtraSmallIcon(context),
        color: Colors.white,
      ),
    );
  }
}

class _TinyChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TinyChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColor.indigo),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.0,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// ✅ Made Stateful so clear (X) icon updates immediately when typing/clearing
class _SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isCompact;
  final VoidCallback onClear;
  final ValueChanged<String> onSubmitted;

  const _SearchBarWidget({
    required this.controller,
    required this.focusNode,
    required this.isCompact,
    required this.onClear,
    required this.onSubmitted,
  });

  @override
  State<_SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<_SearchBarWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outerBorderRadius = BorderRadius.circular(14);
    final innerBorderRadius = BorderRadius.circular(12.5);
    final gradientColors = [AppColor.indigo, AppColor.purple];

    return Container(
      decoration: BoxDecoration(
        borderRadius: outerBorderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: innerBorderRadius,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              size: 20,
              color: Color(0xFF6B7280),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                textInputAction: TextInputAction.search,
                onSubmitted: widget.onSubmitted,
                style: TextStyle(
                  fontSize: widget.isCompact ? 13.5 : 14.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Search subject...',
                  hintStyle: TextStyle(
                    fontSize: widget.isCompact ? 13.0 : 14.0,
                    color: const Color(0xFF6B7280),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (widget.controller.text.isNotEmpty)
              IconButton(
                onPressed: widget.onClear,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Color(0xFF6B7280),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
                splashRadius: 18,
                tooltip: 'Clear',
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptySubjectsState extends StatelessWidget {
  final String query;
  final VoidCallback onBack;
  final VoidCallback onClear;

  const _EmptySubjectsState({
    required this.query,
    required this.onBack,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    const subtle = Color(0xFF6B7280);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: subtle),
            const SizedBox(height: 10),
            Text(
              query.trim().isEmpty ? 'No subjects found' : 'No results found',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              query.trim().isEmpty
                  ? 'There are no subjects available for this selection right now.'
                  : 'We couldn’t find any results for “$query”.\nTry a different keyword or clear the search.',
              style: const TextStyle(
                fontSize: 13.0,
                height: 1.35,
                color: subtle,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                if (query.trim().isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Clear search'),
                  ),
                TextButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Go back'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColor.indigo,
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
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