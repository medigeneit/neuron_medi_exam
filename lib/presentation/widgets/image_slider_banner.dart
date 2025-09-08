import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:medi_exam/data/models/slide_items_model.dart';
import 'package:medi_exam/presentation/widgets/youtube_video_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:medi_exam/presentation/utils/app_colors.dart';
// Assume you have a SlideItem with fields/safe getters used below.

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

  void _prepareDisplayItems() {
    _displayItems = [];

    for (final item in widget.slideItems) {
      if (item.isValidForDisplay) {
        _displayItems.add(item);

        final repeatAfter = item.repeatAfter ?? 0;
        if (repeatAfter > 0) {
          for (int i = 0; i < repeatAfter; i++) {
            _displayItems.add(item);
          }
        }
      }
    }
  }

  void _handleItemTap(SlideItem item) async {
    final linkType = item.safeLinkType;
    final link = item.safeLink;

    if (linkType == 'video_link') {
      _showYouTubeDialog(item);
    } else if (linkType == 'web_link') {
      final uri = Uri.tryParse(link);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  void _showYouTubeDialog(SlideItem item) {
    final videoId = _extractYouTubeId(item.safeLink);
    if (videoId == null) {
      // Fallback: open as normal web link if somehow not a valid YouTube URL
      final uri = Uri.tryParse(item.safeLink);
      if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

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
    // Handles: https://youtu.be/VIDEOID , https://www.youtube.com/watch?v=VIDEOID
    // and other common formats
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
                carouselController: _carouselController,
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
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(widget.borderRadius),
                              ),
                              child: Image.network(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _displayItems.asMap().entries.map((entry) {
              final bool isActive = _currentIndex == entry.key;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isActive ? AppColor.primaryColor : Colors.grey[400],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}


