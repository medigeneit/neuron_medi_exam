import 'dart:math';
import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';

class LoadingWidget extends StatefulWidget {
  final Color? color;
  final double? size;

  const LoadingWidget({
    super.key,
    this.color,
    this.size,
  });

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = (widget.color ?? AppColor.primaryColor);
    final double size = widget.size ?? Sizes.loaderBig(context);

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value; // 0..1
          final double r = size * 0.56; // orbit radius
          final double ringThickness = max(2.0, size * 0.085);
          final double orbSize = size * 0.18;

          // differing speeds/phases for parallax feel
          final a1 = (t * 2 * pi);            // question mark
          final a2 = (-t * 2 * pi * 1.3);     // check
          final a3 = (t * 2 * pi * 1.8);      // cap

          // soft breathing + micro-tilt
          final pulse = 1.0 + 0.05 * sin(t * 2 * pi * 2.0);
          final wobble = 0.05 * sin(t * 2 * pi);

          return Stack(
            alignment: Alignment.center,
            children: [
              // sweeping/glowing progress ring
              Positioned.fill(
                child: CustomPaint(
                  painter: _RingPainter(
                    progress: t,
                    color: primary,
                    thickness: ringThickness,
                  ),
                ),
              ),

              // orbiting “exam” cues
              Transform.translate(
                offset: Offset(cos(a1) * r, sin(a1) * r),
                child: _Orb(
                  size: orbSize * 0.9,
                  color: primary.withOpacity(0.95),
                  child: Icon(Icons.question_mark,
                      size: orbSize * 0.62, color: Colors.white),
                ),
              ),
              Transform.translate(
                offset: Offset(cos(a2) * r, sin(a2) * r),
                child: _Orb(
                  size: orbSize * 0.9,
                  color: primary.withOpacity(0.95),
                  child: Icon(Icons.check_rounded,
                      size: orbSize * 0.62, color: Colors.white),
                ),
              ),
              Transform.translate(
                offset: Offset(cos(a3) * r, sin(a3) * r),
                child: _Orb(
                  size: orbSize * 0.95,
                  color: primary.withOpacity(0.85),
                  child: Icon(Icons.clear_rounded,
                      size: orbSize * 0.62, color: Colors.white),
                ),
              ),

              // center “PGEasy” badge
              Transform.rotate(
                angle: wobble,
                child: Transform.scale(
                  scale: pulse,
                  child: _PGEasyBadge(
                    size: size * 0.56,
                    color: primary,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress; // 0..1
  final Color color;
  final double thickness;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = min(size.width, size.height) * 0.56;

    // base ring
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..color = color.withOpacity(0.12)
      ..isAntiAlias = true;
    canvas.drawCircle(center, radius, base);

    // sweeping arc with rotating gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweep = pi * 1.65; // visible arc length
    final start = -pi / 2 + progress * 2 * pi;

    final shader = SweepGradient(
      startAngle: 0,
      endAngle: 2 * pi,
      transform: GradientRotation(progress * 2 * pi),
      colors: [
        color.withOpacity(0.05),
        color.withOpacity(0.25),
        color,
        color.withOpacity(0.25),
        color.withOpacity(0.05),
      ],
      stops: const [0.00, 0.25, 0.50, 0.75, 1.00],
    ).createShader(rect);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..shader = shader
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, thickness * 0.35)
      ..isAntiAlias = true;

    canvas.drawArc(rect, start, sweep, false, arc);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
          oldDelegate.color != color ||
          oldDelegate.thickness != thickness;
}

class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  final Widget child;

  const _Orb({
    required this.size,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.55),
            blurRadius: size * 0.9,
            spreadRadius: size * 0.12,
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.22),
          width: size * 0.06,
        ),
      ),
      child: child,
    );
  }
}

class _PGEasyBadge extends StatelessWidget {
  final double size;
  final Color color;

  const _PGEasyBadge({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.28);

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.12),
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.95),
            color.withOpacity(0.70),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.45),
            blurRadius: size * 0.65,
            spreadRadius: size * 0.08,
          ),
        ],
      ),
      child: FittedBox(
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.white.withOpacity(0.85),
            ],
          ).createShader(rect),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PG',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  height: 0.9,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 2),
                      blurRadius: size * 0.06,
                      color: Colors.black.withOpacity(0.25),
                    ),
                  ],
                ),
              ),
              Text(
                'Easy',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  height: 0.9,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 2),
                      blurRadius: size * 0.06,
                      color: Colors.black.withOpacity(0.25),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
