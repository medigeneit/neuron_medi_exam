import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';

// Reusable decorated background
class FancyBackground extends StatelessWidget {
  const FancyBackground({
    super.key,
    required this.child,
    this.gradient,
    this.radius = 24,
    this.padding = const EdgeInsets.all(24),
    this.showDecorations = true,
    this.boxShadow,
  });

  /// The content placed on top of the background.
  final Widget child;

  /// Optional gradient. Falls back to AppColor.primaryGradient.
  final Gradient? gradient;

  /// Corner radius.
  final double radius;

  /// Inner padding around [child].
  final EdgeInsetsGeometry padding;

  /// Toggle decorative circles.
  final bool showDecorations;

  /// Optional custom shadows. Defaults to the original look.
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient ?? AppColor.primaryGradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: AppColor.primaryColor.withOpacity(0.4),
                blurRadius: 25,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
            ],
      ),
      child: Stack(
        children: [
          if (showDecorations) ...[
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColor.whiteColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColor.whiteColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }
}
