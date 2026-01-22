import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';

class TinyInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const TinyInfoChip({
    Key? key,
    required this.icon,
    required this.label,
  }) : super(key: key);

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
            style: TextStyle(
              fontSize: Sizes.verySmallText(context),
              color: Color(0xFF374151),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// ✅ shows: Minimum requirement + progress color
class RequirementChip extends StatelessWidget {
  final int minQ;
  final int selectedQ;

  const RequirementChip({
    Key? key,
    required this.minQ,
    required this.selectedQ,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ok = selectedQ >= minQ;
    final bg = ok ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED);
    final border = ok ? const Color(0xFF34D399) : const Color(0xFFF59E0B);
    final fg = ok ? const Color(0xFF065F46) : const Color(0xFF92400E);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border.withOpacity(0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ok ? Icons.verified_rounded : Icons.info_outline_rounded,
            size: 16,
            color: fg,
          ),
          const SizedBox(width: 6),
          Text(
            'Min $minQ Q • $selectedQ selected',
            style: TextStyle(
              fontSize: Sizes.verySmallText(context),
              fontWeight: FontWeight.w900,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorCardModern extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorCardModern({
    Key? key,
    required this.message,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'Failed to load',
                style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message.isEmpty ? 'Something went wrong' : message,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyModernState extends StatelessWidget {
  final String query;
  final String titleWhenEmpty;
  final String subtitleWhenEmpty;
  final VoidCallback onBack;
  final VoidCallback onClear;

  const EmptyModernState({
    Key? key,
    required this.query,
    required this.titleWhenEmpty,
    required this.subtitleWhenEmpty,
    required this.onBack,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const subtle = Color(0xFF6B7280);
    final q = query.trim();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 46, color: subtle),
            const SizedBox(height: 10),
            Text(
              q.isEmpty ? titleWhenEmpty : 'No results found',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              q.isEmpty
                  ? subtitleWhenEmpty
                  : 'We couldn’t find any results for “$q”.\nTry a different keyword or clear the search.',
              style: const TextStyle(
                fontSize: 13.0,
                height: 1.35,
                color: subtle,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                if (q.isNotEmpty)
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
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
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

class ChapterTopicSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isCompact;
  final VoidCallback onClear;
  final ValueChanged<String> onSubmitted;
  final String hintText;

  const ChapterTopicSearchBar({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.isCompact,
    required this.onClear,
    required this.onSubmitted,
    required this.hintText,
  }) : super(key: key);

  @override
  State<ChapterTopicSearchBar> createState() => _ChapterTopicSearchBarState();
}

class _ChapterTopicSearchBarState extends State<ChapterTopicSearchBar> {
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
    final gradientColors = [AppColor.indigo, AppColor.purple];
    final outerBorderRadius = BorderRadius.circular(14);
    final innerBorderRadius = BorderRadius.circular(12.5);

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
            const Icon(Icons.search_rounded, size: 20, color: Color(0xFF6B7280)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                textInputAction: TextInputAction.search,
                onSubmitted: widget.onSubmitted,
                style: TextStyle(
                  fontSize: widget.isCompact ? 13.5 : 14.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    fontSize: widget.isCompact ? 13.0 : 14.0,
                    color: const Color(0xFF6B7280),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
            if (widget.controller.text.isNotEmpty)
              IconButton(
                onPressed: widget.onClear,
                icon: const Icon(Icons.close_rounded,
                    size: 18, color: Color(0xFF6B7280)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                splashRadius: 18,
                tooltip: 'Clear',
              ),
          ],
        ),
      ),
    );
  }
}

/// ✅ Now bottom bar shows selected QUESTION count and disables feel when < min.
class BottomNextBar extends StatelessWidget {
  final int selectedQuestionCount;
  final int minRequired;
  final String buttonText;
  final VoidCallback onPressed;
  final List<Color> gradientColors;

  const BottomNextBar({
    Key? key,
    required this.selectedQuestionCount,
    required this.minRequired,
    required this.buttonText,
    required this.onPressed,
    required this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final safeBottom = media.padding.bottom;

    final ok = selectedQuestionCount >= minRequired;

    return Container(
      padding: EdgeInsets.fromLTRB(14, 10, 14, 10 + safeBottom),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, -8),
          ),
        ],
        border: Border(
          top: BorderSide(color: Colors.black.withOpacity(0.06)),
        ),
      ),
      child: Row(
        children: [
    /*      Expanded(
            child: _SelectedCounterPill(
              selectedQ: selectedQuestionCount,
              minRequired: minRequired,
            ),
          ),
          const SizedBox(width: 10),*/
          Expanded(
            flex: 2,
            child: _GradientButton(
              text: buttonText,
              icon: Icons.arrow_forward_rounded,
              gradientColors: ok
                  ? gradientColors
                  : [
                gradientColors.first.withOpacity(0.55),
                gradientColors.last.withOpacity(0.55),
              ],
              onPressed: onPressed,
            ),
          ),
        ],
      ),
    );
  }
}

/*class _SelectedCounterPill extends StatelessWidget {
  final int selectedQ;
  final int minRequired;

  const _SelectedCounterPill({
    required this.selectedQ,
    required this.minRequired,
  });

  @override
  Widget build(BuildContext context) {
    final ok = selectedQ >= minRequired;

    final bg = ok ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED);
    final border = ok ? const Color(0xFF34D399) : const Color(0xFFF59E0B);
    final fg = ok ? const Color(0xFF065F46) : const Color(0xFF92400E);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: bg,
        border: Border.all(color: border.withOpacity(0.45)),
      ),
      child: Row(
        children: [
          Icon(ok ? Icons.verified_rounded : Icons.warning_amber_rounded,
              color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$selectedQ / $minRequired Q',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}*/

class _GradientButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onPressed;

  const _GradientButton({
    required this.text,
    required this.icon,
    required this.gradientColors,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.24),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------------------
/// Chapter + topics UI building
/// ---------------------------
class TopicRowData {
  final int id;
  final String title;
  final int count;
  final bool checked;
  final ValueChanged<bool?> onChanged;

  TopicRowData({
    required this.id,
    required this.title,
    required this.count,
    required this.checked,
    required this.onChanged,
  });
}

class ChapterTopicsCard extends StatefulWidget {
  final String chapterTitle;
  final int chapterCount;
  final int topicsCount;
  final int selectedTopicsCount;

  final bool chapterChecked;
  final bool chapterIndeterminate;
  final ValueChanged<bool> onToggleChapter;

  final bool isChapterSelected;
  final List<TopicRowData> topics;
  final bool isDark;

  const ChapterTopicsCard({
    Key? key,
    required this.chapterTitle,
    required this.chapterCount,
    required this.topicsCount,
    required this.selectedTopicsCount,
    required this.chapterChecked,
    required this.chapterIndeterminate,
    required this.onToggleChapter,
    required this.isChapterSelected,
    required this.topics,
    required this.isDark,
  }) : super(key: key);

  @override
  State<ChapterTopicsCard> createState() => _ChapterTopicsCardState();
}

class _ChapterTopicsCardState extends State<ChapterTopicsCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(18);
    final gradientColors = [AppColor.indigo, AppColor.purple];

    final subtitle =
        '${widget.chapterCount} Q • ${widget.topicsCount} topic${widget.topicsCount == 1 ? '' : 's'}'
        '${widget.selectedTopicsCount > 0 ? ' • ${widget.selectedTopicsCount} selected' : ''}';

    final selectedGlow = widget.isChapterSelected;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          colors: selectedGlow
              ? [
            gradientColors.first.withOpacity(0.98),
            gradientColors.last.withOpacity(0.98),
          ]
              : [
            gradientColors.first.withOpacity(0.88),
            gradientColors.last.withOpacity(0.88),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          if (selectedGlow)
            BoxShadow(
              color: AppColor.indigo.withOpacity(0.20),
              blurRadius: 24,
              offset: const Offset(0, 12),
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      padding: const EdgeInsets.all(1.3),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: widget.isDark ? const Color(0xFF121416) : Colors.white,
        ),
        child: Column(
          children: [
            InkWell(
              borderRadius: borderRadius,
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _TriStateCheckbox(
                      value: widget.chapterChecked,
                      indeterminate: widget.chapterIndeterminate,
                      onChanged: (v) => widget.onToggleChapter(v ?? false),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.chapterTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: Sizes.normalText(context),
                              color: widget.isDark ? Colors.white : Colors.black,
                              height: 1.10,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: Sizes.smallText(context),
                              fontWeight: FontWeight.w700,
                              color: widget.isDark
                                  ? Colors.white70
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 160),
                      turns: _expanded ? 0.5 : 0.0,
                      child: Icon(
                        Icons.expand_more_rounded,
                        color: widget.isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 170),
              crossFadeState: _expanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: Container(
                      height: 1,
                      color: Colors.black.withOpacity(0.06),
                    ),
                  ),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    itemCount: widget.topics.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final t = widget.topics[i];
                      return _TopicTile(
                        title: t.title,
                        count: t.count,
                        checked: t.checked,
                        onChanged: t.onChanged,
                        isDark: widget.isDark,
                      );
                    },
                  ),
                ],
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  final String title;
  final int count;
  final bool checked;
  final ValueChanged<bool?> onChanged;
  final bool isDark;

  const _TopicTile({
    required this.title,
    required this.count,
    required this.checked,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final border = Colors.black.withOpacity(0.06);

    final bg = checked
        ? AppColor.indigo.withOpacity(0.10)
        : (isDark ? const Color(0xFF0F1113) : const Color(0xFFF9FAFB));

    final bColor = checked ? AppColor.indigo.withOpacity(0.28) : border;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onChanged(!checked),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Checkbox(
                value: checked,
                onChanged: onChanged,
                activeColor: AppColor.indigo,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: Sizes.smallText(context),
                    color: isDark ? Colors.white : const Color(0xFF111827),
                    height: 1.12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _CountPill(count: count, active: checked),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  final int count;
  final bool active;
  const _CountPill({required this.count, required this.active});

  @override
  Widget build(BuildContext context) {
    final bg = active
        ? AppColor.indigo.withOpacity(0.16)
        : AppColor.indigo.withOpacity(0.08);
    final border = active
        ? AppColor.indigo.withOpacity(0.32)
        : AppColor.indigo.withOpacity(0.18);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: bg,
        border: Border.all(color: border),
      ),
      child: Text(
        '$count Q',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: AppColor.indigo,
          fontSize: Sizes.verySmallText(context),
        ),
      ),
    );
  }
}

class _TriStateCheckbox extends StatelessWidget {
  final bool value;
  final bool indeterminate;
  final ValueChanged<bool?> onChanged;

  const _TriStateCheckbox({
    required this.value,
    required this.indeterminate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final active = AppColor.indigo;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        if (indeterminate) {
          onChanged(true);
        } else {
          onChanged(!value);
        }
      },
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: (value || indeterminate) ? active : Colors.black26,
            width: 2,
          ),
          color: (value || indeterminate) ? active : Colors.transparent,
        ),
        child: Center(
          child: indeterminate
              ? Container(
            width: 10,
            height: 2.6,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          )
              : value
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(18),
    gradient: LinearGradient(
      colors: [Colors.white, Colors.white.withOpacity(0.95)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColor.indigo.withOpacity(0.08),
        blurRadius: 20,
        offset: const Offset(0, 12),
      ),
    ],
    border: Border.all(color: Colors.black.withOpacity(0.05)),
  );
}
