import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';

class FreeExamCardButton extends StatefulWidget {
  final VoidCallback onTap;

  const FreeExamCardButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  State<FreeExamCardButton> createState() =>
      _FreeExamCardButtonState();
}

class _FreeExamCardButtonState extends State<FreeExamCardButton>
    with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  late final AnimationController _glowCtrl;
  late final AnimationController _pressCtrl;
  late final AnimationController _iconCtrl;

  @override
  void initState() {
    super.initState();

    // Background gradient motion
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // Glow "breathing"
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);

    // Press / bounce feedback
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    // Bolt pulse
    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _glowCtrl.dispose();
    _pressCtrl.dispose();
    _iconCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    // tiny bounce
    await _pressCtrl.forward();
    await _pressCtrl.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(14);

    // Base colors (your original vibe)
    const c1 =  AppColor.purple; // coral/pink
    const c3 = AppColor.indigo; // aqua

    return AnimatedBuilder(
      animation: Listenable.merge([_bgCtrl, _glowCtrl, _pressCtrl, _iconCtrl]),
      builder: (context, _) {
        // Move gradient endpoints around in a loop
        final t = _bgCtrl.value;
        final ax = math.sin(t * 2 * math.pi);
        final ay = math.cos(t * 2 * math.pi);
        final begin = Alignment(ax, -ay);
        final end = Alignment(-ax, ay);



        // press scale (slightly shrink on press)
        final pressScale = 1.0 - (_pressCtrl.value * 0.03);

        // icon pulse
        final iconScale = 1.0 + (_iconCtrl.value * 0.12);

        return Transform.scale(
          scale: pressScale,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                colors: const [c1, c3],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.22),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),

              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: borderRadius,
                onTap: _handleTap,
                onTapDown: (_) => _pressCtrl.forward(),
                onTapCancel: () => _pressCtrl.reverse(),
                child: Stack(
                  children: [

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          // Badge-ish icon circle + pulse
                          Transform.scale(
                            scale: iconScale,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.22),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white30,
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.bolt_rounded,
                                color: Colors.white,
                                size: Sizes.verySmallIcon(context),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Slight animated emphasis using shadow glow
                                Text(
                                  'Free Exam',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: Sizes.normalText(context),
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.2,
                                    shadows: [
                                      Shadow(
                                        color: Colors.white.withOpacity(
                                            0.08 + _glowCtrl.value * 0.18),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Test yourself with our free exams!',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: Sizes.verySmallText(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Optional subtle arrow that gently fades in/out
                          Opacity(
                            opacity: 0.45 + (_glowCtrl.value * 0.35),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A lightweight diagonal sweep shimmer using a moving gradient + ClipRRect.
class _SweepShimmer extends StatelessWidget {
  final double progress;
  final BorderRadius borderRadius;

  const _SweepShimmer({
    required this.progress,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // map 0..1 to -1..1
    final x = (progress * 2) - 1;

    return ClipRRect(
      borderRadius: borderRadius,
      child: Transform.translate(
        offset: Offset(x * 120, 0),
        child: Transform.rotate(
          angle: -0.45,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.18),
                  Colors.transparent,
                ],
                stops: const [0.35, 0.5, 0.65],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
