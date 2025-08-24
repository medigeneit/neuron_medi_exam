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