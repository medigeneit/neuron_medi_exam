import 'package:flutter/material.dart';
import 'package:medi_exam/data/models/easy_finder_questions_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';

import 'easy_finder_mcq_review_tile.dart';
import 'easy_finder_sba_review_tile.dart';

class EasyFinderTopicGroupWidget extends StatelessWidget {
  final String topicName;
  final List<EasyFinderQuestionItem> questions;

  final Map<int, String> indexLabelById;
  final bool showAllAnswers;

  const EasyFinderTopicGroupWidget({
    super.key,
    required this.topicName,
    required this.questions,
    required this.indexLabelById,
    required this.showAllAnswers,
  });

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Topic header
          Row(
            children: [
              Icon(Icons.local_offer_rounded,
                  size: 16, color: AppColor.purple.withOpacity(0.85)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  topicName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: Sizes.verySmallText(context) + 1,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey.shade900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColor.purple.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColor.purple.withOpacity(0.14)),
                ),
                child: Text(
                  '${questions.length}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColor.purple.withOpacity(0.95),
                    height: 1,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ✅ Questions
          for (int i = 0; i < questions.length; i++) ...[
            _buildQuestionTile(context, questions[i], fallbackIndex: i + 1),
            if (i != questions.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionTile(
      BuildContext context,
      EasyFinderQuestionItem q, {
        required int fallbackIndex,
      }) {
    final id = q.safeId;
    final idxLabel = (id != 0 && indexLabelById.containsKey(id))
        ? indexLabelById[id]!
        : '#$fallbackIndex';

    if (q.isMCQ) {
      return EasyFinderMCQReviewTile(
        key: ValueKey('easy_mcq_${q.safeId}_$fallbackIndex'),
        indexLabel: idxLabel,
        titleHtml: q.safeTitle.isEmpty ? '—' : q.safeTitle,
        options: q.safeOptions,
        answerScript: q.correctAns,
        questionId: q.id,
        blobColor: AppColor.purple,
        showAllAnswers: showAllAnswers,
      );
    }

    return EasyFinderSBAReviewTile(
      key: ValueKey('easy_sba_${q.safeId}_$fallbackIndex'),
      indexLabel: idxLabel,
      titleHtml: q.safeTitle.isEmpty ? '—' : q.safeTitle,
      options: q.safeOptions,
      answerScript: q.correctAns,
      questionId: q.id,
      blobColor: AppColor.indigo,
      showAllAnswers: showAllAnswers,
    );
  }
}