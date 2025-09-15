import 'package:flutter/material.dart';
import 'package:medi_exam/data/models/course_session_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/widgets/helpers/banner_card_helpers.dart';
import 'package:medi_exam/presentation/widgets/date_formatter_widget.dart';

class AvailableBannerCard extends StatefulWidget {
  final Batch batch;
  final VoidCallback onDetails;

  const AvailableBannerCard({
    Key? key,
    required this.batch,
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
                              child: BannerImage(url: widget.batch.safeBannerUrl),
                            ),

/*                            // Batch ID ribbon
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'ID: ${widget.batch.safeId}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),*/

/*                            // Schedule indicator
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.schedule_rounded,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.batch.safeExamTime,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),*/
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
                                widget.batch.safeName,
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
                                'Starts: ${formatDateStr(widget.batch.formattedStartDate)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Schedule summary
                              if (widget.batch.scheduleSummary.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text(
                                    widget.batch.scheduleSummary,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: gradientColors[0],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 8),

                              // Info chips - Using Wrap for dynamic wrapping


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
                                                'View Details',
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