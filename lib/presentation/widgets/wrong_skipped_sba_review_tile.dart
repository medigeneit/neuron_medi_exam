import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';
import 'package:medi_exam/presentation/widgets/labeled_radio.dart';
import 'package:medi_exam/presentation/widgets/question_action_row.dart';

/// Wrong/Skipped SBA review tile
/// Redesigned to match SBAAnswerReviewTile & SBAQuestionTile style:
/// - Left: serial (a), b)...) + option HTML
/// - Right: You (letter radio) + optional divider + Correct (letter radio)
/// - Correct section fully removed when hidden (no lock icon, no empty column)
class WrongSkippedSBAReviewTile extends StatefulWidget {
  final String indexLabel;
  final String titleHtml;
  final Map<String, String> options; // {"A": "...", "B": "..."}
  final String? givenAnswer; // e.g. "B"
  final String? correctAnswer; // e.g. "A"
  final int? questionId;
  final Color blobColor;

  /// Global show/hide sync from overview card
  final bool showAllCorrect;

  const WrongSkippedSBAReviewTile({
    super.key,
    required this.indexLabel,
    required this.titleHtml,
    required this.options,
    required this.givenAnswer,
    required this.correctAnswer,
    required this.questionId,
    this.blobColor = AppColor.indigo,
    this.showAllCorrect = false,
  });

  @override
  State<WrongSkippedSBAReviewTile> createState() =>
      _WrongSkippedSBAReviewTileState();
}

class _WrongSkippedSBAReviewTileState extends State<WrongSkippedSBAReviewTile> {
  bool _showCorrect = false;

  @override
  void initState() {
    super.initState();
    _showCorrect = widget.showAllCorrect;
  }

  @override
  void didUpdateWidget(covariant WrongSkippedSBAReviewTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showAllCorrect != widget.showAllCorrect) {
      setState(() => _showCorrect = widget.showAllCorrect);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = _sortedOptions(widget.options); // A..Z
    final String givenKey = (widget.givenAnswer ?? '').trim().toUpperCase();
    final String correctKey = (widget.correctAnswer ?? '').trim().toUpperCase();

    final bool hasGiven = givenKey.isNotEmpty;
    final bool hasCorrect = correctKey.isNotEmpty;
    final bool? docIsCorrect =
    (hasGiven && hasCorrect) ? (givenKey == correctKey) : null;

    return CustomBlobBackground(
      backgroundColor: Colors.white,
      blobColor: widget.blobColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),

            const SizedBox(height: 8),

            // Column headers aligned to the right like your answer tiles
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

            ...List.generate(entries.length, (i) {
              final key = entries[i].key.toUpperCase();
              final text = entries[i].value;
              return _optionRow(
                context,
                key: key,
                text: text,
                givenKey: givenKey,
                correctKey: correctKey,
                docIsCorrect: docIsCorrect,
              );
            }),

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
        // Index circle (matching your other tiles)
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
      width: 42, // matches the single-letter radio area
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

  Widget _optionRow(
      BuildContext context, {
        required String key,
        required String text,
        required String givenKey,
        required String correctKey,
        required bool? docIsCorrect,
      }) {
    final bool youSelected = givenKey.isNotEmpty && (givenKey == key);
    final bool correctSelected = correctKey.isNotEmpty && (correctKey == key);

    final Color youColor = (docIsCorrect == null)
        ? Colors.grey
        : (docIsCorrect ? Colors.green : Colors.red);

    final Color correctColor = AppColor.indigo;

    const double radioSize = 22;

    final String serial = key.isNotEmpty ? '${key.toLowerCase()})' : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // LEFT: serial + option html
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
                        data: text,
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

              // RIGHT: You + optional divider + Correct
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // YOU
                  SizedBox(
                    width: 42,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: LabeledRadio(
                        label: key,
                        selected: youSelected,
                        disabled: true,
                        selectedColor: youSelected ? youColor : Colors.grey,
                        size: radioSize,
                      ),
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
                      width: 42,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: LabeledRadio(
                          label: key,
                          selected: correctSelected,
                          disabled: true,
                          selectedColor: correctColor,
                          size: radioSize,
                        ),
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

  List<MapEntry<String, String>> _sortedOptions(Map<String, String> map) {
    final entries = map.entries.toList();
    entries.sort((a, b) => a.key.toUpperCase().compareTo(b.key.toUpperCase()));
    return entries;
  }
}
