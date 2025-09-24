import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:medi_exam/data/models/exam_answers_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';
import 'package:medi_exam/presentation/widgets/labeled_radio.dart';

/// Read-only MCQ review tile that shows both:
/// - Doctor's T/F (colored green if matches, red if wrong)
/// - Correct T/F (blue)
/// Now: statement text and radios are in the SAME ROW,
/// and there is a vertical divider between doctor vs correct radios.
class MCQAnswerReviewTile extends StatelessWidget {
  final String indexLabel;
  final String titleHtml;
  final List<AnswerOption> options; // 5 statements (A..E with text)
  final List<bool?>? doctorStates;   // length 5: true/false/null
  final List<bool?>? correctStates;  // length 5: true/false/null

  const MCQAnswerReviewTile({
    super.key,
    required this.indexLabel,
    required this.titleHtml,
    required this.options,
    required this.doctorStates,
    required this.correctStates,
  });

  @override
  Widget build(BuildContext context) {
    final ds = doctorStates ?? const [null, null, null, null, null];
    final cs = correctStates ?? const [null, null, null, null, null];

    return CustomBlobBackground(
      backgroundColor: Colors.white,
      blobColor: AppColor.purple,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
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
            const SizedBox(height: 10),

            // Statements rows (each in single row with radios)
            ...List.generate(
              options.length,
                  (i) => _statementRow(context, i, options[i], ds, cs),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statementRow(
      BuildContext context,
      int i,
      AnswerOption opt,
      List<bool?> ds,
      List<bool?> cs,
      ) {
    final bool? doc = i < ds.length ? ds[i] : null;
    final bool? cor = i < cs.length ? cs[i] : null;

    // Doctor correctness (null -> no attempt)
    final bool? docIsCorrect =
    (doc == null || cor == null) ? null : (doc == cor);

    // Selected colors per spec
    final Color correctColor = AppColor.indigo; // blue-ish (brand)
    final Color docColor = (docIsCorrect == null)
        ? Colors.grey // unanswered -> neutral
        : (docIsCorrect ? Colors.green : Colors.red);

    const double radioSize = 24;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Statement text (expand to take free space)
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

              // Doctor radios: T / F
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LabeledRadio(
                    label: 'T',
                    selected: doc == true,
                    disabled: true,
                    selectedColor: docColor,
                    size: radioSize,
                  ),
                  const SizedBox(width: 8),
                  LabeledRadio(
                    label: 'F',
                    selected: doc == false,
                    disabled: true,
                    selectedColor: docColor,
                    size: radioSize,
                  ),
                ],
              ),

              // Vertical divider
              const SizedBox(width: 10),
              Container(
                width: 1,
                height: radioSize + 6,
                color: Colors.black12,
              ),
              const SizedBox(width: 10),

              // Correct radios: T / F
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LabeledRadio(
                    label: 'T',
                    selected: cor == true,
                    disabled: true,
                    selectedColor: correctColor,
                    size: radioSize,
                  ),
                  const SizedBox(width: 8),
                  LabeledRadio(
                    label: 'F',
                    selected: cor == false,
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
  }
}
