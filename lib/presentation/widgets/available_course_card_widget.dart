import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';

/// A modern, touch-friendly course card with animated press,
/// gradient border, and material ripple.
/// Updated: no top icon, centered title text, arrow at bottom.
class AvailableCourseCardWidget extends StatefulWidget {
  final IconData icon; // kept for backwards-compat but no longer used visually
  final String title;
  final VoidCallback onTap;
  final bool isBatch;

  const AvailableCourseCardWidget({
    Key? key,
    required this.icon, // not displayed anymore
    required this.title,
    required this.onTap,
    required this.isBatch,
  }) : super(key: key);

  @override
  State<AvailableCourseCardWidget> createState() => _AvailableCourseCardWidgetState();
}

class _AvailableCourseCardWidgetState extends State<AvailableCourseCardWidget> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(16);

    // Keep gradient border style consistent with container
    final gradientBorder = widget.isBatch
        ? AppColor.secondaryGradient
        : AppColor.primaryGradient;

    // Subtle scale & elevation when pressed/hovered
    final scale = _pressed ? 0.98 : (_hovered ? 1.01 : 1.0);
    final elevation = _pressed ? 4.0 : (_hovered ? 10.0 : 6.0);

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: DecoratedBox(
        // Outer gradient border
        decoration: BoxDecoration(
          gradient: gradientBorder.withOpacity(0.5),
          color: Colors.white,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Container(
          // Border thickness
          margin: const EdgeInsets.all(1.6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Material(
            color: Colors.white.withOpacity(0.88),
            elevation: elevation,
            shadowColor: Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              onHover: (h) => setState(() => _hovered = h),
              onHighlightChanged: (p) => setState(() => _pressed = p),
              borderRadius: BorderRadius.circular(14),
              splashColor: theme.colorScheme.primary.withOpacity(0.10),
              highlightColor: theme.colorScheme.primary.withOpacity(0.06),
              child: Padding(
                // a bit more vertical padding to center things nicely
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Centered title (takes available space)
                    Expanded(
                      child: Center(
                        child: Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: Sizes.verySmallText(context),
                            fontWeight: FontWeight.w700,
                            color: AppColor.primaryTextColor,
                            height: 1.2,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),

                    // Right arrow pinned at bottom-center
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 140),
                      curve: Curves.easeOut,
                      offset: _pressed
                          ? const Offset(0.05, 0) // tiny nudge when pressed
                          : (_hovered ? const Offset(0.02, 0) : Offset.zero),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Icon(
                          Icons.arrow_circle_right_outlined,
                          size: Sizes.verySmallIcon(context),
                          color: theme.colorScheme.primary.withOpacity(0.75),
                          semanticLabel: 'Open',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
