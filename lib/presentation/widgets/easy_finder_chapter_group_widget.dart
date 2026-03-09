import 'package:flutter/material.dart';
import 'package:medi_exam/data/models/easy_finder_questions_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';

import 'easy_finder_topic_group_widget.dart';

class EasyFinderChapterGroupWidget extends StatelessWidget {
  final String chapterName;

  /// topic -> questions
  final Map<String, List<EasyFinderQuestionItem>> topics;

  final Map<int, String> indexLabelById;
  final bool showAllAnswers;

  const EasyFinderChapterGroupWidget({
    super.key,
    required this.chapterName,
    required this.topics,
    required this.indexLabelById,
    required this.showAllAnswers,
  });

  int get _count {
    int total = 0;
    for (final t in topics.values) {
      total += t.length;
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
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          collapsedIconColor: isDark ? Colors.white70 : Colors.grey.shade700,
          iconColor: isDark ? Colors.white70 : Colors.grey.shade700,
          title: Row(
            children: [
              Icon(Icons.layers_rounded,
                  size: 18, color: AppColor.indigo.withOpacity(0.85)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  chapterName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: Sizes.verySmallText(context) + 1,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.grey.shade900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _MiniCount(text: '$_count'),
            ],
          ),
          children: [
            for (final topicName in topics.keys)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: EasyFinderTopicGroupWidget(
                  topicName: topicName,
                  questions: topics[topicName] ?? const [],
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

class _MiniCount extends StatelessWidget {
  final String text;
  const _MiniCount({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColor.indigo.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColor.indigo.withOpacity(0.14)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: AppColor.indigo.withOpacity(0.95),
          height: 1,
        ),
      ),
    );
  }
}