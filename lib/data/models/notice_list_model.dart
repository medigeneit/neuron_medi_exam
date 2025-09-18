import 'package:flutter/material.dart';

class NoticeListModel {
  final List<Notice>? notices;

  NoticeListModel({
    this.notices,
  });

  factory NoticeListModel.fromJson(Map<String, dynamic> json) {
    return NoticeListModel(
      notices: json['data'] is List
          ? (json['data'] as List).map((e) => Notice.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': notices?.map((notice) => notice.toJson()).toList(),
    };
  }

  bool get isEmpty => notices == null || notices!.isEmpty;
  bool get isNotEmpty => notices != null && notices!.isNotEmpty;

  // Helper methods
  bool get hasValidNotices => notices != null && notices!.isNotEmpty;
  bool get isValidForDisplay => hasValidNotices;

  // Safe getters with fallbacks
  List<Notice> get safeNotices => notices ?? [];

  // Filter methods
  List<Notice> get readNotices => safeNotices.where((notice) => notice.isRead).toList();
  List<Notice> get unreadNotices => safeNotices.where((notice) => !notice.isRead).toList();
  int get unreadCount => unreadNotices.length;

  // Mark methods - FIXED: Use proper null-safe approach
  void markAsRead(int noticeId) {
    final index = notices?.indexWhere((n) => n.id == noticeId);
    if (index != null && index != -1) {
      notices![index].isRead = true;
    }
  }

  void markAllAsRead() {
    notices?.forEach((notice) => notice.isRead = true);
  }

  void markAsUnread(int noticeId) {
    final index = notices?.indexWhere((n) => n.id == noticeId);
    if (index != null && index != -1) {
      notices![index].isRead = false;
    }
  }
}

class Notice {
  final int? id;
  final String? title;
  final String? publishDate;
  bool isRead;

  Notice({
    this.id,
    this.title,
    this.publishDate,
    this.isRead = false,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'] is int ? json['id'] : null,
      title: json['title'] is String ? json['title'] : null,
      publishDate: json['publish_date'] is String ? json['publish_date'] : null,
      isRead: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'publish_date': publishDate,
      'is_read': isRead,
    };
  }

  bool get isEmpty =>
      (id == null || id! <= 0) &&
          (title?.isEmpty ?? true) &&
          (publishDate?.isEmpty ?? true);

  bool get isNotEmpty =>
      (id != null && id! > 0) ||
          (title?.isNotEmpty ?? false) ||
          (publishDate?.isNotEmpty ?? false);

  // Helper methods
  bool get hasValidId => id != null && id! > 0;
  bool get hasValidTitle => title != null && title!.isNotEmpty;
  bool get hasValidPublishDate => publishDate != null && publishDate!.isNotEmpty;
  bool get isValidForDisplay => hasValidTitle && hasValidPublishDate;

  // Safe getters with fallbacks
  int get safeId => id ?? 0;
  String get safeTitle => title ?? 'No title';
  String get safePublishDate => publishDate ?? 'No date';

  // Date formatting helper
  String get formattedPublishDate {
    if (publishDate == null || publishDate!.isEmpty) return 'No date';

    try {
      final date = DateTime.parse(publishDate!);
      return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
    } catch (e) {
      return publishDate!;
    }
  }

  String get shortFormattedDate {
    if (publishDate == null || publishDate!.isEmpty) return 'No date';

    try {
      final date = DateTime.parse(publishDate!);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return publishDate!;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  // Time ago helper
  String get timeAgo {
    if (publishDate == null || publishDate!.isEmpty) return 'Unknown time';

    try {
      final date = DateTime.parse(publishDate!);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        final years = (difference.inDays / 365).floor();
        return '$years year${years > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return '$months month${months > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }

  // Status helpers
  bool get isNew => !isRead;
  String get statusText => isRead ? 'Read' : 'New';
  Color get statusColor => isRead ? Colors.grey : Colors.blue;

  // Copy with method for updating read status
  Notice copyWith({
    int? id,
    String? title,
    String? publishDate,
    bool? isRead,
  }) {
    return Notice(
      id: id ?? this.id,
      title: title ?? this.title,
      publishDate: publishDate ?? this.publishDate,
      isRead: isRead ?? this.isRead,
    );
  }
}

extension NoticeListApplyRead on NoticeListModel {
  void applyReadFlags(Set<int> readIds) {
    for (final n in safeNotices) {
      final id = n.id;
      if (id != null) {
        n.isRead = readIds.contains(id);
      }
    }
  }
}