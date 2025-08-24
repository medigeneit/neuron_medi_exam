import 'package:flutter/material.dart';

class AvailableBatchItem {
  final String title;
  final String subTitle;
  final String startDate;
  final String days;
  final String time;
  final String? price;
  final String? discount;
  final String? imageUrl;
  final String? batchDetails;
  final String? courseOutline;
  final String? courseFee;
  final String? offer;
  final VoidCallback? onDetails;

  const AvailableBatchItem({
    required this.title,
    required this.subTitle,
    required this.startDate,
    required this.days,
    required this.time,
    this.price,
    this.discount,
    this.imageUrl,
    this.batchDetails,
    this.courseOutline,
    this.courseFee,
    this.offer,
    this.onDetails,
  });
}