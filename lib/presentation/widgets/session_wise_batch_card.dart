import 'package:flutter/material.dart';
import 'package:medi_exam/data/models/course_session_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/widgets/date_formatter_widget.dart';

class SessionWiseBatchCard extends StatefulWidget {
  final Batch batch;
  final VoidCallback? onDetails;

  const SessionWiseBatchCard({
    Key? key,
    required this.batch,
    this.onDetails,
  }) : super(key: key);

  @override
  State<SessionWiseBatchCard> createState() => _SessionWiseBatchCardState();
}

class _SessionWiseBatchCardState extends State<SessionWiseBatchCard> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    // Compact type scales for mobile
    final titleSize = isMobile ? 16.0 : 18.0;
    final subTitleSize = isMobile ? 12.5 : 14.0;
    final infoSize = isMobile ? 11.0 : 12.0;

    // Modern gradient colors
    final gradientColors = [AppColor.indigo, AppColor.purple]; // Indigo to purple

    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: _pressed ? 0.98 : (_hovered ? 1.01 : 1.0),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(1.5),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(19),
              child: Stack(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(19),
                    onTap: widget.onDetails,
                    onHighlightChanged: (v) => setState(() => _pressed = v),
                    onHover: (v) => setState(() => _hovered = v),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 14 : 16,
                        vertical: isMobile ? 12 : 14,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title & subtitle with improved hierarchy
                          Text(
                            widget.batch.safeName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              color: AppColor.primaryTextColor,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Divider with gradient
                          Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  gradientColors[0].withOpacity(0.1),
                                  gradientColors[0].withOpacity(0.3),
                                  gradientColors[0].withOpacity(0.1),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Chips row (compact & scannable)
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              if (widget.batch.hasValidStartDate)
                                _InfoChip(
                                  icon: Icons.calendar_today_rounded,
                                  title: 'Start: ',
                                  label: formatDateStr(widget.batch.formattedStartDate),
                                  fontSize: infoSize,
                                  bg: isDark ? const Color(0xFF2D2F33) : const Color(0xFFF0F7FF),
                                  iconColor: gradientColors[0],
                                ),
                              if (widget.batch.hasValidExamDays)
                                _InfoChip(
                                  icon: Icons.event_repeat_rounded,
                                  title: 'Days: ',
                                  label: widget.batch.safeExamDays,
                                  fontSize: infoSize,
                                  bg: isDark ? const Color(0xFF2D2F33) : const Color(0xFFF0F7FF),
                                  iconColor: gradientColors[0],
                                ),
                              if (widget.batch.hasValidExamTime)
                                _InfoChip(
                                  icon: Icons.schedule_rounded,
                                  title: 'Time: ',
                                  label: widget.batch.safeExamTime,
                                  fontSize: infoSize,
                                  bg: isDark ? const Color(0xFF2D2F33) : const Color(0xFFF0F7FF),
                                  iconColor: gradientColors[0],
                                ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // CTA with modern gradient
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
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: gradientColors[0].withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: widget.onDetails,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 14 : 16,
                                        vertical: isMobile ? 8 : 10,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Details',
                                            style: TextStyle(
                                              fontSize: isMobile ? 13 : 14,
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
                          )
                        ],
                      ),
                    ),
                  ),

/*                  // Banner availability indicator
                  if (widget.batch.hasValidBannerUrl)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.image_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Banner',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),*/
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String label;
  final double fontSize;
  final Color bg;
  final Color iconColor;

  const _InfoChip({
    Key? key,
    required this.icon,
    required this.title,
    required this.label,
    required this.fontSize,
    required this.bg,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF374151);

// Wrap the chip so it has a reasonable max width (so text can wrap)
    return ConstrainedBox(
      constraints: BoxConstraints(
        // tune this if you want wider/narrower chips
        maxWidth: MediaQuery.of(context).size.width * 0.8,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          // <-- let the row use the available width
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start, // nicer when label wraps
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 6),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                color: fg,
                height: 1.1,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            // <-- make the label flexible so it can wrap onto line 2
            Flexible(
              child: Text(
                label,
                maxLines: 2,            // allow two lines
                softWrap: true,         // enable wrapping
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: fontSize,
                  color: fg,
                  height: 1.1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}