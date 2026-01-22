// lib/presentation/widgets/mcq_question_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:medi_exam/data/models/exam_question_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';
import 'package:medi_exam/presentation/widgets/helpers/payment_screen_helpers.dart';
import 'package:medi_exam/presentation/widgets/labeled_radio.dart';

class MCQQuestionTile extends StatelessWidget {
  final String indexLabel;
  final int questionId;
  final String examQuestionId;
  final String titleHtml;
  final List<QuestionOption> options; // N statements
  final List<bool?> states; // length N: true/false/null
  final List<bool> locks; // length N: true = that statement locked
  final List<bool> busy; // length N: true = submitting that statement
  final bool enabled;
  final void Function(int index, bool value) onSelect;

  const MCQQuestionTile({
    super.key,
    required this.indexLabel,
    required this.questionId,
    required this.examQuestionId,
    required this.titleHtml,
    required this.options,
    required this.states,
    required this.locks,
    required this.busy,
    required this.enabled,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return CustomBlobBackground(
      backgroundColor: Colors.white,
      blobColor: AppColor.purple,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      "table": Style(
                        width: Width(100, Unit.percent),
                      ),
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...List.generate(
              options.length,
                  (i) => _statementRow(context, i, options[i]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statementRow(BuildContext context, int i, QuestionOption opt) {
    final bool? state = states[i]; // true / false / null
    final bool locked = locks[i] == true;
    final bool isBusy = (busy.length > i) ? busy[i] : false;
    final bool rowEnabled = enabled && !locked && !isBusy;
    const double radioSize = 28;

    final String serial =
    opt.serial != null ? '${opt.serial!.toLowerCase()})' : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
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
                    // Option serial (a), b), c))
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

                    // Statement text
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  if (isBusy)
                    SizedBox(
                      width: Sizes.veryExtraSmallIcon(context),
                      height: Sizes.veryExtraSmallIcon(context),
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueGrey,),
                    ),

                  const SizedBox(width: 6),

                  LabeledRadio(
                    label: 'T',
                    selected: state == true,
                    disabled: !rowEnabled,
                    onTap: () => onSelect(i, true),
                    size: radioSize,
                    selectedColor: AppColor.primaryColor,
                  ),
                  const SizedBox(width: 10),
                  LabeledRadio(
                    label: 'F',
                    selected: state == false,
                    disabled: !rowEnabled,
                    onTap: () => onSelect(i, false),
                    size: radioSize,
                    selectedColor: AppColor.primaryColor,
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
