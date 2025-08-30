import 'package:flutter/material.dart';

class NoticeItem {
  final String title;
  final DateTime date;
  final bool isRead;


  const NoticeItem({
    required this.title,
    required this.date,
    this.isRead = false,
  });
}

class DemoNotices {
  static final List<NoticeItem> noticeList = [
    NoticeItem(
      title: 'New Batch Schedule for FCPS Part-1',
      date: DateTime(2025, 8, 30),
      isRead: true,
    ),
    NoticeItem(
      title: 'Holiday Notice: Eid-ul-Fitr',
      date: DateTime(2025, 8, 30),
      isRead: false,
    ),
    NoticeItem(
      title: 'Online Class Link Update',
      date: DateTime(2025, 8, 29),
      isRead: false,
    ),
    NoticeItem(
      title: 'Exam Schedule for BCS Preparation',
      date: DateTime(2025, 8, 28),
      isRead: true,
    ),
    NoticeItem(
      title: 'Library Hours Extended',
      date: DateTime(2025, 8, 27),
      isRead: true,
    ),
    NoticeItem(
      title: 'Scholarship Application Deadline',
      date: DateTime(2025, 8, 26),
      isRead: false,
    ),
    NoticeItem(
      title: 'Guest Lecture on Medical Ethics',
      date: DateTime(2025, 8, 20),
      isRead: false,
    ),
    NoticeItem(
      title: 'Payment Reminder for January Batch',
      date: DateTime(2023, 12, 28),
      isRead: true,
    ),
    NoticeItem(
      title: 'New Study Materials Available',
      date: DateTime(2023, 12, 25),
      isRead: true,
    ),
    NoticeItem(
      title: 'Winter Vacation Schedule',
      date: DateTime(2023, 12, 20),
      isRead: false,
    ),
  ];

  // Get unread notices count
  static int get unreadCount =>
      noticeList.where((notice) => !notice.isRead).length;

  // Get latest notices (last 7 days)
  static List<NoticeItem> get recentNotices => noticeList
      .where((notice) =>
      notice.date.isAfter(DateTime.now().subtract(const Duration(days: 7))))
      .toList();

}