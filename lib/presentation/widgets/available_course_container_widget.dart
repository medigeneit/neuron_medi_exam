import 'package:flutter/material.dart';
import 'package:medi_exam/data/models/course_item.dart';
import 'package:medi_exam/data/models/discipline_faculty.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/available_course_card_widget.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/widgets/discipline_faculty_picker_dialog.dart';

class AvailableCourseContainerWidget extends StatefulWidget {
  final String title;
  final List<CourseItem> courses;
  final bool isBatch;

  const AvailableCourseContainerWidget({
    Key? key,
    required this.title,
    required this.courses,
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

    // Determine which courses to show
    final displayedCourses = _isExpanded
        ? widget.courses
        : widget.courses.take(_initialItemCount).toList();

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
                    count: widget.courses.length,
                    textColor: textColor,
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
                      final crossAxisCount =
                      _crossAxisCountForWidth(constraints.maxWidth);
                      // approximate square-ish cards
                      final childAspectRatio =
                      _childAspectRatioForWidth(constraints.maxWidth);

                      return AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.topCenter,
                        child: GridView.builder(
                          itemCount: displayedCourses.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: childAspectRatio,
                          ),
                          itemBuilder: (context, i) {
                            final course = displayedCourses[i];
                            return AvailableCourseCardWidget(
                              icon: course.icon,
                              title: course.title,
                              onTap: () => _showDisciplineDialog(context, course.title, course.icon, widget.isBatch),
                              isBatch: widget.isBatch,
                            );
                          },
                        ),
                      );
                    },
                  ),

                  // Toggle button (shown only when needed)
                  if (widget.courses.length > _initialItemCount) ...[
                    const SizedBox(height: 8),
                    _ShowMoreButton(
                      expanded: _isExpanded,
                      onPressed: () =>
                          setState(() => _isExpanded = !_isExpanded),
                    ),
                  ],

                  // Empty state
                  if (widget.courses.isEmpty) ...[
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


  const _Header({
    required this.title,
    required this.count,
    required this.textColor,

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
                    fontSize: Sizes.subTitleText(context),
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _CountBadge(count: count),
            ],
          ),
        ),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final gradient = AppColor.primaryGradient;
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

void _showDisciplineDialog(BuildContext context, String courseTitle, IconData courseIcon, bool isBatch) {
  final faculties = _facultiesForCourse(courseTitle);

  showDisciplineFacultyPickerDialog(
    context,
    title: courseTitle, // title based on the course.title
    subtitle: 'Select a discipline to proceed.',
    icon: courseIcon,
    isBatch: isBatch,
    faculties: faculties,
    onSelected: (picked) {
      // TODO: Navigate or trigger action with the selected faculty
      // e.g., Navigator.pushNamed(context, Routes.facultyDetails, arguments: picked);
      debugPrint('Selected: ${picked.title} from $courseTitle');
    },
  );
}

/// Map course -> faculties (extend as you add more datasets)
List<DisciplineFaculty> _facultiesForCourse(String title) {
  final t = title.toLowerCase();

  if (t.contains('residency')) {
    return demoResidencyFaculties;
  }

  // Fallback for other course types (until you add more lists)
  // You can return an empty list to show an empty state in the dialog,
  // or re-use residency as placeholder.
  return demoResidencyFaculties;
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
