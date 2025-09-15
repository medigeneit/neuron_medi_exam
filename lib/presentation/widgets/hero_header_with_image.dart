import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/widgets/date_formatter_widget.dart';
import 'package:medi_exam/presentation/widgets/helpers/banner_card_helpers.dart';

/// Collapsible header with banner or gradient blob background + glass info card
class HeroHeader extends StatelessWidget {
  final String banner;
  final String headerTitle;
  final String headerSubtitle;
  final String time;
  final String days;
  final String startDate;

  const HeroHeader({
    required this.banner,
    required this.headerTitle,
    required this.headerSubtitle,
    required this.time,
    required this.days,
    required this.startDate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (banner.isNotEmpty)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: BannerImage(url: banner),
          )
        else
        // gradient blob background
          _BlobBackground(),

        // scrim for contrast
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.15),
                  Colors.black.withOpacity(isDark ? 0.40 : 0.35),
                  Colors.black.withOpacity(isDark ? 0.65 : 0.55),
                ],
              ),
            ),
          ),
        ),

        // Glass card with title/subtitle + meta chips
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 9.0, sigmaY: 9.0),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      headerTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20.5,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    if (headerSubtitle.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      const _SubtleSubtitle(),
                      Text(
                        headerSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (time.isNotEmpty) _GlassChip(label: time),
                        if (days.isNotEmpty) _GlassChip(label: days),
                        if (startDate.isNotEmpty)
                          _GlassChip(label: 'Starts ${formatDateStr(startDate)}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SubtleSubtitle extends StatelessWidget {
  const _SubtleSubtitle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 2,
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: Colors.white.withOpacity(0.35),
      ),
    );
  }
}

/// Simple painted blob gradient background (no extra packages)
class _BlobBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        gradient: LinearGradient(
          colors: [AppColor.indigo, AppColor.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // soft radial “blob” lights
          Positioned(
            left: -60,
            top: -30,
            child: _RadialBlob(color: Colors.white, opacity: 0.12, size: 240),
          ),
          Positioned(
            right: -30,
            bottom: -40,
            child: _RadialBlob(color: Colors.white, opacity: 0.10, size: 200),
          ),
        ],
      ),
    );
  }
}

class _RadialBlob extends StatelessWidget {
  final Color color;
  final double opacity;
  final double size;

  const _RadialBlob({
    required this.color,
    required this.opacity,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(opacity),
              blurRadius: size * 0.6,
              spreadRadius: size * 0.20,
            ),
          ],
        ),
      ),
    );
  }
}


class _GlassChip extends StatelessWidget {
  final String label;
  const _GlassChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.25),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.white, // stays readable
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}