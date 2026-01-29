import 'package:flutter/material.dart';
import 'package:medi_exam/data/models/courses_model.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/animated_text_widget.dart';
import 'package:medi_exam/presentation/widgets/available_course_card_widget.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/widgets/show_disciplne_dialog.dart';

class AvailableCourseContainerWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final CoursesModel batchCourses;
  final bool isBatch;

  // ✅ show "Free Exam" diagonal ribbon tag
  final bool showFreeExamRibbon;

  final void Function({
  required bool isBatch,
  required String courseTitle,
  required IconData icon,
  required Package package,
  }) onPackagePicked;

  const AvailableCourseContainerWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.batchCourses,
    required this.isBatch,
    required this.onPackagePicked,
    this.showFreeExamRibbon = false,
  });

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

    final gradientStroke =
    widget.isBatch ? AppColor.primaryGradient : AppColor.secondaryGradient;

    final textColor =
    widget.isBatch ? AppColor.purpleDark : AppColor.primaryColor;

    final courses = widget.batchCourses.courses ?? [];
    final displayedCourses =
    _isExpanded ? courses : courses.take(_initialItemCount).toList();

    return Semantics(
      container: true,
      label: '${widget.title} section',
      child: ClipRRect(
        borderRadius: radius, // ✅ clip everything, including the ribbon
        child: Stack(
          clipBehavior: Clip.hardEdge, // ✅ enforce clipping inside rounded rect
          children: [
            DecoratedBox(
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
                margin: const EdgeInsets.all(1.6),
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
                        _Header(
                          title: widget.title,
                          subtitle: widget.subtitle,
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
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount =
                            _crossAxisCountForWidth(constraints.maxWidth);
                            final childAspectRatio =
                            _childAspectRatioForWidth(constraints.maxWidth);

                            final itemCount = displayedCourses.length;

                            return AnimatedSize(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              alignment: Alignment.topCenter,
                              child: itemCount == 1
                                  ? Center(
                                child: AvailableCourseCardWidget(
                                  icon: Icons.school_rounded,
                                  title: displayedCourses[0].courseName ??
                                      'Unknown Course',
                                  onTap: () {
                                    final course = displayedCourses[0];
                                    showDisciplineDialog(
                                      context,
                                      courseTitle: course.courseName ??
                                          'Unknown Course',
                                      courseIcon: Icons.school_rounded,
                                      isBatch: widget.isBatch,
                                      packages: course.package ?? [],
                                      onPicked: (pickedPackage) {
                                        widget.onPackagePicked(
                                          isBatch: widget.isBatch,
                                          courseTitle: course.courseName ??
                                              'Unknown Course',
                                          icon: Icons.school_rounded,
                                          package: pickedPackage,
                                        );
                                      },
                                    );
                                  },
                                  isBatch: widget.isBatch,
                                ),
                              )
                                  : GridView.builder(
                                itemCount: itemCount,
                                shrinkWrap: true,
                                physics:
                                const NeverScrollableScrollPhysics(),
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
                                    icon: Icons.school_rounded,
                                    title: course.courseName ??
                                        'Unknown Course',
                                    onTap: () {
                                      showDisciplineDialog(
                                        context,
                                        courseTitle: course.courseName ??
                                            'Unknown Course',
                                        courseIcon: Icons.school_rounded,
                                        isBatch: widget.isBatch,
                                        packages: course.package ?? [],
                                        onPicked: (pickedPackage) {
                                          widget.onPackagePicked(
                                            isBatch: widget.isBatch,
                                            courseTitle:
                                            course.courseName ??
                                                'Unknown Course',
                                            icon: Icons.school_rounded,
                                            package: pickedPackage,
                                          );
                                        },
                                      );
                                    },
                                    isBatch: widget.isBatch,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        if (courses.length > _initialItemCount) ...[
                          const SizedBox(height: 8),
                          _ShowMoreButton(
                            expanded: _isExpanded,
                            onPressed: () =>
                                setState(() => _isExpanded = !_isExpanded),
                          ),
                        ],
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

            // ✅ Ribbon is now clipped & stays inside the card
            if (widget.showFreeExamRibbon)
              const Positioned(
                top: 18,
                right: -28,
                child: _DiagonalRibbon(text: 'FREE EXAM'),
              ),
          ],
        ),
      ),
    );
  }

  int _crossAxisCountForWidth(double w) {
    if (w >= 1000) return 4;
    if (w >= 760) return 3;
    return 3;
  }

  double _childAspectRatioForWidth(double w) {
    if (w < 360) return 0.80;
    if (w < 760) return 0.95;
    return 1.05;
  }
}

/// ✅ Diagonal ribbon (fits inside clipped container)
class _DiagonalRibbon extends StatefulWidget {
  final String text;

  const _DiagonalRibbon({required this.text});

  @override
  State<_DiagonalRibbon> createState() => _DiagonalRibbonState();
}

class _DiagonalRibbonState extends State<_DiagonalRibbon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late final Animation<double> _pulse;
  late final Animation<double> _wiggle;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.92, end: 1.10).animate(
      CurvedAnimation(parent: _ctl, curve: Curves.easeInOut),
    );

    _wiggle = Tween<double>(begin: -0.06, end: 0.06).animate(
      CurvedAnimation(parent: _ctl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grad = AppColor.secondaryGradient;
    final Color shadowBase =
    (grad is LinearGradient ? grad.colors.first : Colors.black);

    return Transform.rotate(
      angle: 0.72,
      child: Container(
        width: 136,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: grad,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: shadowBase.withOpacity(0.22),
              blurRadius: 12,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ Animated Icon (pulse + glow + tiny wiggle)
            AnimatedBuilder(
              animation: _ctl,
              builder: (_, __) {
                final glow = 2.0 + (6.0 * _ctl.value);
                final glowOpacity = 0.25 + (0.35 * _ctl.value);

                return Transform.rotate(
                  angle: _wiggle.value,
                  child: Transform.scale(
                    scale: _pulse.value,
                    child: Icon(
                      Icons.local_fire_department,
                      size: Sizes.extraSmallIcon(context),
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.redAccent.withOpacity(glowOpacity),
                          blurRadius: glow,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(width: 4),

            // Your AnimatedText (kept)
            AnimatedText(
              text: widget.text,
              color: AppColor.primaryColor,
              animationType: AnimationType.colorShift,
              colorPalette: const [
                AppColor.whiteColor,
                Colors.yellow,
                AppColor.whiteColor,
              ],
              duration: const Duration(seconds: 2),
              fontSize: Sizes.extraSmallText(context),
              fontWeight: FontWeight.w600,
              letterSpacing: .6,
            ),
          ],
        ),
      ),
    );
  }
}


/// Header with title, count badge, and animated subtitle.
class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final int count;
  final Color textColor;
  final bool isBatch;

  const _Header({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.textColor,
    required this.isBatch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
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
                        color: AppColor.midnightBlue,
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
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          child: AnimatedText(
            text: subtitle,
            color: AppColor.primaryColor,
            animationType: AnimationType.colorShift,
            colorPalette: [
              Colors.grey.shade400,
              AppColor.indigoDark,
              AppColor.indigo,
              AppColor.purple,
              AppColor.purpleDark,
              Colors.grey.shade600,
            ],
            duration: const Duration(seconds: 2),
            fontSize: Sizes.smallText(context),
            fontWeight: FontWeight.normal,
            letterSpacing: -0.2,
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
    final gradient =
    isBatch ? AppColor.primaryGradient : AppColor.secondaryGradient;
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

/// Centered Show More/Less button
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
