import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

class BannerImage extends StatelessWidget {
  final String? url;

  const BannerImage({
    Key? key,
    required this.url,
  }) : super(key: key);

  bool get _hasValidUrl => url != null && url!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1D4ED8),
            Color(0xFF7C3AED),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _BannerPatternBackground(),

          // blurred image fills the whole banner background
          if (_hasValidUrl)
            Positioned.fill(
              child: ClipRect(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                  child: Image.network(
                    url!,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),

          // dark overlay for better look
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.16),
                    Colors.black.withOpacity(0.22),
                  ],
                ),
              ),
            ),
          ),

          // main image: takes maximum possible square space
          LayoutBuilder(
            builder: (context, constraints) {
              final double horizontalPadding = 12;
              final double verticalPadding = 12;

              final double maxImageSize = math.min(
                constraints.maxHeight - (verticalPadding * 2),
                constraints.maxWidth - (horizontalPadding * 2),
              );

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Center(
                  child: Container(
                    width: maxImageSize,
                    height: maxImageSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white.withOpacity(0.08),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.16),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: _buildMainImage(),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainImage() {
    if (!_hasValidUrl) {
      return const _BannerFallback(
        icon: Icons.image_outlined,
        text: 'No image available',
      );
    }

    return Image.network(
      url!,
      fit: BoxFit.contain,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;

        return const Center(
          child: SizedBox(
            height: 28,
            width: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          ),
        );
      },
      errorBuilder: (context, _, __) {
        return const _BannerFallback(
          icon: Icons.broken_image_outlined,
          text: 'Image failed to load',
        );
      },
    );
  }
}

class _BannerFallback extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BannerFallback({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 38, color: Colors.white70),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerPatternBackground extends StatelessWidget {
  const _BannerPatternBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -30,
          left: -20,
          child: _GlowBubble(
            size: 120,
            color: Colors.white.withOpacity(0.12),
          ),
        ),
        Positioned(
          top: 10,
          right: -10,
          child: _GlowBubble(
            size: 90,
            color: Colors.cyanAccent.withOpacity(0.14),
          ),
        ),
        Positioned(
          bottom: -30,
          right: -10,
          child: _GlowBubble(
            size: 130,
            color: Colors.pinkAccent.withOpacity(0.14),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: _GlowBubble(
            size: 70,
            color: Colors.amber.withOpacity(0.10),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _BannerPatternPainter(),
          ),
        ),
      ],
    );
  }
}

class _GlowBubble extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowBubble({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0),
          ],
        ),
      ),
    );
  }
}

class _BannerPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    const spacing = 30.0;

    for (double x = -size.height; x < size.width + size.height; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        linePaint,
      );
    }

    final dotPaint = Paint()..color = Colors.white.withOpacity(0.06);

    for (double y = 16; y < size.height; y += 34) {
      for (double x = 16; x < size.width; x += 34) {
        canvas.drawCircle(Offset(x, y), 1.4, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color iconColor;

  const InfoPill({
    Key? key,
    required this.icon,
    required this.label,
    required this.bg,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF374151);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: fg,
              height: 1.1,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}