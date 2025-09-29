import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';

class PaymentSuccessDialog extends StatefulWidget {
  /// e.g. 'Payment Submitted' or 'Manual payment received'
  final String message;

  /// e.g. '৳1,000.00'
  final String amountText;

  /// How long to show dialog before auto-navigation
  final Duration autoNavigateAfter;

  const PaymentSuccessDialog({
    super.key,
    required this.message,
    required this.amountText,
    this.autoNavigateAfter = const Duration(seconds: 3),
  });

  /// Convenience helper
  static Future<void> show({
    required String message,
    required String amountText,
    Duration autoNavigateAfter = const Duration(seconds: 3),
  }) async {
    await Get.dialog(
      PaymentSuccessDialog(
        message: message,
        amountText: amountText,
        autoNavigateAfter: autoNavigateAfter,
      ),
      barrierDismissible: false,
    );
  }

  @override
  State<PaymentSuccessDialog> createState() => _PaymentSuccessDialogState();
}

class _PaymentSuccessDialogState extends State<PaymentSuccessDialog>
    with TickerProviderStateMixin {
  late final AnimationController _entrance; // one-time scale in
  late final AnimationController _pulse;    // repeating pulse for badge
  late final AnimationController _ripple;   // expanding ripple behind badge
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      lowerBound: 0.9,
      upperBound: 1.0,
    )..forward();

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);

    _ripple = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _timer = Timer(widget.autoNavigateAfter, () {
      if (Get.isDialogOpen == true) Get.back();
      Get.offAllNamed(RouteNames.navBar, arguments: 0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _entrance.dispose();
    _pulse.dispose();
    _ripple.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: ScaleTransition(
            scale: _entrance.drive(
              Tween(begin: 0.94, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 460),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.transparent,
              child: CustomBlobBackground(
                backgroundColor: AppColor.whiteColor,
                blobColor: Colors.green,
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // === Animated Badge with Ripple & Glow ===
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Expanding ripple ring behind the badge
                            AnimatedBuilder(
                              animation: _ripple,
                              builder: (_, __) {
                                final t = _ripple.value; // 0..1
                                final size = 72 + (t * 40); // expands
                                final opacity = (1 - t).clamp(0.0, 1.0);
                                return Container(
                                  width: size,
                                  height: size,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColor.indigo.withOpacity(0.08 * opacity),
                                  ),
                                );
                              },
                            ),
                            // Pulsing badge with glow
                            AnimatedBuilder(
                              animation: _pulse,
                              builder: (_, __) {
                                // pulse scale: 1.0 -> 1.05 -> 1.0
                                final s = 1.0 + (_pulse.value * 0.05);
                                final glow = 12.0 + (_pulse.value * 10.0);
                                return Transform.scale(
                                  scale: s,
                                  child: Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [AppColor.indigo, AppColor.purple],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColor.indigo.withOpacity(0.35),
                                          blurRadius: glow,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.check_rounded,
                                        color: Colors.white, size: 40),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // === Animated amount with sheen sweep ===
                      _GradientAmountAnimated(text: widget.amountText),
                      const SizedBox(height: 8),

                      // Message
                      Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'Redirecting to dashboard…',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.5, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated gradient amount with a subtle sheen sweep.
class _GradientAmountAnimated extends StatefulWidget {
  final String text;
  const _GradientAmountAnimated({required this.text});

  @override
  State<_GradientAmountAnimated> createState() => _GradientAmountAnimatedState();
}

class _GradientAmountAnimatedState extends State<_GradientAmountAnimated>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sheen;

  @override
  void initState() {
    super.initState();
    _sheen = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _sheen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Gradient-filled amount text
        ShaderMask(
          shaderCallback: (r) => LinearGradient(
            colors: [AppColor.indigo, AppColor.purple],
          ).createShader(r),
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white, // masked by shader
              letterSpacing: -0.2,
            ),
          ),
        ),
        // Moving sheen bar
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _sheen,
              builder: (_, __) {
                final t = _sheen.value; // 0..1
                return Opacity(
                  opacity: 0.25,
                  child: Transform.translate(
                    offset: Offset(-140 + (280 * t), 0),
                    child: Container(
                      width: 90,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
