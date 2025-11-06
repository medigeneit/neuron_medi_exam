import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:medi_exam/data/models/exam_answers_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';
import 'package:medi_exam/presentation/widgets/labeled_radio.dart';

/// Read-only MCQ review tile that shows both:
/// - Your (doctor's) T/F (green if matches, red if wrong; grey if unanswered)
/// - Correct T/F (brand indigo)
/// Works with ANY number of statements (matches options.length).
class MCQAnswerReviewTile extends StatelessWidget {
  final String indexLabel;
  final String titleHtml;
  final List<AnswerOption> options; // N statements (A..)
  final List<bool?>? doctorStates;   // length N: true/false/null
  final List<bool?>? correctStates;  // length N: true/false/null

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
    final int len = options.length;
    final List<bool?> ds = _normalizeStates(doctorStates, len);
    final List<bool?> cs = _normalizeStates(correctStates, len);

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
            const SizedBox(height: 10),

            // Statement rows
            ...List.generate(
              len,
                  (i) => _statementRow(context, i, options[i], ds[i], cs[i]),
            ),
          ],
        ),
      ),
    );
  }

  // Normalize incoming states to exactly `len` (pad/truncate to match options).
  List<bool?> _normalizeStates(List<bool?>? src, int len) {
    if (len <= 0) return const <bool?>[];
    final out = List<bool?>.filled(len, null);
    if (src == null || src.isEmpty) return out;
    final copy = src.length < len ? src.length : len;
    for (var i = 0; i < copy; i++) {
      out[i] = src[i];
    }
    return out;
  }

  Widget _statementRow(
      BuildContext context,
      int i,
      AnswerOption opt,
      bool? doc,
      bool? cor,
      ) {
    // null -> unanswered or unknown
    final bool? docIsCorrect = (doc == null || cor == null) ? null : (doc == cor);

    final Color correctColor = AppColor.indigo; // correct key color (blue-ish)
    final Color youColor = (docIsCorrect == null)
        ? Colors.grey // unanswered -> neutral grey
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
              // Statement text
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

              // Your (doctor) radios
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LabeledRadio(
                    label: 'T',
                    selected: doc == true,
                    disabled: true,
                    selectedColor: youColor,
                    size: radioSize,
                  ),
                  const SizedBox(width: 8),
                  LabeledRadio(
                    label: 'F',
                    selected: doc == false,
                    disabled: true,
                    selectedColor: youColor,
                    size: radioSize,
                  ),
                ],
              ),

              // Divider
              const SizedBox(width: 10),
              Container(width: 1, height: radioSize + 6, color: Colors.black12),
              const SizedBox(width: 10),

              // Correct radios
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
