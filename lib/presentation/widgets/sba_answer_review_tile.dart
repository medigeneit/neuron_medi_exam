import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:medi_exam/data/models/exam_answers_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';
import 'package:medi_exam/presentation/widgets/labeled_radio.dart';

/// Read-only SBA review tile that shows:
/// - Doctor's selected option (green if correct, red if wrong)
/// - Correct option (blue)
class SBAAnswerReviewTile extends StatelessWidget {
  final String indexLabel;
  final String titleHtml;
  final List<AnswerOption> options; // A..E
  final int? doctorIndex;  // 0..4
  final int? correctIndex; // 0..4

  const SBAAnswerReviewTile({
    super.key,
    required this.indexLabel,
    required this.titleHtml,
    required this.options,
    required this.doctorIndex,
    required this.correctIndex,
  });

  @override
  Widget build(BuildContext context) {
    final bool? docIsCorrect = (doctorIndex == null || correctIndex == null)
        ? null
        : (doctorIndex == correctIndex);

    return CustomBlobBackground(
      backgroundColor: Colors.white,
      blobColor: AppColor.indigo,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with index and question title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

            // Options
            ...List.generate(options.length, (i) {
              final opt = options[i];
              final String letter = (opt.serial ?? '').toUpperCase();

              // Colors
              final Color correctColor = AppColor.indigo; // blue
              final Color youColor = (docIsCorrect == null)
                  ? Colors.grey
                  : (docIsCorrect ? Colors.green : Colors.red);

              final bool youSelected = (doctorIndex == i);
              final bool correctSelected = (correctIndex == i);

              const double radioSize = 24;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Option text
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12, right: 8),
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
                        ),
                        // Radios: You + Correct
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // YOU (A..E)
                            LabeledRadio(
                              label: letter,
                              selected: youSelected,
                              disabled: true,
                              selectedColor: youSelected ? youColor : Colors.grey,
                              size: radioSize,
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 1,
                              height: radioSize + 6,
                              color: Colors.black12,
                            ),
                            const SizedBox(width: 10),
                            // CORRECT (A..E)
                            LabeledRadio(
                              label: letter,
                              selected: correctSelected,
                              disabled: true,
                              selectedColor: correctColor,
                              size: radioSize,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
