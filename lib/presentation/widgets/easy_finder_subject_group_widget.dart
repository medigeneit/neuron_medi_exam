import 'package:flutter/material.dart';
import 'package:medi_exam/data/models/easy_finder_questions_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';

import 'easy_finder_chapter_group_widget.dart';

class EasyFinderSubjectGroupWidget extends StatelessWidget {
  final String subjectName;

  /// chapter -> topic -> questions
  final Map<String, Map<String, List<EasyFinderQuestionItem>>> chapters;

  final Map<int, String> indexLabelById;
  final bool showAllAnswers;

  const EasyFinderSubjectGroupWidget({
    super.key,
    required this.subjectName,
    required this.chapters,
    required this.indexLabelById,
    required this.showAllAnswers,
  });

  int get _count {
    int total = 0;
    for (final c in chapters.values) {
      for (final t in c.values) {
        total += t.length;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          collapsedIconColor: isDark ? Colors.white70 : Colors.grey.shade700,
          iconColor: isDark ? Colors.white70 : Colors.grey.shade700,
          title: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColor.primaryColor, AppColor.purple, AppColor.indigo],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primaryColor.withOpacity(0.20),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(Icons.menu_book_rounded,
                    color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  subjectName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: Sizes.smallText(context),
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.grey.shade900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _CountPill(text: '$_count'),
            ],
          ),
          children: [
            for (final chapterName in chapters.keys)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: EasyFinderChapterGroupWidget(
                  chapterName: chapterName,
                  topics: chapters[chapterName] ?? {},
                  indexLabelById: indexLabelById,
                  showAllAnswers: showAllAnswers,
                ),
              ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColor.primaryColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColor.primaryColor.withOpacity(0.16)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: AppColor.primaryColor,
          height: 1,
        ),
      ),
    );
  }
}