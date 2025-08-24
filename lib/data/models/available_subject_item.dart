import 'package:flutter/material.dart';

class AvailableSubjectsItem {
  final String title;
  final String subTitle;
  final String startDate;
  final String days;
  final String time;
  final String? price;
  final String? discount;
  final String? imageUrl;
  final VoidCallback onDetails;

  const AvailableSubjectsItem({
    required this.title,
    required this.subTitle,
    required this.startDate,
    required this.days,
    required this.time,
    this.price,
    this.discount,
    this.imageUrl,
    required this.onDetails,
  });
}