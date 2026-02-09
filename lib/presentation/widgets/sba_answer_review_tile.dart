// lib/presentation/widgets/sba_answer_review_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:medi_exam/data/models/exam_answers_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';
import 'package:medi_exam/presentation/widgets/labeled_radio.dart';
import 'package:medi_exam/presentation/widgets/question_action_row.dart';

class SBAAnswerReviewTile extends StatelessWidget {
  final String indexLabel;
  final String titleHtml;
  final List<AnswerOption> options;
  final int? doctorIndex;
  final int? correctIndex;

  final int? questionId;

  const SBAAnswerReviewTile({
    super.key,
    required this.indexLabel,
    required this.titleHtml,
    required this.options,
    required this.doctorIndex,
    required this.correctIndex,
    required this.questionId,
  });

  @override
  Widget build(BuildContext context) {
    final int len = options.length;

    final bool inRangeDoc =
        doctorIndex != null && doctorIndex! >= 0 && doctorIndex! < len;
    final bool inRangeCor =
        correctIndex != null && correctIndex! >= 0 && correctIndex! < len;

    final bool? docIsCorrect =
    (inRangeDoc && inRangeCor) ? (doctorIndex == correctIndex) : null;

    return CustomBlobBackground(
      backgroundColor: Colors.white,
      blobColor: AppColor.indigo,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColor.secondaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.purple.withOpacity(0.30),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Text(
                    indexLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: Sizes.verySmallText(context),
                      color: AppColor.whiteColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Html(
                    data: titleHtml,
                    style: {
                      "body": Style(
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                        lineHeight: const LineHeight(1.35),
                      ),
                      "img": Style(width: Width(100, Unit.percent)),
                      "table": Style(width: Width(100, Unit.percent)),
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ✅ Column headers (You / Correct)
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _colHeader(context, "You"),
                  const SizedBox(width: 10 + 1 + 10),
                  _colHeader(context, "Answer"),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Options
            ...List.generate(len, (i) {
              final opt = options[i];
              final String letter = (opt.serial ?? '').toUpperCase();
              final String serial =
              opt.serial != null ? '${opt.serial!.toLowerCase()})' : '';

              final bool youSelected = inRangeDoc && (doctorIndex == i);
              final bool correctSelected = inRangeCor && (correctIndex == i);

              final Color correctColor = AppColor.indigo;
              final Color youColor = (docIsCorrect == null)
                  ? Colors.grey
                  : (docIsCorrect ? Colors.green : Colors.red);

              const double radioSize = 22;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2, right: 6),
                                child: Text(
                                  serial,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.blackColor,
                                    fontSize: Sizes.smallText(context),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Html(
                                  data: opt.title ?? '',
                                  style: {
                                    "body": Style(
                                      margin: Margins.zero,
                                      padding: HtmlPaddings.zero,
                                    ),
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        // YOU
                        SizedBox(
                          width: 42,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: LabeledRadio(
                              label: letter,
                              selected: youSelected,
                              disabled: true,
                              selectedColor: youSelected ? youColor : Colors.grey,
                              size: radioSize,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),
                        Container(
                          width: 1,
                          height: radioSize + 6,
                          color: Colors.black12,
                        ),


                        // CORRECT
                        SizedBox(
                          width: 42,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: LabeledRadio(
                              label: letter,
                              selected: correctSelected,
                              disabled: true,
                              selectedColor: correctColor,
                              size: radioSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 2),

            QuestionActionRow(questionId: questionId),
          ],
        ),
      ),
    );
  }

  Widget _colHeader(BuildContext context, String text) {
    return SizedBox(
      width: 42,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: Sizes.verySmallText(context) - 1,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
