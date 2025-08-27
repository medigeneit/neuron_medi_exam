import 'package:flutter/material.dart';


class CustomBackground extends StatelessWidget {
  const CustomBackground({
    super.key,
    required this.child,
    this.colors,
    this.showTopLeftBlob = true,
    this.showBottomRightBlob = true,
  });

  final Widget child;
  final List<Color>? colors;
  final bool showTopLeftBlob;
  final bool showBottomRightBlob;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final gradientColors = colors ??
        [
          cs.primary.withOpacity(.15),
          cs.secondary.withOpacity(.10),
          cs.tertiary.withOpacity(.10),
        ];

    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
        ),

        // Top-left blob
        if (showTopLeftBlob)
          const Positioned(
            top: -80,
            left: -60,
            child: _Blob(size: 220),
          ),

        // Bottom-right blob
        if (showBottomRightBlob)
          Positioned(
            bottom: -60,
            right: -40,
            child: _Blob(
              size: 180,
              // Slightly different opacity for variety using theme secondary
              colorOverride:
              cs.secondary.withOpacity(.18), // fallback handled in _Blob
            ),
          ),

        // Page content
        child,
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, this.colorOverride});

  final double size;
  final Color? colorOverride;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final baseColor = colorOverride ?? cs.primary.withOpacity(.20);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: baseColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(.35),
            blurRadius: 60,
            spreadRadius: 10,
          )
        ],
      ),
    );
  }
}
