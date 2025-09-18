import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:medi_exam/data/models/slide_items_model.dart';
import 'package:medi_exam/presentation/widgets/youtube_video_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:get/get.dart';
import 'package:medi_exam/presentation/utils/routes.dart';

class ImageSliderBanner extends StatefulWidget {
  final List<SlideItem> slideItems;
  final double height;
  final double borderRadius;
  final BoxFit fit;

  const ImageSliderBanner({
    Key? key,
    required this.slideItems,
    this.height = 200,
    this.borderRadius = 24,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  State<ImageSliderBanner> createState() => _ImageSliderBannerState();
}

class _ImageSliderBannerState extends State<ImageSliderBanner> {
  int _currentIndex = 0;


  final CarouselSliderController _carouselController = CarouselSliderController();

  List<SlideItem> _displayItems = [];

  @override
  void initState() {
    super.initState();
    _prepareDisplayItems();
  }

  @override
  void didUpdateWidget(covariant ImageSliderBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.slideItems, widget.slideItems)) {
      _prepareDisplayItems();
    }
  }

  void _prepareDisplayItems() {
    // 1) Filter base list: require thumb; for batch, require a target
    final base = <SlideItem>[];
    for (final item in widget.slideItems) {
      if (!item.hasValidThumb) continue;
      if (item.isBatchType && !item.hasAnyTarget) continue;
      base.add(item);
    }

    if (base.isEmpty) {
      setState(() => _displayItems = const <SlideItem>[]);
      return;
    }

    // 2) Collect repeating items (repeat_after > 0)
    final repeaters = base.where((it) => it.safeRepeatAfter > 0).toList();

    // A counter per repeater: how many items have passed since it last appeared
    // Initialize to 0 to enforce an initial delay of repeat_after after its first appearance.
    final counters = <int, int>{}; // key: logical id, value: ticks
    for (final r in repeaters) {
      counters[_keyOf(r)] = 0;
    }

    // 3) Build one "cycle":
    //    - Include each base item exactly once
    //    - After EVERY placed item, tick counters and insert any due repeats (priority desc)
    final result = <SlideItem>[];

    void _tickAndMaybeInsertRepeats() {
      if (repeaters.isEmpty) return;

      // Advance counters
      for (final r in repeaters) {
        final k = _keyOf(r);
        counters[k] = (counters[k] ?? 0) + 1;
      }

      // Collect all repeats that are due now
      final due = <SlideItem>[];
      for (final r in repeaters) {
        final k = _keyOf(r);
        if ((counters[k] ?? 0) >= r.safeRepeatAfter) {
          due.add(r);
        }
      }

      if (due.isEmpty) return;

      // Insert by priority (desc). If equal, keep stable order.
      due.sort((a, b) => b.safePriority.compareTo(a.safePriority));

      for (final r in due) {
        result.add(r);
        counters[_keyOf(r)] = 0; // reset the one we just inserted
      }
    }

    for (final item in base) {
      // Place the base item once
      result.add(item);

      // If this base item is itself a repeater, its appearance resets its counter
      if (item.safeRepeatAfter > 0) {
        counters[_keyOf(item)] = 0;
      }

      // After every placement, tick time and insert any due repeats
      _tickAndMaybeInsertRepeats();
    }

    setState(() => _displayItems = result);
  }

  // Prefer stable key (id) when present
  int _keyOf(SlideItem item) => item.hasValidId ? item.id! : item.hashCode;

