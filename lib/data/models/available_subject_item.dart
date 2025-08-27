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

// Dummy list for demo
final List<AvailableSubjectsItem> demoSubjectsItems = [

  AvailableSubjectsItem(
    title: "Chapter 01: Cell Structure & Function",
    subTitle: "Subject: Biology",
    startDate: "01 Oct 2025",
    days: "Mon, Wed, Fri",
    time: "6:00 PM - 7:30 PM",
    discount: "Free",
    onDetails: () {
      // You can navigate or show dialog here
      debugPrint("Chapter 01: Cell Structure & Function");
    },
  ),

  AvailableSubjectsItem(
    title: "Chapter 02: Atomic Structure",
    subTitle: "Subject: Chemistry",
    startDate: "03 Oct 2025",
    days: "Mon, Wed",
    time: "6:00 PM - 7:30 PM",

    onDetails: () {
      debugPrint("Chapter 02: Atomic Structure");
    },
  ),

  AvailableSubjectsItem(
    title: "Chapter 05: Laws of Motion",
    subTitle: "Subject: Physics",
    startDate: "04 Oct 2025",
    days: "Tue, Thu",
    time: "5:00 PM - 6:30 PM",
    discount: "50% OFF",
    onDetails: () {
      debugPrint("Chapter 05: Laws of Motion");
    },
  ),

  AvailableSubjectsItem(
    title: "Chapter 03: Quantitative Chemistry",
    subTitle: "Subject: Chemistry",
    startDate: "05 Oct 2025",
    days: "Tue, Thu",
    time: "7:00 PM - 8:30 PM",
    onDetails: () {
      debugPrint("Chapter 03: Quantitative Chemistry");
    },
  ),

  AvailableSubjectsItem(
    title: "Chapter 10: Semiconductors & Electronics",
    subTitle: "Subjects: Physics",
    startDate: "10 Oct 2025",
    days: "Sat, Sun",
    time: "5:00 PM - 6:30 PM",
    discount: "Free",
    onDetails: () {
      debugPrint("Chapter 10: Semiconductors & Electronics");
    },
  ),
  AvailableSubjectsItem(
    title: "Chapter 10: Statistics & Probability",
    subTitle: "Subject: Math",
    startDate: "12 Oct 2025",
    days: "Mon - Fri",
    time: "8:00 PM - 9:00 PM",

    onDetails: () {
      debugPrint("Chapter 10: Statistics & Probability");
    },
  ),


];