import 'package:flutter/material.dart';

import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/animated_text_widget.dart';

///demonstrates a section  for subject wise preparation.
///demonstrates a section  for subject wise preparation.

class ComingSoonWidget extends StatefulWidget {
  final String title;
  final bool isBatch;

  const ComingSoonWidget({
    Key? key,
    required this.title,
    required this.isBatch,
  }) : super(key: key);

  @override
  State<ComingSoonWidget> createState() => _ComingSoonWidgetState();
}

class _ComingSoonWidgetState extends State<ComingSoonWidget>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(20);

    final gradientStroke =
    widget.isBatch ? AppColor.primaryGradient : AppColor.secondaryGradient;

    final textColor = const Color(0xFF111827);

    return Semantics(
      container: true,
      label: '${widget.title} section',
      child: DecoratedBox(
        // outer gradient border
        decoration: BoxDecoration(
          gradient: gradientStroke.withOpacity(0.5),
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(1.6), // border thickness
          decoration: BoxDecoration(
            gradient: gradientStroke,
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Material(
            type: MaterialType.card,
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header
                  _Header(
                    title: widget.title,
                    textColor: textColor,
                    isBatch: widget.isBatch,
                  ),

                  const SizedBox(height: 12),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.black.withOpacity(0.04),
                  ),
                  const SizedBox(height: 12),


                  AnimatedText(
                    text: 'Coming Soon...',
                    color: Colors.black54,
                    animationType: AnimationType.colorShift,
                    colorPalette: [Colors.grey.shade400, Colors.grey.shade800, Colors.black87],
                    duration: Duration(seconds: 2),
                    fontSize: Sizes.bodyText(context),
                    fontWeight: FontWeight.w600,
                  ),


                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _Header extends StatelessWidget {
  final String title;

  final Color textColor;
  final bool isBatch;

  const _Header({
    required this.title,

    required this.textColor,
    required this.isBatch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: Sizes.bodyText(context),
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}