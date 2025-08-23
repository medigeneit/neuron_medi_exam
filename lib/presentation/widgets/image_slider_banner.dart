import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';

class SliderImage {
  final String imageUrl;
  final VoidCallback onTap;
  final String? caption;

  SliderImage({
    required this.imageUrl,
    required this.onTap,
    this.caption,
  });
}

class ImageSliderBanner extends StatefulWidget {
  final List<SliderImage> images;
  final double height;
  final double borderRadius;
  final BoxFit fit;

  const ImageSliderBanner({
    Key? key,
    required this.images,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    final height = isMobile ? widget.height * 0.8 : widget.height;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          // Main Carousel with improved styling
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
                itemCount: widget.images.length,
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
                  return GestureDetector(
                    onTap: widget.images[index].onTap,
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
                            // Image with proper rounded corners
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(widget.borderRadius),
                              ),
                              child: Image.network(
                                widget.images[index].imageUrl,
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

                            // Gradient overlay for better text readability
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

                            // Caption with improved styling
                            if (widget.images[index].caption != null)
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
                                    widget.images[index].caption!,
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

          // Modern dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.images.asMap().entries.map((entry) {
              final bool isActive = _currentIndex == entry.key;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isActive
                      ? AppColor.primaryColor
                      : (isDark ? Colors.white38 : Colors.grey[400]),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}