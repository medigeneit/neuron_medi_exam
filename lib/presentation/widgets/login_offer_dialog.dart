import 'dart:math';
import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/utils/auth_checker.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';

class LoginOfferPromptManager {
  LoginOfferPromptManager._();

  static bool _handledThisSession = false;
  static bool _isShowing = false;

  static Future<void> maybeShow({BuildContext? context}) async {
    if (_handledThisSession || _isShowing) return;

    final isAuthenticated = await AuthChecker.to.isAuthenticated();
    if (isAuthenticated) return;

    final ctx = context ?? Get.overlayContext ?? Get.context;
    if (ctx == null) return;

    _handledThisSession = true;
    _isShowing = true;

    try {
      await showGeneralDialog(
        context: ctx,
        barrierDismissible: true,
        barrierLabel: 'Login Offer',
        barrierColor: Colors.black.withOpacity(0.55),
        transitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, __, ___) => const SizedBox.shrink(),
        transitionBuilder: (dialogCtx, anim, __, ___) {
          final curved = CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutBack,
            reverseCurve: Curves.easeInCubic,
          );

          return Opacity(
            opacity: anim.value,
            child: Center(
              child: Transform.scale(
                scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved).value,
                child: LoginOfferDialog(
                  onLater: () {
                    if (Navigator.of(dialogCtx, rootNavigator: true).canPop()) {
                      Navigator.of(dialogCtx, rootNavigator: true).pop();
                    }
                  },
                  onLogin: () async {
                    if (Navigator.of(dialogCtx, rootNavigator: true).canPop()) {
                      Navigator.of(dialogCtx, rootNavigator: true).pop();
                    }

                    await Future.delayed(const Duration(milliseconds: 120));

                    Get.toNamed(
                      RouteNames.login,
                      arguments: {
                        'popOnSuccess': true,
                        'returnRoute': null,
                        'returnArguments': null,
                        'message':
                        'Login now to unlock exclusive offers, free exams, and your personal progress.',
                      },
                    );
                  },
                ),
              ),
            ),
          );
        },
      );
    } finally {
      _isShowing = false;
    }
  }
}

class LoginOfferDialog extends StatefulWidget {
  final VoidCallback onLater;
  final VoidCallback onLogin;

  const LoginOfferDialog({
    super.key,
    required this.onLater,
    required this.onLogin,
  });

  @override
  State<LoginOfferDialog> createState() => _LoginOfferDialogState();
}

class _LoginOfferDialogState extends State<LoginOfferDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;
  late final Animation<double> _shine;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.98, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _shine = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.90,
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.20),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 30,
                  color: Colors.black.withOpacity(0.22),
                ),
              ],
            ),
            child: CustomBlobBackground(
              backgroundColor: Colors.white.withOpacity(0.94),
              blobColor: AppColor.purple.withOpacity(0.75),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: _OfferParticles(animation: _controller),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (_, __) {
                            return Transform.scale(
                              scale: _pulse.value,
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColor.primaryColor.withOpacity(0.18),
                                      AppColor.indigo.withOpacity(0.15),
                                      AppColor.purple.withOpacity(0.12),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.45),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColor.primaryColor.withOpacity(0.15),
                                      blurRadius: 16,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.local_offer_rounded,
                                  size: 34,
                                  color: AppColor.primaryColor,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Login',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColor.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Login now to unlock special offers, free exams, saved progress, and a more personalized experience.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface.withOpacity(0.72),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: const [
                            _BenefitChip(
                              icon: Icons.card_giftcard_rounded,
                              label: 'Special Offers',
                            ),
                            _BenefitChip(
                              icon: Icons.quiz_rounded,
                              label: 'Free Exams',
                            ),
                            _BenefitChip(
                              icon: Icons.insights_rounded,
                              label: 'Saved Progress',
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  side: BorderSide(
                                    color: AppColor.primaryColor.withOpacity(0.35),
                                  ),
                                  foregroundColor: AppColor.primaryColor,
                                ),
                                onPressed: widget.onLater,
                                child: const Text(
                                  'Later',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AnimatedBuilder(
                                animation: _controller,
                                builder: (_, __) {
                                  return Stack(
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 13,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            backgroundColor: AppColor.primaryColor,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                          ),
                                          onPressed: widget.onLogin,
                                          icon: const Icon(Icons.login_rounded),
                                          label: const Text(
                                            'Login',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: IgnorePointer(
                                          child: Opacity(
                                            opacity: 0.22,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(16),
                                              child: CustomPaint(
                                                painter: _ShinePainter(
                                                  progress: _shine.value,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
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

class _BenefitChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BenefitChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(0.72),
        border: Border.all(
          color: Colors.black.withOpacity(0.06),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColor.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferParticles extends StatefulWidget {
  final Animation<double> animation;

  const _OfferParticles({required this.animation});

  @override
  State<_OfferParticles> createState() => _OfferParticlesState();
}

class _OfferParticlesState extends State<_OfferParticles> {
  final _random = Random();
  late final List<_Particle> _items;

  @override
  void initState() {
    super.initState();
    _items = List.generate(
      18,
          (_) => _Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 1.4 + _random.nextDouble() * 2.8,
        speed: 0.18 + _random.nextDouble() * 0.55,
        drift: 0.01 + _random.nextDouble() * 0.025,
        phase: _random.nextDouble() * pi * 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (_, __) {
        return CustomPaint(
          painter: _ParticlesPainter(
            t: widget.animation.value,
            particles: _items,
          ),
        );
      },
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double drift;
  final double phase;

  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.drift,
    required this.phase,
  });
}

class _ParticlesPainter extends CustomPainter {
  final double t;
  final List<_Particle> particles;

  _ParticlesPainter({
    required this.t,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final yy = (p.y + t * p.speed) % 1.0;
      final y = yy * size.height;
      final dx = sin(t * pi * 2 + p.phase) * (p.drift * size.width);
      final x = (p.x * size.width) + dx;

      final colorIndex = ((p.x * 10).floor() + (t * 6).floor()) % 3;
      paint.color = [
        AppColor.primaryColor.withOpacity(0.22),
        AppColor.purple.withOpacity(0.18),
        Colors.blueAccent.withOpacity(0.16),
      ][colorIndex];

      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}

class _ShinePainter extends CustomPainter {
  final double progress;

  _ShinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final x = lerpDouble(-w, w * 1.2, progress)!;

    final rect = Rect.fromLTWH(0, 0, w, h);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.34),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0.35, 0.50, 0.65],
        transform: GradientRotation(pi / 10),
      ).createShader(rect);

    canvas.save();
    canvas.translate(x, 0);
    canvas.drawRect(Rect.fromLTWH(-w * 0.6, 0, w * 0.6, h), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ShinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}