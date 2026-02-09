import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';

class UnitsVsQuestionsDialog extends StatelessWidget {
  final Color blobColor;
  final Color backgroundColor;

  const UnitsVsQuestionsDialog({
    super.key,
    this.blobColor = const Color(0xFF2D3142),
    this.backgroundColor = Colors.white,
  });

  /// Call this anywhere to show the dialog
  static Future<void> show(
      BuildContext context, {
        Color blobColor = const Color(0xFF2D3142),
        Color backgroundColor = Colors.white,
      }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => UnitsVsQuestionsDialog(
        blobColor: blobColor,
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // We keep an AlertDialog-like layout but with your custom background.
    return Dialog(
      backgroundColor: Colors.transparent,
/*      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),*/
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomBlobBackground(
          blobColor: blobColor,
          backgroundColor: backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header (same as your AlertDialog title row)
                Row(
                  children: const [
                    Icon(Icons.info_outline_rounded, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Units vs Questions',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Body (scrollable for small phones)
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What is Total?',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: Sizes.smallText(context),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'This card shows performance using Units (answerable parts).',
                        ),
                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.withOpacity(0.15)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• SBA: 1 question = 1 unit'),
                              const SizedBox(height: 4),
                              const Text(
                                '• MCQ: 1 question = multiple stems (e.g., 5 stems = 5 units)',
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'So Total Units = (MCQ stems) + (SBA questions).',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black.withOpacity(0.75),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),
                        Text(
                          'How the stats work',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: Sizes.smallText(context),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Correct / Wrong / Skipped are calculated in Units.\n'
                              'Question counts are shown separately as “Total Question”.',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Actions
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Got it'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