  bool get _isDesktopLike {
    if (kIsWeb) return true;
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return true;
      default:
        return false;
    }
  }

  Future<void> _openExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the link')),
      );
    }
  }

  void _handleItemTap(SlideItem item) async {
    final type = item.safeLinkType;

    // Batch route
    if (type == 'batch_type') {
      final batchId = item.safeBatchId;
      final coursePackageId = item.safeCoursePackageId;

      if (batchId <= 0 && coursePackageId <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Batch details not available')),
        );
        return;
      }

      Get.toNamed(
        RouteNames.batchDetails,
        arguments: {
          'batchId': batchId.toString(),
          'coursePackageId': coursePackageId.toString(),
          'imageUrl': item.safeThumb,
          'title': item.safeTitle,
        },
      );
      return;
    }

    // Video link
    if (type == 'video_link') {
      final link = item.safeLink;
      final videoId = _extractYouTubeId(link);

      if (!_isDesktopLike && videoId != null) {
        _showYouTubeDialog(item, videoId);
        return;
      }

      if (link.isNotEmpty) {
        await _openExternal(link);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video link is unavailable')),
        );
      }
      return;
    }

    // Web link
    if (type == 'web_link') {
      final link = item.safeLink;
      if (link.isNotEmpty) {
        await _openExternal(link);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link is unavailable')),
        );
      }
      return;
    }
  }

  void _showYouTubeDialog(SlideItem item, String videoId) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => YouTubeVideoDialog(
        videoId: videoId,
        title: item.hasValidTitle ? item.safeTitle : null,
      ),
    );
  }

  String? _extractYouTubeId(String url) {
    final id = YoutubePlayer.convertUrlToId(url);
    return (id != null && id.isNotEmpty) ? id : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    final height = isMobile ? widget.height * 0.8 : widget.height;

    if (_displayItems.isEmpty) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          color: isDark ? Colors.grey[800] : Colors.grey[200],
        ),
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            color: isDark ? Colors.white70 : Colors.grey[500],
            size: 40,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          // Main Carousel
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.6) : Colors.grey.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: CarouselSlider.builder(
                carouselController: _carouselController, // ✅ correct controller
                itemCount: _displayItems.length,
                options: CarouselOptions(
                  height: height,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  enlargeStrategy: CenterPageEnlargeStrategy.height,
                  aspectRatio: 16 / 9,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: true,
                  autoPlayInterval: const Duration(seconds: 5),
                  autoPlayAnimationDuration: const Duration(milliseconds: 1000),
                  viewportFraction: isMobile ? 0.92 : 0.87,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                itemBuilder: (context, index, realIndex) {
                  final item = _displayItems[index];
                  final isVideo = item.safeLinkType == 'video_link';
                  final isBatch = item.safeLinkType == 'batch_type';

                  return GestureDetector(
                    onTap: () => _handleItemTap(item),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                        child: Stack(
                          children: [
                            // Image
                            Image.network(
                              item.safeThumb,
                              width: double.infinity,
                              height: double.infinity,
                              fit: widget.fit,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(widget.borderRadius),
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                          : null,
                                      color: AppColor.primaryColor,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(widget.borderRadius),
                                  ),
                                  child: Icon(
                                    Icons.error_outline,
                                    color: isDark ? Colors.white70 : Colors.grey[500],
                                    size: 40,
                                  ),
                                );
                              },
                            ),

                            // Gradient overlay
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(widget.borderRadius),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                            ),

                            // Play overlay for videos
                            if (isVideo)
                              Positioned.fill(
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),

                            // Badge for batch type
                            if (isBatch)
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.45),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.auto_awesome_mosaic, color: Colors.white, size: 14),
                                      SizedBox(width: 6),
                                      Text(
                                        'Batch',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // Caption
                            if (item.hasValidTitle)
                              Positioned(
                                left: 20,
                                right: 20,
                                bottom: 24,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    item.safeTitle,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isMobile ? 16 : 18,
                                      fontWeight: FontWeight.w600,
                                      height: 1.2,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Dot indicators
// Dot indicators (responsive: single row when fits, wrap when not)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = MediaQuery.of(context).size.width < 600;

                // Sizes tuned for small vs large screens
                final double dotHeight = isMobile ? 6 : 8;
                final double dotWidth = isMobile ? 6 : 8;
                final double activeDotWidth = isMobile ? 16 : 24;
                const double spacing = 4;

                // Build all indicators once
                final indicators = List<Widget>.generate(_displayItems.length, (i) {
                  final bool isActive = _currentIndex == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isActive ? activeDotWidth : dotWidth,
                    height: dotHeight,
                    margin: const EdgeInsets.symmetric(horizontal: spacing / 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(dotHeight / 2),
                      color: isActive ? AppColor.primaryColor : Colors.grey[400],
                    ),
                  );
                });

                // Quick width estimate to decide if we can keep a single Row
                final int count = indicators.length;
                final estimatedWidth = (count - 1) * spacing +
                    // assume one active and rest normal (rough but safe)
                    activeDotWidth + (count - 1) * dotWidth;

                if (estimatedWidth <= constraints.maxWidth) {
                  // Fits in one line → center Row
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: indicators,
                  );
                }

                // Doesn’t fit → Wrap across multiple lines, centered
                return Wrap(
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  spacing: spacing,
                  runSpacing: spacing,
                  children: indicators,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
