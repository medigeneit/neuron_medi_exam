import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'available_batch_card.dart';

class AvailableBatchItem {
  final String title;
  final String subTitle;
  final String startDate;
  final String days;
  final String time;
  final VoidCallback onDetails;

  const AvailableBatchItem({
    required this.title,
    required this.subTitle,
    required this.startDate,
    required this.days,
    required this.time,
    required this.onDetails,
  });
}

class AvailableBatchContainer extends StatefulWidget {
  final List<AvailableBatchItem> items;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color borderColor;
  final String title;
  final String? subtitle;

  const AvailableBatchContainer({
    Key? key,
    required this.items,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.borderColor = AppColor.primaryColor,
    this.title = 'Available Batches',
    this.subtitle,
  }) : super(key: key);

  @override
  State<AvailableBatchContainer> createState() => _AvailableBatchContainerState();
}

class _AvailableBatchContainerState extends State<AvailableBatchContainer> {
  final _controller = ScrollController();

  double _itemWidth = 0;
  double _spacing = 12;
  int _itemsPerViewport = 3;

  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted || !_controller.hasClients) return;
    final max = _controller.position.maxScrollExtent;
    final offset = _controller.offset;
    final p = max > 0 ? (offset / max).clamp(0.0, 1.0) : 0.0;
    if (p != _progress) setState(() => _progress = p);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 600;
      _itemsPerViewport = isMobile ? 2 : 3;
      _spacing = isMobile ? 12.0 : 16.0;

      final totalSpacing = _spacing * (_itemsPerViewport - 1);
      _itemWidth = (constraints.maxWidth - totalSpacing) / _itemsPerViewport;

      // trigger initial progress calc after first layout
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onScroll();
      });

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Modern container with gradient border effect
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF121212) : Colors.white,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.5) : Colors.grey.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColor.primaryColor.withOpacity(0.08),
                    AppColor.primaryColor.withOpacity(0.04),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(
                  color: AppColor.primaryColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              padding: widget.padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modern header with icon and count
                  Container(
                    padding: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.auto_awesome_rounded,
                              size: 18, color: AppColor.primaryColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: TextStyle(
                                  fontSize: Sizes.bodyText(context),
                                  fontWeight: FontWeight.w800,
                                  color: AppColor.primaryColor,
                                  height: 1.0,
                                ),
                              ),
                              if (widget.subtitle != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    widget.subtitle!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color?.withOpacity(.6),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (widget.items.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              // Handle "See All" action
                              debugPrint('See All Batches clicked');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColor.primaryColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'See All',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.primaryTextColor,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Carousel with improved styling
                  Scrollbar(
                    controller: _controller,
                    thumbVisibility: true,
                    trackVisibility: false,
                    thickness: 3,
                    radius: const Radius.circular(3),
                    interactive: true,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        controller: _controller,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            for (int i = 0; i < widget.items.length; i++) ...[
                              Container(
                                width: isMobile ? constraints.maxWidth * 0.65 : _itemWidth,
                                margin: EdgeInsets.only(right: i != widget.items.length - 1 ? _spacing : 0),
                                child: AvailableBatchCard(
                                  title: widget.items[i].title,
                                  subTitle: widget.items[i].subTitle,
                                  startDate: widget.items[i].startDate,
                                  days: widget.items[i].days,
                                  time: widget.items[i].time,
                                  onDetails: widget.items[i].onDetails,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Modern dot indicator instead of progress bar
                  if (widget.items.length > 1)
                    Center(
                      child: Wrap(
                        spacing: 6,
                        children: List.generate(widget.items.length, (index) {
                          final double activeSize = 8;
                          final double inactiveSize = 6;
                          final bool isActive = _progress >= index / (widget.items.length - 1) &&
                              _progress <= (index + 1) / (widget.items.length - 1);

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: isActive ? activeSize : inactiveSize,
                            height: isActive ? activeSize : inactiveSize,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColor.primaryColor
                                  : (isDark ? Colors.white : Colors.black).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}