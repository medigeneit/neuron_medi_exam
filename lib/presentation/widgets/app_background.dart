import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:medi_exam/presentation/utils/app_colors.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.showParticles = true,
    this.showSoftGrid = true,
    this.intensity = 0.3,
  });

  final Widget child;
  final bool showParticles;
  final bool showSoftGrid;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _blendColors(const Color(0xFF662483), Colors.white, 0.95),
                _blendColors(const Color(0xFF6366F1), Colors.white, 0.98),
                _blendColors(const Color(0xFF8B5CF6), Colors.white, 0.96),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // Subtle grid pattern
        if (showSoftGrid) ..._buildGridPattern(),

        // Floating particles
        if (showParticles) ..._buildParticles(context, intensity),

        // Soft vignette effect
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.02),
              ],
            ),
          ),
        ),

        // Content
        child,
      ],
    );
  }

  List<Widget> _buildGridPattern() {
    return [
      Opacity(
        opacity: 0.06,
        child: CustomPaint(
          painter: _GridPainter(),
          size: Size.infinite,
        ),
      ),
    ];
  }

  List<Widget> _buildParticles(BuildContext context, double intensity) {
    final particles = <Widget>[];
    final colors = [
      const Color(0xFF662483).withOpacity(0.15 * intensity),
      const Color(0xFF6366F1).withOpacity(0.12 * intensity),
      const Color(0xFF8B5CF6).withOpacity(0.10 * intensity),
    ];

    // Add multiple particles at different positions
    for (int i = 0; i < 8; i++) {
      particles.add(
        Positioned(
          top: _getParticlePosition(i, 0) * MediaQuery.of(context).size.height,
          left: _getParticlePosition(i, 1) * MediaQuery.of(context).size.width,
          child: _FloatingParticle(
            color: colors[i % colors.length],
            size: 60 + (i * 15),
            delay: i * 1000,
          ),
        ),
      );
    }

    return particles;
  }

  double _getParticlePosition(int index, int axis) {
    final positions = [
      [0.1, 0.2], [0.8, 0.1], [0.2, 0.7], [0.9, 0.6],
      [0.15, 0.9], [0.7, 0.3], [0.3, 0.4], [0.85, 0.8],
    ];
    return positions[index % positions.length][axis];
  }

  Color _blendColors(Color color1, Color color2, double ratio) {
    return Color.lerp(color1, color2, ratio)!;
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColor.primaryColor
      ..strokeWidth = 0.8 // Increased stroke width
      ..style = PaintingStyle.stroke;

    // Top-left corner wave pattern
    _drawCornerWaves(canvas, paint, Offset(0, 0), size.width * 0.4, true);

    // Bottom-right corner wave pattern
    _drawCornerWaves(canvas, paint, Offset(size.width, size.height), size.width * 0.4, false);
  }

  void _drawCornerWaves(Canvas canvas, Paint paint, Offset origin, double maxDistance, bool isTopLeft) {
    final waveCount = 12; // Increased wave count for denser pattern
    final waveSpacing = maxDistance / waveCount;

    for (int i = 0; i < waveCount; i++) {
      final radius = i * waveSpacing;
      final amplitude = waveSpacing * 0.1; // Reduced amplitude for tighter waves
      final points = <Offset>[];

      // Generate more points for smoother waves
      for (double angle = 0; angle <= math.pi / 2; angle += math.pi / 50) {
        final waveOffset = math.sin(angle * 5) * amplitude; // Increased frequency
        double x, y;

        if (isTopLeft) {
          x = origin.dx + radius * math.cos(angle) + waveOffset * math.cos(angle + math.pi/2);
          y = origin.dy + radius * math.sin(angle) + waveOffset * math.sin(angle + math.pi/2);
        } else {
          x = origin.dx - radius * math.cos(angle) - waveOffset * math.cos(angle + math.pi/2);
          y = origin.dy - radius * math.sin(angle) - waveOffset * math.sin(angle + math.pi/2);
        }

        points.add(Offset(x, y));
      }

      // Draw the wave line
      if (points.length > 1) {
        final path = Path();
        path.moveTo(points[0].dx, points[0].dy);
        for (int j = 1; j < points.length; j++) {
          path.lineTo(points[j].dx, points[j].dy);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FloatingParticle extends StatefulWidget {
  const _FloatingParticle({
    required this.color,
    required this.size,
    required this.delay,
  });

  final Color color;
  final double size;
  final int delay;

  @override
  _FloatingParticleState createState() => _FloatingParticleState();
}

class _FloatingParticleState extends State<_FloatingParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159, // 2π radians for full circle
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ))
      ..addListener(() => setState(() {}));

    // Start animation after delay
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offsetX = 20 * math.cos(_animation.value);
    final offsetY = 10 * math.sin(_animation.value * 2);

    return Transform.translate(
      offset: Offset(offsetX, offsetY),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}


