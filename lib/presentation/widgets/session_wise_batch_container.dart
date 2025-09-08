import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/models/course_session_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'session_wise_batch_card.dart';

class SessionWiseBatchContainer extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool isBatch;
  final List<Batch> batches;
  final VoidCallback onTapShowAllBatches;
  final Function(Batch) onTapBatch;
  final EdgeInsets padding;
  final double borderRadius;
  final Color borderColor;

  const SessionWiseBatchContainer({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.isBatch,
    required this.batches,
    required this.onTapShowAllBatches,
    required this.onTapBatch,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 12,
    this.borderColor = Colors.transparent,
  }) : super(key: key);

  @override
  State<SessionWiseBatchContainer> createState() => _SessionWiseBatchContainerState();
}

class _SessionWiseBatchContainerState extends State<SessionWiseBatchContainer> {
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                gradient: widget.isBatch ? AppColor.primaryGradient.withOpacity(0.06) : AppColor.secondaryGradient.withOpacity(0.06),
                border: Border.all(
                  color: widget.isBatch ? AppColor.primaryColor.withOpacity(0.2) : AppColor.purple.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              padding: widget.padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modern header with icon and count
                  Container(
                    padding: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black.withOpacity(0.08),
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
                              size: 18, color: widget.isBatch ? AppColor.primaryColor : AppColor.purple),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: TextStyle(
                                  fontSize: Sizes.subTitleText(context),
                                  fontWeight: FontWeight.w800,
                                  color: widget.isBatch ? AppColor.primaryColor : AppColor.purple,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.subtitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.batches.isNotEmpty)
                          GestureDetector(
                            onTap: widget.onTapShowAllBatches,
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

                  const SizedBox(height: 12),

                  // Carousel with improved styling
                  if (widget.batches.isEmpty)
                    _buildEmptyBatches()
                  else
                    Scrollbar(
                      controller: _controller,
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
                              for (int i = 0; i < widget.batches.length; i++) ...[
                                Container(
                                  width: isMobile ? constraints.maxWidth * 0.65 : _itemWidth,
                                  margin: EdgeInsets.only(right: i != widget.batches.length - 1 ? _spacing : 0),
                                  child: SessionWiseBatchCard(
                                    batch: widget.batches[i],
                                    onDetails: () {
                                      widget.onTapBatch(widget.batches[i]);
                                    },
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
                  if (widget.batches.length > 1)
                    Center(
                      child: Wrap(
                        spacing: 6,
                        children: List.generate(widget.batches.length, (index) {
                          final bool isActive = _progress >= index / (widget.batches.length - 1) &&
                              _progress <= (index + 1) / (widget.batches.length - 1);

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: isActive ? 16 : 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: isActive
                                  ? AppColor.primaryColor
                                  : Colors.grey[400],
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

  Widget _buildEmptyBatches() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'No batches available',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Check back later for new batches',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}