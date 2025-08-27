import 'package:flutter/material.dart';

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

// Dummy images for the slider
final List<SliderImage> sliderImages = [
  SliderImage(
    imageUrl: "https://picsum.photos/800/400?random=1",
    onTap: () {
      debugPrint("Banner 1 tapped");
    },
    caption: "Special Offer - 50% Off on Biology Courses",
  ),

  SliderImage(
    imageUrl: "https://picsum.photos/800/400?random=2",
    onTap: () {
      debugPrint("Banner 2 tapped");
    },
    caption: "Special Offer - 30% Off on Math Courses",
  ),
  SliderImage(
    imageUrl: "https://picsum.photos/800/400?random=3",
    onTap: () {
      debugPrint("Banner 3 tapped");
    },
    caption: "Special Offer - 45% Off on Physics Crash Courses",
  ),
  // ... other images
];