// lib/presentation/widgets/helpers/make_customize_question_helpers.dart
//
// ✅ Updated: hide pool question count, hide quota max/min in UI,
// ✅ hide ALL question counts inside Selected Content dialog and its list.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:medi_exam/data/models/free_exam_quota_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';

// --------------------- Selection Summary ---------------------

class SelectionSummaryCompactCard extends StatelessWidget {
  final bool isDark;

  // (kept for logic/compatibility — UI hides these numbers)
  final int totalPool;
  final int poolCap;
  final int planCap;

  final List<Map<String, dynamic>> selectedChapters;
  final List<Map<String, dynamic>> selectedTopics;
  final int topicsCount;
  final int minExamQ;
  final int freeMaxExamQ;
  final bool isPremiumUser;
  final VoidCallback onViewSelected;

  const SelectionSummaryCompactCard({
    Key? key,
    required this.isDark,
    required this.totalPool,
    required this.poolCap,
    required this.planCap,
    required this.selectedChapters,
    required this.selectedTopics,
    required this.topicsCount,
    required this.minExamQ,
    required this.freeMaxExamQ,
    required this.isPremiumUser,
    required this.onViewSelected,
  }) : super(key: key);

  String _pickStr(Map<String, dynamic> m, List<String> keys, String fallback) {
    for (final k in keys) {
      final v = m[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString().trim();
    }
    return fallback;
  }

  String _chapterKeyFromTopic(Map<String, dynamic> t) {
    final id = t['chapter_id'] ?? t['chapterId'] ?? t['chapterID'];
    final name = _pickStr(
      t,
      ['chapter_name', 'chapterName', 'chapter_title', 'chapterTitle'],
      '',
    );
    if (id != null) return 'id:$id';
    if (name.isNotEmpty) return 'name:$name';
    return 'unknown';
  }

  @override
  Widget build(BuildContext context) {
    // ✅ group selectedTopics by chapter (for accurate chapter count)
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final t in selectedTopics) {
      final key = _chapterKeyFromTopic(t);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(t);
    }

    // ✅ include fully selected chapters too
    final Map<String, Map<String, dynamic>> fullChaptersByKey = {};
    for (final c in selectedChapters) {
      final id = c['chapter_id'] ?? c['chapterId'] ?? c['chapterID'];
      final name = _pickStr(
        c,
        ['chapter_name', 'chapterName', 'chapter_title', 'chapterTitle'],
        '',
      );
      final key = (id != null) ? 'id:$id' : (name.isNotEmpty ? 'name:$name' : 'unknown_full');
      fullChaptersByKey[key] = c;
      grouped.putIfAbsent(key, () => []);
    }

    final chapterCount = grouped.keys.length;

    // ✅ No pool counts / no numeric limit in UI
    final planText = isPremiumUser ? 'Premium plan' : 'Free plan';

    return CustomBlobBackground(
      backgroundColor: AppColor.whiteColor,
      blobColor: AppColor.indigo,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Badge(icon: Icons.info_outline_rounded),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Selection Summary',
                    style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _divider(),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _InfoStat(
                  icon: Icons.layers_rounded,
                  title: 'Chapters:',
                  value: '$chapterCount',
                ),
                _InfoStat(
                  icon: Icons.local_library_rounded,
                  title: 'Topics:',
                  value: '$topicsCount',
                ),
                _InfoStat(
                  icon: Icons.workspace_premium_rounded,
                  title: 'Plan:',
                  value: planText,
                ),
                _ActionStat(
                  value: 'Selected Content',
                  onTap: onViewSelected,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------- Exam Quantity ---------------------

class ExamQuantityCard extends StatelessWidget {
  final bool isDark;

  final int pool; // internal
  final int mcqCount;
  final int sbaCount;
  final int total;

  final int minTotal;
  final int planMax;
  final int freeMax;
  final bool isPremiumUser;

  final VoidCallback onMcqMinus;
  final VoidCallback onMcqPlus;
  final VoidCallback onSbaMinus;
  final VoidCallback onSbaPlus;

  final ValueChanged<int> onPresetTap;

  const ExamQuantityCard({
    Key? key,
    required this.isDark,
    required this.pool,
    required this.mcqCount,
    required this.sbaCount,
    required this.total,
    required this.minTotal,
    required this.planMax,
    required this.freeMax,
    required this.isPremiumUser,
    required this.onMcqMinus,
    required this.onMcqPlus,
    required this.onSbaMinus,
    required this.onSbaPlus,
    required this.onPresetTap,
  }) : super(key: key);

  static const int _step = 5;

  int _floorToStep(int v) {
    if (v <= 0) return 0;
    return (v ~/ _step) * _step;
  }

  @override
  Widget build(BuildContext context) {
    final int fixedMcq = _floorToStep(mcqCount);
    final int fixedSba = _floorToStep(sbaCount);
    final int fixedTotal = fixedMcq + fixedSba;

    return CustomBlobBackground(
      backgroundColor: AppColor.whiteColor,
      blobColor: AppColor.purple,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _Badge(icon: Icons.tune_rounded),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Exam Quantity',
                    style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900),
                  ),
                ),
                _CountPill(text: '$fixedTotal Q'),
              ],
            ),
            const SizedBox(height: 10),
            _divider(),
            const SizedBox(height: 10),
            _TypeStepperTile(
              title: 'MCQ',
              subtitle: 'Multiple Choice Questions',
              icon: Icons.rule_rounded,
              value: fixedMcq,
              onMinus: onMcqMinus,
              onPlus: onMcqPlus,
              selected: fixedMcq > 0,
              stepLabel: '±$_step',
            ),
            const SizedBox(height: 10),
            _TypeStepperTile(
              title: 'SBA',
              subtitle: 'Single Best Answer',
              icon: Icons.task_alt_rounded,
              value: fixedSba,
              onMinus: onSbaMinus,
              onPlus: onSbaPlus,
              selected: fixedSba > 0,
              stepLabel: '±$_step',
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------- Status Hint ---------------------

class StatusHintCompactCard extends StatelessWidget {
  final bool isDark;
  final int pool; // internal only (UI hides it)
  final int minRequired;
  final int freeMax;
  final bool isPremiumUser;
  final int totalSelected;

  const StatusHintCompactCard({
    Key? key,
    required this.isDark,
    required this.pool,
    required this.minRequired,
    required this.freeMax,
    required this.isPremiumUser,
    required this.totalSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title;
    String message;
    IconData icon;
    Color tint;

    if (totalSelected > pool) {
      title = 'Exceeds available pool';
      message = 'Your selection is higher than what’s available. Try lowering it a bit.';
      icon = Icons.error_outline_rounded;
      tint = const Color(0xFFEF4444);
    } else if (!isPremiumUser && totalSelected > freeMax) {
      title = 'Premium Feature';
      message = 'Larger exams are available with Premium.';
      icon = Icons.workspace_premium_rounded;
      tint = const Color(0xFFF59E0B);
    } else if (totalSelected < minRequired) {
      title = 'Minimum required';
      message = 'Select at least $minRequired questions to create an exam.';
      icon = Icons.info_outline_rounded;
      tint = const Color(0xFFF59E0B);
    } else {
      title = 'Tip';
      message = 'Use the + / − buttons to adjust MCQ and SBA in steps of 5.';
      icon = Icons.lightbulb_outline_rounded;
      tint = AppColor.indigo;
    }

    return Container(
      decoration: _cardDecoration(bg: isDark ? const Color(0xFF121416) : Colors.white),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: tint.withOpacity(0.10),
              border: Border.all(color: tint.withOpacity(0.25)),
            ),
            child: Icon(icon, color: tint),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.22,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------- Bottom Bar ---------------------

class CreateExamBottomBarCompact extends StatelessWidget {
  final bool canCreate;
  final bool isLoading;
  final int totalSelected;
  final int minRequired;
  final VoidCallback onPressed;

  const CreateExamBottomBarCompact({
    Key? key,
    required this.canCreate,
    required this.totalSelected,
    required this.minRequired,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final safeBottom = media.padding.bottom;

    // ✅ only block taps while loading
    final disabled = isLoading;

    final gradient = (disabled || !canCreate)
        ? [
      AppColor.indigo.withOpacity(0.55),
      AppColor.purple.withOpacity(0.55),
    ]
        : const [AppColor.indigo, AppColor.purple];

    // ✅ keep "Let's create exam" visible when >= min (even if not creatable yet)
    final buttonText = isLoading
        ? "Creating..."
        : (totalSelected < minRequired
        ? "Select at least $minRequired"
        : "Let's create exam");

    return Container(
      padding: EdgeInsets.fromLTRB(14, 8, 14, 8 + safeBottom),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
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
      child: _PrimaryButton(
        text: buttonText,
        icon: Icons.play_arrow_rounded,
        gradientColors: gradient,
        isLoading: isLoading,
        onPressed: disabled ? null : onPressed, // ✅ clickable unless loading
      ),
    );
  }
}

// --------------------- Internal UI pieces ---------------------

class _TypeStepperTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final bool selected;
  final String stepLabel;

  const _TypeStepperTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onMinus,
    required this.onPlus,
    required this.selected,
    required this.stepLabel,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColor.indigo.withOpacity(0.06) : Colors.grey.shade50;
    final border = selected
        ? AppColor.indigo.withOpacity(0.25)
        : Colors.black.withOpacity(0.06);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: bg,
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColor.indigo.withOpacity(0.10),
              border: Border.all(color: AppColor.indigo.withOpacity(0.22)),
            ),
            child: Icon(icon, color: AppColor.indigo, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.white,
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                  ),
                  child: Text(
                    stepLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 11.5,
                      color: AppColor.indigo,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _StepperBtn(icon: Icons.remove_rounded, onTap: onMinus),
          const SizedBox(width: 8),
          _CountPill(text: '$value'),
          const SizedBox(width: 8),
          _StepperBtn(icon: Icons.add_rounded, onTap: onPlus),
        ],
      ),
    );
  }
}

class _StepperBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: Colors.black.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF111827)),
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  final String text;
  const _CountPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColor.indigo.withOpacity(0.10),
        border: Border.all(color: AppColor.indigo.withOpacity(0.22)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          color: AppColor.indigo,
        ),
      ),
    );
  }
}

