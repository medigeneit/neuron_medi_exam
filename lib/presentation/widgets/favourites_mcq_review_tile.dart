import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:medi_exam/data/models/favourite_questions_list_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';
import 'package:medi_exam/presentation/widgets/labeled_radio.dart';
import 'package:medi_exam/presentation/widgets/question_action_row.dart';

class FavouritesMCQReviewTile extends StatefulWidget {
  final String indexLabel;
  final String titleHtml;
  final List<FavouriteQuestionOption> options;
  final String? answerScript; // e.g. "TTFTF"
  final int? questionId;
  final Color blobColor;

  /// Global show/hide sync from overview card
  final bool showAllAnswers;

  /// If user unfavourites from this tile, remove from screen list
  final void Function(int questionId)? onRemovedFromFavourites;

  const FavouritesMCQReviewTile({
    super.key,
    required this.indexLabel,
    required this.titleHtml,
    required this.options,
    required this.answerScript,
    required this.questionId,
    this.blobColor = AppColor.purple,
    this.showAllAnswers = false,
    this.onRemovedFromFavourites,
  });

  @override
  State<FavouritesMCQReviewTile> createState() => _FavouritesMCQReviewTileState();
}

class _FavouritesMCQReviewTileState extends State<FavouritesMCQReviewTile> {
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _showAnswer = widget.showAllAnswers;
  }

  @override
  void didUpdateWidget(covariant FavouritesMCQReviewTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showAllAnswers != widget.showAllAnswers) {
      setState(() => _showAnswer = widget.showAllAnswers);
    }
  }

  @override
  Widget build(BuildContext context) {
    final correctStates = _parseMcqScript(widget.answerScript, widget.options.length);

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

            // ✅ Only "Answer" header (no "You")
            if (_showAnswer)
              Align(
                alignment: Alignment.centerRight,
                child: _colHeader(context, "Answer"),
              ),

            if (_showAnswer) const SizedBox(height: 8),

            ...List.generate(
              widget.options.length,
                  (i) => _statementRow(
                context,
                widget.options[i],
                correctStates[i],
              ),
            ),

            const SizedBox(height: 2),

            // ✅ Action row (allows un-favourite)
            QuestionActionRow(
              questionId: widget.questionId,
              initiallyBookmarked: true,
              onFavouriteChanged: (isFav) {
                if (!isFav && widget.questionId != null) {
                  widget.onRemovedFromFavourites?.call(widget.questionId!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColor.secondaryGradient,
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
            onTap: () => setState(() => _showAnswer = !_showAnswer),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _showAnswer
                    ? AppColor.primaryColor.withOpacity(0.10)
                    : Colors.grey.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _showAnswer ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                size: 20,
                color: _showAnswer ? AppColor.primaryColor : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _colHeader(BuildContext context, String text) {
    return SizedBox(
      width: 66,
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

  Widget _statementRow(BuildContext context, FavouriteQuestionOption opt, bool? correct) {
    const double radioSize = 22;
    final String serial = opt.serial != null ? '${opt.serial!.toLowerCase()})' : '';

    final Color correctColor = AppColor.indigo;

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
                        data: (opt.title ?? '').trim(),
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

              if (_showAnswer)
                SizedBox(
                  width: 66,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      LabeledRadio(
                        label: 'T',
                        selected: correct == true,
                        disabled: true,
                        selectedColor: correctColor,
                        size: radioSize,
                      ),
                      const SizedBox(width: 8),
                      LabeledRadio(
                        label: 'F',
                        selected: correct == false,
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

  List<bool?> _parseMcqScript(String? script, int len) {
    final out = List<bool?>.filled(len, null);
    final s = (script ?? '').trim().toUpperCase();
    if (s.isEmpty) return out;

    final n = s.length < len ? s.length : len;
    for (int i = 0; i < n; i++) {
      final ch = s[i];
      if (ch == 'T') out[i] = true;
      if (ch == 'F') out[i] = false;
    }
    return out;
  }
}
