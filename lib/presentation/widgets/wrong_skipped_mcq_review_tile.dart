import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:medi_exam/data/models/wrong_skipped_qus_details_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';
import 'package:medi_exam/presentation/widgets/labeled_radio.dart';
import 'package:medi_exam/presentation/widgets/question_action_row.dart';

/// Wrong/Skipped MCQ (stems) review tile
/// Redesigned to match MCQAnswerReviewTile & MCQQuestionTile design:
/// - Left: serial + statement HTML
/// - Right: You (T/F) + (optional) Correct (T/F)
/// - Correct section is totally removed when hidden (no lock icon)
class WrongSkippedMCQReviewTile extends StatefulWidget {
  final String indexLabel;
  final String titleHtml;
  final List<WrongSkippedStem> stems;
  final int? questionId;
  final Color blobColor;

  /// Global show/hide sync from overview card
  final bool showAllCorrect;

  const WrongSkippedMCQReviewTile({
    super.key,
    required this.indexLabel,
    required this.titleHtml,
    required this.stems,
    required this.questionId,
    this.blobColor = AppColor.purple,
    this.showAllCorrect = false,
  });

  @override
  State<WrongSkippedMCQReviewTile> createState() =>
      _WrongSkippedMCQReviewTileState();
}

class _WrongSkippedMCQReviewTileState extends State<WrongSkippedMCQReviewTile> {
  bool _showCorrect = false;

  @override
  void initState() {
    super.initState();
    _showCorrect = widget.showAllCorrect;
  }

  @override
  void didUpdateWidget(covariant WrongSkippedMCQReviewTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showAllCorrect != widget.showAllCorrect) {
      setState(() => _showCorrect = widget.showAllCorrect);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlobBackground(
      backgroundColor: Colors.white,
      blobColor: widget.blobColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),

            const SizedBox(height: 10),

            // Column headers aligned to the right (same vibe as your previous tiles)
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _colHeader(context, "You"),
                  if (_showCorrect) ...[
                    const SizedBox(width: 18),
                    _colHeader(context, "Answer"),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Statement rows
            ...List.generate(
              widget.stems.length,
                  (i) => _statementRow(context, i, widget.stems[i]),
            ),

            const SizedBox(height: 2),

            QuestionActionRow(questionId: widget.questionId),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Index circle (similar to your other tiles)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColor.warningGradient,
            boxShadow: [
              BoxShadow(
                color: widget.blobColor.withOpacity(0.30),
                blurRadius: 16,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Text(
            widget.indexLabel,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: Sizes.verySmallText(context),
              color: AppColor.whiteColor,
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Question title
        Expanded(
          child: Html(
            data: widget.titleHtml,
            style: {
              "body": Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                lineHeight: const LineHeight(1.35),
              ),
              "img": Style(width: Width(100, Unit.percent)),
              "table": Style(width: Width(100, Unit.percent)),
              "p": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
            },
          ),
        ),

        const SizedBox(width: 6),

        // Eye toggle (local)
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => setState(() => _showCorrect = !_showCorrect),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _showCorrect
                    ? AppColor.primaryColor.withOpacity(0.10)
                    : Colors.grey.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _showCorrect
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 20,
                color: _showCorrect
                    ? AppColor.primaryColor
                    : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _colHeader(BuildContext context, String text) {
    return SizedBox(
      width: 66, // enough for T/F radios (2x)
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

  Widget _statementRow(BuildContext context, int index, WrongSkippedStem s) {
    final bool? doc = _tfToBool(s.givenAnswer);
    final bool? cor = _tfToBool(s.correctAnswer);

    final bool? docIsCorrect =
    (doc == null || cor == null) ? null : (doc == cor);

    // Color logic: You column becomes green/red/grey like MCQAnswerReviewTile
    final Color youColor = (docIsCorrect == null)
        ? Colors.grey
        : (docIsCorrect ? Colors.green : Colors.red);

    // Correct column always indigo
    final Color correctColor = AppColor.indigo;

    // Serial style like your MCQ tiles
    final String serial = '${s.stemNo ?? (index + 1)})';

    const double radioSize = 22;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // LEFT: serial + statement
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
                        data: (s.optionTitle ?? '').trim(),
                        style: {
                          "body": Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            lineHeight: const LineHeight(1.25),
                          ),
                          "p": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
                          "img": Style(width: Width(100, Unit.percent)),
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // RIGHT: Answers
              // If correct hidden => ONLY show You radios
              // If correct shown => show You + divider + Correct radios
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // YOU
                  SizedBox(
                    width: 66,
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

                  // CORRECT (fully removed when hidden)
                  if (_showCorrect) ...[
                    const SizedBox(width: 10),
                    Container(
                      width: 1,
                      height: radioSize + 6,
                      color: Colors.black12,
                    ),


                    SizedBox(
                      width: 66,
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool? _tfToBool(String? v) {
    final s = (v ?? '').trim().toUpperCase();
    if (s == 'T' || s == 'TRUE') return true;
    if (s == 'F' || s == 'FALSE') return false;
    return null;
  }
}
