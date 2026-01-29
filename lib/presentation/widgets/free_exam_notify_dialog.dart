// lib/presentation/widgets/free_exam_notify_dialog.dart
import 'dart:math';
import 'dart:ui' show ImageFilter, lerpDouble;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medi_exam/data/models/free_exam_quota_model.dart';
import 'package:medi_exam/data/services/free_exam_quota_service.dart';
import 'package:medi_exam/data/utils/auth_checker.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';

/// ✅ ONE-TIME-PER-DAY modern "Free Exam Quota" celebration dialog.
/// - Shows ONLY if user is logged in.
/// - Shows ONLY if API says can_create_exam == true
/// - Shows ONLY once per date per doctor.
/// - After OK -> stored in local storage so it doesn't show again that day.
class FreeExamNotifyDialogManager {
  static bool _isShowing = false;

  /// Call this from:
  /// ✅ HomeScreen init (after first frame)
  /// ✅ After login success (immediate)
  static Future<void> maybeShow({BuildContext? context}) async {
    if (_isShowing) return;

    // ✅ Only for logged-in users
    final authed = await AuthChecker.to.isAuthenticated();
    if (!authed) return;

    // ✅ Fetch quota from API
    final res = await FreeExamQuotaService().fetchFreeExamQuota();
    if (!res.isSuccess || res.responseData == null) return;

    final model = res.responseData as FreeExamQuotaModel;

    // ✅ Only show if can_create_exam == true
    if (model.canCreateExam != true) return;

    // ✅ Date from server (preferred); fallback to today
    final serverDate = (model.date ?? '').trim();
    final dateKey = serverDate.isNotEmpty ? serverDate : _todayIso();

    // ✅ One-time per day per doctor
    final doctorId = LocalStorageService.getDoctorId() ?? 0;
    final seenKey = _buildSeenKey(dateKey, doctorId);

    final alreadySeen = LocalStorageService.getString(seenKey) == '1';
    if (alreadySeen) return;

    final ctx = context ?? Get.overlayContext ?? Get.context;
    if (ctx == null) return;

    _isShowing = true;

    try {
      await showGeneralDialog(
        context: ctx,
        barrierDismissible: true,
        barrierLabel: 'Free Exam',
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
                scale: Tween<double>(begin: 0.90, end: 1.0).animate(curved).value,
                child: FreeExamNotifyDialog(
                  remainingQuestions: model.remainingQuestions ?? 0,
                  dailyLimit: model.dailyLimit ?? 0,
                  usedQuestions: model.usedQuestions ?? 0,
                  dateIso: dateKey,
                  onOk: () async {
                    // ✅ Mark as seen for today
                    await LocalStorageService.setString(seenKey, '1');
                    if (Navigator.of(dialogCtx, rootNavigator: true).canPop()) {
                      Navigator.of(dialogCtx, rootNavigator: true).pop();
                    }
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

  static String _buildSeenKey(String dateIso, int doctorId) {
    // Example: free_exam_quota_seen_2026-01-25_2007
    return 'free_exam_quota_seen_${dateIso}_$doctorId';
  }

  static String _todayIso() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

/// ✅ Futuristic compact animated dialog with celebration vibe.
class FreeExamNotifyDialog extends StatefulWidget {
  final int remainingQuestions;
  final int dailyLimit;
  final int usedQuestions;
  final String dateIso; // "2026-01-25"
  final VoidCallback onOk;

  const FreeExamNotifyDialog({
    super.key,
    required this.remainingQuestions,
    required this.dailyLimit,
    required this.usedQuestions,
    required this.dateIso,
    required this.onOk,
  });

  @override
  State<FreeExamNotifyDialog> createState() => _FreeExamNotifyDialogState();
}

class _FreeExamNotifyDialogState extends State<FreeExamNotifyDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;
  late final Animation<double> _shine;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );

    _shine = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = _formatIsoToPretty(widget.dateIso);

    final remaining = widget.remainingQuestions;
    final limit = max(1, widget.dailyLimit);
    final used = max(0, widget.usedQuestions);

    final progressValue = (remaining / limit).clamp(0.0, 1.0);

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.90,
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withOpacity(0.18),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 28,
                  spreadRadius: 0,
                  color: Colors.black.withOpacity(0.20),
                ),
              ],
            ),
            child: CustomBlobBackground(
              backgroundColor: Colors.white.withOpacity(0.92),
              blobColor: AppColor.primaryColor.withOpacity(0.75),
              child: Stack(
                children: [
                  // 🎉 floating particles
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: true,
                      child: CelebrationParticles(controller: _ctrl),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top Glow Badge
                        AnimatedBuilder(
                          animation: _ctrl,
                          builder: (_, __) {
                            return Transform.scale(
                              scale: _pulse.value,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColor.primaryColor.withOpacity(0.18),
                                      Colors.purpleAccent.withOpacity(0.14),
                                      Colors.blueAccent.withOpacity(0.12),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.35),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 18,
                                      color: Colors.deepPurple,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Daily Free Bonus",
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 14),
                        Text(
                          "Congratulations!",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                             fontSize:  Sizes.headingText(context),
                            color: AppColor.primaryColor
                          ),
                        ),
                        const SizedBox(height: 6),
                        ShaderMask(
                          shaderCallback: (rect) {
                            return LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColor.indigo,
                                AppColor.purple,
                                AppColor.purple,
                                AppColor.indigo,
                              ],
                            ).createShader(rect);
                          },
                          child: Text(
                            textAlign: TextAlign.center,
                            "You got $remaining free questions today!",
                            style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.0,
                                fontSize: Sizes.titleText(context)
                            ),
                          ),
                        ),


                        const SizedBox(height: 6),

                        Text(
                          "Claim the free question in Subject-wise preparation section.",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.65),
                            fontWeight: FontWeight.w500,
                            fontSize: Sizes.bodyText(context)
                          ),
                        ),

                        const SizedBox(height: 14),

                        // sleek progress panel
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: Colors.white.withOpacity(0.65),
                            border: Border.all(
                              color: Colors.black.withOpacity(0.06),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Today's quota",
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "$used / $limit used",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: progressValue,
                                  minHeight: 10,
                                  backgroundColor: Colors.black.withOpacity(0.06),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColor.primaryColor.withOpacity(0.9),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Use them now — come back tomorrow for a fresh refill ✨",
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.62),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // OK button with animated shine
                        AnimatedBuilder(
                          animation: _ctrl,
                          builder: (_, __) {
                            return Stack(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      backgroundColor: AppColor.primaryColor,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                    ),
                                    onPressed: widget.onOk,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.check_circle_outline_rounded, size: 20, color: Colors.white,),
                                        SizedBox(width: 10),
                                        Text(
                                          "Awesome!",
                                          style: TextStyle(fontWeight: FontWeight.w800),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // shine overlay
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: Opacity(
                                      opacity: 0.20,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: CustomPaint(
                                          painter: _ShinePainter(progress: _shine.value),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

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

/// ------------------------------------------------------------
/// 🎉 Celebration Particles (no external package)
/// ------------------------------------------------------------
class CelebrationParticles extends StatefulWidget {
  final Animation<double> controller;
  const CelebrationParticles({super.key, required this.controller});

  @override
  State<CelebrationParticles> createState() => _CelebrationParticlesState();
}

class _CelebrationParticlesState extends State<CelebrationParticles> {
  final _rnd = Random();
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = List.generate(22, (i) {
      return _Particle(
        x: _rnd.nextDouble(),
        y: _rnd.nextDouble(),
        size: 1.6 + _rnd.nextDouble() * 2.6,
        speed: 0.20 + _rnd.nextDouble() * 0.55,
        drift: 0.01 + _rnd.nextDouble() * 0.03,
        phase: _rnd.nextDouble() * pi * 2,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (_, __) {
        return CustomPaint(
          painter: _ParticlesPainter(
            t: widget.controller.value,
            particles: _particles,
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

  _ParticlesPainter({required this.t, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      // vertical float (loop)
      final yy = (p.y + t * p.speed) % 1.0;
      final y = yy * size.height;

      // tiny drift
      final driftX = sin(t * pi * 2 + p.phase) * (p.drift * size.width);
      final x = (p.x * size.width) + driftX;

      // gradient-ish alternating colors
      final colorIndex = ((p.x * 10).floor() + (t * 6).floor()) % 3;
      paint.color = [
        AppColor.primaryColor.withOpacity(0.35),
        Colors.purpleAccent.withOpacity(0.28),
        Colors.blueAccent.withOpacity(0.22),
      ][colorIndex];

      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}

/// ------------------------------------------------------------
/// ✨ Shine Painter for OK button
/// ------------------------------------------------------------
class _ShinePainter extends CustomPainter {
  final double progress;
  _ShinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // a diagonal moving shine line
    final x = lerpDouble(-w, w * 1.2, progress)!;

    final rect = Rect.fromLTWH(0, 0, w, h);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.35),
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

/// ------------------------------------------------------------
/// Date formatter: "2026-04-09" -> "09 Apr 2026"
/// ------------------------------------------------------------
String _formatIsoToPretty(String iso) {
  try {
    final parts = iso.split('-');
    if (parts.length != 3) return iso;
    final y = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final d = int.parse(parts[2]);

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final dd = d.toString().padLeft(2, '0');
    final mm = (m >= 1 && m <= 12) ? months[m - 1] : '---';
    return "$dd $mm $y";
  } catch (_) {
    return iso;
  }
}
