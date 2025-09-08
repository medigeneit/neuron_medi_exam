import 'package:flutter/material.dart';
import 'package:medi_exam/data/models/courses_model.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/available_course_card_widget.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/widgets/show_disciplne_dialog.dart';

class AvailableCourseContainerWidget extends StatefulWidget {
  final String title;
  final CoursesModel batchCourses;
  final bool isBatch;

  const AvailableCourseContainerWidget({
    Key? key,
    required this.title,
    required this.batchCourses,
    required this.isBatch,
  }) : super(key: key);

  @override
  State<AvailableCourseContainerWidget> createState() =>
      _AvailableCourseContainerWidgetState();
}

class _AvailableCourseContainerWidgetState
    extends State<AvailableCourseContainerWidget>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  final int _initialItemCount = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(20);

    final gradientStroke = widget.isBatch ? AppColor.primaryGradient : AppColor.secondaryGradient;

    final textColor = const Color(0xFF111827);

    // Get courses from batchCourses
    final courses = widget.batchCourses.courses ?? [];
    final displayedCourses = _isExpanded
        ? courses
        : courses.take(_initialItemCount).toList();

    return Semantics(
      container: true,
      label: '${widget.title} section',
      child: DecoratedBox(
        // outer gradient border
        decoration: BoxDecoration(
          gradient: gradientStroke.withOpacity(0.5),
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(1.6), // border thickness
          decoration: BoxDecoration(
            gradient: gradientStroke,
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Material(
            type: MaterialType.card,
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header
                  _Header(
                    title: widget.title,
                    count: courses.length,
                    textColor: textColor,
                    isBatch: widget.isBatch,
                  ),

                  const SizedBox(height: 12),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.black.withOpacity(0.04),
                  ),
                  const SizedBox(height: 12),

                  // Responsive grid + animated height for expand/collapse
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = _crossAxisCountForWidth(constraints.maxWidth);
                      final childAspectRatio = _childAspectRatioForWidth(constraints.maxWidth);

                      // Calculate the actual number of items to display
                      final itemCount = displayedCourses.length;

                      return AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.topCenter,
                        child: itemCount == 1
                            ? Center(
                          child: AvailableCourseCardWidget(
                            icon: Icons.school_rounded,
                            title: displayedCourses[0].courseName ?? 'Unknown Course',
                            onTap: () => showDisciplineDialog(
                              context,
                              displayedCourses[0].courseName ?? 'Unknown Course',
                              Icons.school_rounded,
                              widget.isBatch,
                              displayedCourses[0].package ?? [],
                            ),
                            isBatch: widget.isBatch,
                          ),
                        )
                            : GridView.builder(
                          itemCount: itemCount,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: childAspectRatio,
                          ),
                          itemBuilder: (context, i) {
                            final course = displayedCourses[i];
                            return AvailableCourseCardWidget(
                              icon: Icons.school_rounded,
                              title: course.courseName ?? 'Unknown Course',
                              onTap: () => showDisciplineDialog(
                                context,
                                course.courseName ?? 'Unknown Course',
                                Icons.school_rounded,
                                widget.isBatch,
                                course.package ?? [],
                              ),
                              isBatch: widget.isBatch,
                            );
                          },
                        ),
                      );
                    },
                  ),
                  // Toggle button (shown only when needed)
                  if (courses.length > _initialItemCount) ...[
                    const SizedBox(height: 8),
                    _ShowMoreButton(
                      expanded: _isExpanded,
                      onPressed: () =>
                          setState(() => _isExpanded = !_isExpanded),
                    ),
                  ],

                  // Empty state
                  if (courses.isEmpty) ...[
                    const SizedBox(height: 8),
                    Opacity(
                      opacity: 0.7,
                      child: Text(
                        'No courses available right now.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  int _crossAxisCountForWidth(double w) {
    if (w >= 1000) return 4;
    if (w >= 760) return 3;
    return 3; // phones
  }

  double _childAspectRatioForWidth(double w) {
    // Slightly taller on narrow screens
    if (w < 360) return 0.80;
    if (w < 760) return 0.95;
    return 1.05;
  }

}

/// Header with title, count badge, and animated toggle button.
class _Header extends StatelessWidget {
  final String title;
  final int count;
  final Color textColor;
  final bool isBatch;

  const _Header({
    required this.title,
    required this.count,
    required this.textColor,
    required this.isBatch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: Sizes.bodyText(context),
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _CountBadge(count: count, isBatch: isBatch),
            ],
          ),
        ),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final bool isBatch;
  const _CountBadge({required this.count, required this.isBatch});

  @override
  Widget build(BuildContext context) {
    final gradient = isBatch ? AppColor.primaryGradient : AppColor.secondaryGradient;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

class _HeaderToggleButton extends StatefulWidget {
  final bool expanded;
  final VoidCallback onPressed;
  const _HeaderToggleButton({
    required this.expanded,
    required this.onPressed,
  });

  @override
  State<_HeaderToggleButton> createState() => _HeaderToggleButtonState();
}

class _HeaderToggleButtonState extends State<_HeaderToggleButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final label = widget.expanded ? 'Show Less' : 'Show More';

    return TextButton.icon(
      onPressed: widget.onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onHover: (h) => setState(() => _hovered = h),
      icon: AnimatedRotation(
        turns: widget.expanded ? 0.5 : 0.0, // rotate arrow on expand
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 22,
          color: Colors.black.withOpacity(_hovered ? 0.8 : 0.6),
        ),
      ),
      label: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: Text(
          key: ValueKey(label),
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}


/// Centered Show More/Less button for small screens (optional)
class _ShowMoreButton extends StatelessWidget {
  final bool expanded;
  final VoidCallback onPressed;

  const _ShowMoreButton({
    required this.expanded,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = expanded ? 'Show Less' : 'Show More';

    return Align(
      alignment: Alignment.center,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Text(
                key: ValueKey(label),
                label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 6),
            AnimatedRotation(
              duration: const Duration(milliseconds: 180),
              turns: expanded ? 0.5 : 0.0,
              child: const Icon(Icons.expand_more_rounded, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
