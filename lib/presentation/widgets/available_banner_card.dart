import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/widgets/banner_card_helpers.dart';

class AvailableBannerCard extends StatefulWidget {
  final String title;
  final String subTitle;
  final String startDate;
  final String days;
  final String time;
  final String? price;
  final String? discount;
  final String? imageUrl;
  final VoidCallback onDetails;

  const AvailableBannerCard({
    Key? key,
    required this.title,
    required this.subTitle,
    required this.startDate,
    required this.days,
    required this.time,
    this.price,
    this.discount,
    this.imageUrl,
    required this.onDetails,
  }) : super(key: key);

  @override
  State<AvailableBannerCard> createState() => _AvailableBannerCardState();
}

class _AvailableBannerCardState extends State<AvailableBannerCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gradientColors = [AppColor.indigo, AppColor.purple];
    const double borderRadius = 16;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate dynamic height based on content
        final double maxWidth = constraints.maxWidth;
        final double imageHeight = maxWidth * 0.4; // 40% of card width for image

        return AnimatedScale(
          duration: const Duration(milliseconds: 120),
          scale: _pressed ? 0.98 : 1.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius + 2),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
            padding: const EdgeInsets.all(1.5),
            child: Material(
              color: isDark ? const Color(0xFF121416) : Colors.white,
              borderRadius: BorderRadius.circular(borderRadius),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: widget.onDetails,
                onHighlightChanged: (v) => setState(() => _pressed = v),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top image section (fixed aspect ratio)
                      Container(
                        height: imageHeight,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(borderRadius),
                            topRight: Radius.circular(borderRadius),
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Background image
                            Positioned.fill(
                              child: BannerImage(url: widget.imageUrl),
                            ),

                            // Discount ribbon
                            if (widget.discount != null && widget.discount!.trim().isNotEmpty)
                              Positioned(
                                top: 8,
                                right: -20,
                                child: Transform.rotate(
                                  angle: 0.785,
                                  child: Container(
                                    width: 86,
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: widget.discount!.toLowerCase() == 'free'
                                            ? [Colors.green.shade500, Colors.green.shade700]
                                            : [Colors.orange.shade500, Colors.orange.shade700],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.25),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (widget.discount!.toLowerCase() == 'free')
                                          const Icon(Icons.celebration_rounded, size: 10, color: Colors.white),
                                        if (widget.discount!.toLowerCase() == 'free') const SizedBox(width: 4),
                                        Text(
                                          widget.discount!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 10,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Bottom content section (dynamic height)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title and subtitle
                              Text(
                                widget.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : AppColor.primaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.subTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Price if available
                              if (widget.price != null && widget.price!.trim().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text(
                                    widget.price!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: gradientColors[0],
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 8),

                              // Info chips - Using Wrap for dynamic wrapping
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  InfoPill(
                                    icon: Icons.calendar_today_rounded,
                                    label: 'Start: ${widget.startDate}',
                                    bg: isDark ? const Color(0xFF2D2F33) : const Color(0xFFF0F7FF),
                                    iconColor: gradientColors[0],
                                  ),
                                  InfoPill(
                                    icon: Icons.event_repeat_rounded,
                                    label: 'Days: ${widget.days}',
                                    bg: isDark ? const Color(0xFF2D2F33) : const Color(0xFFF0F7FF),
                                    iconColor: gradientColors[0],
                                  ),
                                  InfoPill(
                                    icon: Icons.schedule_rounded,
                                    label: 'Time: ${widget.time}',
                                    bg: isDark ? const Color(0xFF2D2F33) : const Color(0xFFF0F7FF),
                                    iconColor: gradientColors[0],
                                  ),
                                ],
                              ),

                              const Spacer(),

                              // CTA button
                              Row(
                                children: [
                                  const Spacer(),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: gradientColors,
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: gradientColors[0].withOpacity(0.4),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        onTap: widget.onDetails,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Details',
                                                style: TextStyle(
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              const Icon(
                                                Icons.arrow_forward_rounded,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}