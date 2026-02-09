import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:medi_exam/data/models/favourite_questions_list_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';
import 'package:medi_exam/presentation/widgets/labeled_radio.dart';
import 'package:medi_exam/presentation/widgets/question_action_row.dart';

class FavouritesSBAReviewTile extends StatefulWidget {
  final String indexLabel;
  final String titleHtml;
  final List<FavouriteQuestionOption> options; // A..E
  final String? answerScript; // e.g. "B"
  final int? questionId;
  final Color blobColor;

  /// Global show/hide sync from overview card
  final bool showAllAnswers;

  /// If user unfavourites from this tile, remove from screen list
  final void Function(int questionId)? onRemovedFromFavourites;

  const FavouritesSBAReviewTile({
    super.key,
    required this.indexLabel,
    required this.titleHtml,
    required this.options,
    required this.answerScript,
    required this.questionId,
    this.blobColor = AppColor.indigo,
    this.showAllAnswers = false,
    this.onRemovedFromFavourites,
  });

  @override
  State<FavouritesSBAReviewTile> createState() => _FavouritesSBAReviewTileState();
}

class _FavouritesSBAReviewTileState extends State<FavouritesSBAReviewTile> {
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _showAnswer = widget.showAllAnswers;
  }

  @override
  void didUpdateWidget(covariant FavouritesSBAReviewTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showAllAnswers != widget.showAllAnswers) {
      setState(() => _showAnswer = widget.showAllAnswers);
    }
  }

  @override
  Widget build(BuildContext context) {
    final correctKey = (widget.answerScript ?? '').trim().toUpperCase();

    return CustomBlobBackground(
      backgroundColor: Colors.white,
      blobColor: widget.blobColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),

            const SizedBox(height: 10),

            if (_showAnswer)
              Align(
                alignment: Alignment.centerRight,
                child: _colHeader(context, "Answer"),
              ),

            if (_showAnswer) const SizedBox(height: 8),

            ...List.generate(widget.options.length, (i) {
              final opt = widget.options[i];
              final key = (opt.serial ?? '').trim().toUpperCase();
              final serial = key.isNotEmpty ? '${key.toLowerCase()})' : '';

              final bool correctSelected = _showAnswer && key.isNotEmpty && (key == correctKey);

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
                            width: 42,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: LabeledRadio(
                                label: key,
                                selected: correctSelected,
                                disabled: true,
                                selectedColor: AppColor.indigo,
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
