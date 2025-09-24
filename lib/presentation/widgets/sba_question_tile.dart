// lib/presentation/widgets/sba_question_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:medi_exam/data/models/exam_question_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';
import 'package:medi_exam/presentation/widgets/helpers/payment_screen_helpers.dart';
import 'package:medi_exam/presentation/widgets/labeled_radio.dart';

class SBAQuestionTile extends StatelessWidget {
  final String indexLabel;
  final int questionId;
  final String examQuestionId;
  final String titleHtml;
  final List<QuestionOption> options;
  final String? selectedLetter; // 'A'..'E'
  final bool enabled;
  final ValueChanged<String> onChanged;

  const SBAQuestionTile({
    super.key,
    required this.indexLabel,
    required this.questionId,
    required this.examQuestionId,
    required this.titleHtml,
    required this.options,
    required this.selectedLetter,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomBlobBackground(
      backgroundColor: Colors.white,
      blobColor: AppColor.indigo,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
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

                // ⬇️ Constrain and allow wrapping
                Expanded(
                  child: Html(
                    data: titleHtml,
                    style: {
                      // compact body
                      "body": Style(
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                        lineHeight: const LineHeight(1.35),
                      ),
                      // make images/tables fit the width
                      "img": Style(width: Width(100, Unit.percent)),
                      "table": Style(width: Width(100, Unit.percent),),
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._buildOptions(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOptions(BuildContext context) {
    final list = <Widget>[];
    for (final opt in options) {
      final letter = (opt.serial ?? '').toUpperCase();
      final text = opt.title ?? '';
      final bool selected =
          selectedLetter != null && selectedLetter!.toUpperCase() == letter;
      const double radioSize = 28;

      list.add(
        GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Html(
                      data: text,
                      style: {
                        "body": Style(
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                        ),
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: LabeledRadio(
                    label: letter,
                    selected: selected,
                    disabled: !enabled,
                    onTap: () => onChanged(letter),
                    size: radioSize,
                    selectedColor: AppColor.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      list.add(const SizedBox(height: 8));
    }
    if (list.isNotEmpty) list.removeLast();
    return list;
  }
}