class _InfoStat extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoStat({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: Sizes.smallText(context), color: AppColor.indigo),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: Sizes.smallText(context),
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: Sizes.smallText(context),
              fontWeight: FontWeight.w900,
              color: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionStat extends StatelessWidget {
  final String value;
  final VoidCallback onTap;

  const _ActionStat({
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: Sizes.smallText(context),
                fontWeight: FontWeight.w900,
                color: AppColor.indigo,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded,
                size: Sizes.smallText(context), color: AppColor.indigo),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _PrimaryButton({
    required this.text,
    required this.icon,
    required this.gradientColors,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;

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
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: disabled ? null : onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: isLoading
                    ? Row(
                  key: const ValueKey("loading"),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Creating...",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ],
                )
                    : Row(
                  key: const ValueKey("normal"),
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
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  const _Badge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(colors: [AppColor.indigo, AppColor.purple]),
        boxShadow: [
          BoxShadow(
            color: AppColor.indigo.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}

Widget _divider() {
  return Container(
    height: 1,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.16),
          Colors.transparent,
        ],
      ),
    ),
  );
}

BoxDecoration _cardDecoration({required Color bg}) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(18),
    color: bg,
    boxShadow: [
      BoxShadow(
        color: AppColor.indigo.withOpacity(0.08),
        blurRadius: 18,
        offset: const Offset(0, 12),
      ),
    ],
    border: Border.all(color: Colors.black.withOpacity(0.05)),
  );
}

/// -----------------------
/// Dialog: Selected content (✅ hides question counts + hides pool)
/// -----------------------
class SelectedContentDialog extends StatelessWidget {
  final bool isDark;

  final String courseTitle;
  final String specialtyName;
  final String subjectName;

  final List<Map<String, dynamic>> selectedChapters;
  final List<Map<String, dynamic>> selectedTopics;

  // kept for compatibility, NOT displayed
  final int totalPool;

  const SelectedContentDialog({
    Key? key,
    required this.isDark,
    required this.courseTitle,
    required this.specialtyName,
    required this.subjectName,
    required this.selectedChapters,
    required this.selectedTopics,
    required this.totalPool,
  }) : super(key: key);

  int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  String _pickStr(Map<String, dynamic> m, List<String> keys, String fallback) {
    for (final k in keys) {
      final v = m[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString().trim();
    }
    return fallback;
  }

  String _chapterKeyFromTopic(Map<String, dynamic> t) {
    final id = t['chapter_id'] ?? t['chapterId'] ?? t['chapterID'];
    final name = _pickStr(
      t,
      ['chapter_name', 'chapterName', 'chapter_title', 'chapterTitle'],
      '',
    );
    if (id != null) return 'id:$id';
    if (name.isNotEmpty) return 'name:$name';
    return 'unknown';
  }

  @override
  Widget build(BuildContext context) {
    // group selectedTopics by chapter
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final t in selectedTopics) {
      final key = _chapterKeyFromTopic(t);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(t);
    }

    // include full chapters
    final Map<String, Map<String, dynamic>> fullChaptersByKey = {};
    for (final c in selectedChapters) {
      final id = c['chapter_id'] ?? c['chapterId'] ?? c['chapterID'];
      final name = _pickStr(
        c,
        ['chapter_name', 'chapterName', 'chapter_title', 'chapterTitle'],
        '',
      );
      final key = (id != null) ? 'id:$id' : (name.isNotEmpty ? 'name:$name' : 'unknown_full');
      fullChaptersByKey[key] = c;
      grouped.putIfAbsent(key, () => []);
    }

    final chapterKeys = grouped.keys.toList();
    chapterKeys.sort((a, b) {
      String nameFor(String k) {
        if (fullChaptersByKey.containsKey(k)) {
          return _pickStr(fullChaptersByKey[k]!, ['chapter_name', 'chapterName', 'chapter_title', 'chapterTitle'], 'Chapter');
        }
        final topics = grouped[k]!;
        if (topics.isNotEmpty) {
          return _pickStr(topics.first, ['chapter_name', 'chapterName', 'chapter_title', 'chapterTitle'], 'Chapter');
        }
        return 'Chapter';
      }

      return nameFor(a).toLowerCase().compareTo(nameFor(b).toLowerCase());
    });

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: CustomBlobBackground(
        backgroundColor: AppColor.whiteColor,
        blobColor: AppColor.indigo,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _Badge(icon: Icons.checklist_rounded),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Selected Content',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    splashRadius: 18,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _divider(),
              const SizedBox(height: 10),

              // ✅ no pool / no question numbers
              _TinyLine(left: courseTitle, right: 'Chapters: ${chapterKeys.length}'),
              const SizedBox(height: 6),
              _TinyLine(
                left: 'Faculty: $specialtyName',
                right: 'Topics: ${selectedTopics.length}',
              ),
              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Chapters (${chapterKeys.length})',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
                ),
              ),
              const SizedBox(height: 8),

              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: chapterKeys.map((key) {
                      final topics = grouped[key]!;
                      final isFull = fullChaptersByKey.containsKey(key);

                      String chapterName;
                      if (isFull) {
                        final c = fullChaptersByKey[key]!;
                        chapterName = _pickStr(
                          c,
                          ['chapter_name', 'chapterName', 'chapter_title', 'chapterTitle'],
                          'Chapter',
                        );
                      } else if (topics.isNotEmpty) {
                        chapterName = _pickStr(
                          topics.first,
                          ['chapter_name', 'chapterName', 'chapter_title', 'chapterTitle'],
                          'Chapter',
                        );
                      } else {
                        chapterName = 'Chapter';
                      }

                      // ✅ pie can still use internal values, but we do not show counts anywhere
                      final slices = topics
                          .map((t) => _PieSlice(
                        label: _pickStr(
                          t,
                          ['topic_name', 'topicName', 'title', 'name'],
                          'Topic',
                        ),
                        value: math.max(1, _asInt(t['question_count'])), // internal only
                      ))
                          .toList();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black.withOpacity(0.06)),
                          color: Colors.grey.shade50,
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            leading: _MiniPieChart(
                              size: 36,
                              slices: slices.isEmpty ? const [_PieSlice(label: 'All', value: 1)] : slices,
                            ),
                            title: Text(
                              chapterName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13.8,
                              ),
                            ),
                            subtitle: Text(
                              isFull
                                  ? 'Full chapter selected'
                                  : 'Selected topics: ${topics.length}',
                              style: const TextStyle(
                                fontSize: 12.2,
                                height: 1.1,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            trailing: const Icon(Icons.keyboard_arrow_down_rounded),
                            children: [
                              if (topics.isEmpty)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    isFull ? 'All topics included.' : 'No topics found for this chapter.',
                                    style: const TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                )
                              else
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: topics.map((t) {
                                    final tn = _pickStr(
                                      t,
                                      ['topic_name', 'topicName', 'title', 'name'],
                                      'Topic',
                                    );
                                    return _Chip(label: tn); // ✅ no suffix / no counts
                                  }).toList(),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check_rounded, color: Colors.white),
                  label: const Text('Done'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

class _TinyLine extends StatelessWidget {
  final String left;
  final String right;

  const _TinyLine({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              color: Color(0xFF374151),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          right,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 12.5,
            color: AppColor.indigo,
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColor.indigo.withOpacity(0.08),
        border: Border.all(color: AppColor.indigo.withOpacity(0.18)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: Sizes.verySmallText(context),
          color: const Color(0xFF111827),
        ),
      ),
    );
  }
}

/// -----------------------
/// Mini pie chart (no external packages)
/// -----------------------
class _PieSlice {
  final String label;
  final int value;
  const _PieSlice({required this.label, required this.value});
}

class _MiniPieChart extends StatelessWidget {
  final double size;
  final List<_PieSlice> slices;

  const _MiniPieChart({
    required this.size,
    required this.slices,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PiePainter(slices),
    );
  }
}

class _PiePainter extends CustomPainter {
  final List<_PieSlice> slices;
  _PiePainter(this.slices);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = math.min(size.width, size.height) / 2;

    final total = slices.fold<int>(0, (p, e) => p + e.value);
    if (total <= 0) {
      final p = Paint()
        ..style = PaintingStyle.fill
        ..color = AppColor.indigo.withOpacity(0.25);
      canvas.drawCircle(center, radius, p);
      return;
    }

    final palette = <Color>[
      AppColor.indigo.withOpacity(0.85),
      const Color(0xFFF59E0B).withOpacity(0.85),
      const Color(0xFF06B6D4).withOpacity(0.85),
      const Color(0xFF10B981).withOpacity(0.85),
      AppColor.purple.withOpacity(0.85),
      const Color(0xFFEF4444).withOpacity(0.85),
      Colors.blueGrey.withOpacity(0.85),
    ];

    double start = -math.pi / 2;
    for (int i = 0; i < slices.length; i++) {
      final s = slices[i];
      final sweep = (s.value / total) * (math.pi * 2);

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = palette[i % palette.length];

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        true,
        paint,
      );

      start += sweep;
    }

    final holePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    canvas.drawCircle(center, radius * 0.55, holePaint);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.black.withOpacity(0.06);
    canvas.drawCircle(center, radius * 0.98, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) {
    return oldDelegate.slices != slices;
  }
}

/// ✅ Compact quota banner (FREE user only) — shows ONLY remaining count
class QuotaStatusBanner extends StatelessWidget {
  final bool isDark;
  final bool loading;
  final String? error;
  final FreeExamQuotaModel? quota;

  // kept for compatibility; UI does not show min/max counts
  final int minRequired;
  final int todayMax;

  const QuotaStatusBanner({
    required this.isDark,
    required this.loading,
    required this.error,
    required this.quota,
    required this.minRequired,
    required this.todayMax,
  });

  String _formatDate(String? iso) {
    if (iso == null || iso.trim().isEmpty) return '';
    final dt = DateTime.tryParse(iso.trim());
    if (dt == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final d = dt.day.toString().padLeft(2, '0');
    final m = months[dt.month - 1];
    final y = dt.year.toString();
    return '$d $m $y';
  }

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.auto_awesome_rounded;
    Color tint = AppColor.indigo;

    String title = 'Free Exam Quota';
    String subtitle = 'Checking quota...';

    if (loading) {
      icon = Icons.hourglass_bottom_rounded;
      tint = AppColor.indigo;
      subtitle = 'Checking today\'s quota...';
    } else if (error != null) {
      icon = Icons.warning_amber_rounded;
      tint = const Color(0xFFF59E0B);
      subtitle = error!;
    } else {
      final dateText = _formatDate(quota?.date);
      final remaining = quota?.remainingQuestions ?? 0;
      final can = quota?.canCreateExam == true;

      if (!can) {
        icon = Icons.lock_clock_rounded;
        tint = const Color(0xFFEF4444);
        subtitle = 'Today’s free exam is already used.';
      } else if (remaining < minRequired) {
        icon = Icons.error_outline_rounded;
        tint = const Color(0xFFF59E0B);
        subtitle = 'Remaining today: $remaining • Not enough to create an exam.';
      } else {
        icon = Icons.verified_rounded;
        tint = AppColor.indigo;
        subtitle = 'Remaining today: $remaining${dateText.isEmpty ? '' : ' • $dateText'}';
      }
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? const Color(0xFF121416) : Colors.white,
        border: Border.all(color: tint.withOpacity(0.20)),
        boxShadow: [
          BoxShadow(
            color: tint.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 12),
          )
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: Sizes.smallIcon(context) + 12,
            height: Sizes.smallIcon(context) + 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                colors: [
                  tint.withOpacity(0.95),
                  AppColor.purple.withOpacity(0.95),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: tint.withOpacity(0.20),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Icon(icon, color: Colors.white, size: Sizes.smallIcon(context)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: Sizes.smallText(context),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: Sizes.verySmallText(context),
                    color: Colors.black.withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}