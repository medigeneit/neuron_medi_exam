// lib/presentation/widgets/mcq_answer_review_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:medi_exam/data/models/exam_answers_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';
import 'package:medi_exam/presentation/widgets/labeled_radio.dart';
import 'package:medi_exam/presentation/widgets/question_action_row.dart';

/// Read-only MCQ review tile that shows both:
/// - Your (doctor's) T/F
/// - Correct T/F
class MCQAnswerReviewTile extends StatelessWidget {
  final String indexLabel;
  final String titleHtml;
  final List<AnswerOption> options;
  final List<bool?>? doctorStates;
  final List<bool?>? correctStates;

  /// needed for explanation API
  final int? questionId;

  const MCQAnswerReviewTile({
    super.key,
    required this.indexLabel,
    required this.titleHtml,
    required this.options,
    required this.doctorStates,
    required this.correctStates,
    required this.questionId,
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

            const SizedBox(height: 8),

            // ✅ Column headers (You / Correct)
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _colHeader(context, "You"),
                  const SizedBox(width: 10 + 1 + 10), // same spacing as divider block
                  _colHeader(context, "Answer"),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Statement rows
            ...List.generate(
              len,
                  (i) => _statementRow(context, i, options[i], ds[i], cs[i]),
            ),

            const SizedBox(height: 2),

            QuestionActionRow(questionId: questionId),
          ],
        ),
      ),
    );
  }

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

  Widget _colHeader(BuildContext context, String text) {
    return const SizedBox(
      width: 68, // matches the T/F group width
      child: Text(
        "",
        textAlign: TextAlign.center,
      ),
    ).copyWithText(
      context: context,
      text: text,
    );
  }

  Widget _statementRow(
      BuildContext context,
      int i,
      AnswerOption opt,
      bool? doc,
      bool? cor,
      ) {
    final bool? docIsCorrect =
    (doc == null || cor == null) ? null : (doc == cor);

    final Color correctColor = AppColor.indigo;
    final Color youColor = (docIsCorrect == null)
        ? Colors.grey
        : (docIsCorrect ? Colors.green : Colors.red);

    final String serial = opt.serial != null ? '${opt.serial!.toLowerCase()})' : '';

    const double radioSize = 22;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
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
                width: 68,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
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
              ),

              const SizedBox(width: 12),
              Container(width: 1, height: radioSize + 6, color: Colors.black12),


              // CORRECT
              SizedBox(
                width: 68,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small helper to keep code clean without adding new imports/extensions files.
extension _HeaderTextCopy on SizedBox {
  SizedBox copyWithText({
    required BuildContext context,
    required String text,
  }) {
    return SizedBox(
      width: width,
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
