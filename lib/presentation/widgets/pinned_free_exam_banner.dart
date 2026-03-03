import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';

class PinnedFreeExamBanner extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final double height;

  const PinnedFreeExamBanner({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.height = 72,
  }) : super(key: key);

  @override
  State<PinnedFreeExamBanner> createState() => _PinnedFreeExamBannerState();
}

class _PinnedFreeExamBannerState extends State<PinnedFreeExamBanner>
    with TickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final AnimationController _badgeCtrl;

  @override
  void initState() {
    super.initState();

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0,
      upperBound: 1,
    );

    // Badge pulse — gentle scale + glow breathe
    _badgeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _badgeCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _pressCtrl.forward();
    await _pressCtrl.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(20);

    return SizedBox(
      height: widget.height + 20, // top overflow room for badge
      child: AnimatedBuilder(
        animation: Listenable.merge([_pressCtrl, _badgeCtrl]),
        builder: (context, _) {
          final pressScale = 1.0 - (_pressCtrl.value * 0.025);

          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Transform.scale(
              scale: pressScale,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ── MAIN CARD ──────────────────────────────────────
                  GestureDetector(
                    onTap: _handleTap,
                    onTapDown: (_) => _pressCtrl.forward(),
                    onTapCancel: () => _pressCtrl.reverse(),
                    child: Container(
                      height: widget.height,
                      decoration: BoxDecoration(
                        borderRadius: borderRadius,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColor.primaryColor,
                            AppColor.purple,
                            AppColor.indigo
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.primaryColor.withOpacity(0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: borderRadius,
                        child: Stack(
                          children: [
                            // Subtle decorative circle top-right
                            Positioned(
                              right: -25,
                              top: -25,
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.05),
                                ),
                              ),
                            ),

                            // Content
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  // Icon box
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.school_rounded,
                                      color: Colors.white,
                                      size: Sizes.smallIcon(context),
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  // Texts
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                /*                        // "LIMITED OFFER" chip
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFBBF24)
                                                .withOpacity(0.18),
                                            borderRadius:
                                            BorderRadius.circular(4),
                                            border: Border.all(
                                              color: const Color(0xFFFBBF24)
                                                  .withOpacity(0.45),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(
                                                Icons.bolt_rounded,
                                                color: Color(0xFFFBBF24),
                                                size: 10,
                                              ),
                                              SizedBox(width: 3),
                                              Text(
                                                'LIMITED OFFER',
                                                style: TextStyle(
                                                  color: Color(0xFFFBBF24),
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.8,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 5),*/
                                        Text(
                                          widget.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: Sizes.normalText(context),
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          widget.subtitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color:
                                            Colors.white.withOpacity(0.72),
                                            fontSize:
                                            Sizes.verySmallText(context),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Reserve space so text doesn't go under badge
                                  const SizedBox(width: 56),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── FREE BADGE — top-right, half outside ──────────
                  Positioned(
                    top: -12,
                    right: -6,
                    child: _FreeBadge(pulse: _badgeCtrl.value),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Animated FREE offer badge
class _FreeBadge extends StatelessWidget {
  final double pulse; // 0..1 from AnimationController

  const _FreeBadge({required this.pulse});

  @override
  Widget build(BuildContext context) {
    final scale = 1.0 + pulse * 0.1;
    final glowOpacity = 0.28 + pulse * 0.28;

    return Transform.scale(
      scale: scale,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.amber, Colors.deepOrangeAccent],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFBBF24).withOpacity(glowOpacity),
              blurRadius: 14,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.push_pin_rounded, color: Colors.white, size: 12),
            SizedBox(width: 4),
            Text(
              'FREE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}