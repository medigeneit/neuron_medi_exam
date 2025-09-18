class NoticeDetailsModel {
  final NoticeDetail? noticeDetail;

  NoticeDetailsModel({
    this.noticeDetail,
  });

  factory NoticeDetailsModel.fromJson(Map<String, dynamic> json) {
    return NoticeDetailsModel(
      noticeDetail: json['data'] is Map<String, dynamic>
          ? NoticeDetail.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': noticeDetail?.toJson(),
    };
  }

  bool get isEmpty => noticeDetail == null || noticeDetail!.isEmpty;
  bool get isNotEmpty => noticeDetail != null && noticeDetail!.isNotEmpty;

  // Helper methods
  bool get hasValidNoticeDetail => noticeDetail != null && noticeDetail!.isNotEmpty;
  bool get isValidForDisplay => hasValidNoticeDetail;

  // Safe getters with fallbacks
  NoticeDetail get safeNoticeDetail => noticeDetail ?? NoticeDetail();
}

class NoticeDetail {
  final int? id;
  final String? title;
  final String? description;
  final String? publishDate;
  final String? expiredDate;
  final String? attachmentUrl;
  final String? status;
  final bool? isPublished;
  final bool? isExpired;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;

  NoticeDetail({
    this.id,
    this.title,
    this.description,
    this.publishDate,
    this.expiredDate,
    this.attachmentUrl,
    this.status,
    this.isPublished,
    this.isExpired,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory NoticeDetail.fromJson(Map<String, dynamic> json) {
    return NoticeDetail(
      id: json['id'] is int ? json['id'] : null,
      title: json['title'] is String ? json['title'] : null,
      description: json['description'] is String ? json['description'] : null,
      publishDate: json['publish_date'] is String ? json['publish_date'] : null,
      expiredDate: json['expired_date'] is String ? json['expired_date'] : null,
      attachmentUrl: json['attachment_url'] is String ? json['attachment_url'] : null,
      status: json['status'] is String ? json['status'] : null,
      isPublished: json['is_published'] is bool ? json['is_published'] : null,
      isExpired: json['is_expired'] is bool ? json['is_expired'] : null,
      isActive: json['is_active'] is bool ? json['is_active'] : null,
      createdAt: json['created_at'] is String ? json['created_at'] : null,
      updatedAt: json['updated_at'] is String ? json['updated_at'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'publish_date': publishDate,
      'expired_date': expiredDate,
      'attachment_url': attachmentUrl,
      'status': status,
      'is_published': isPublished,
      'is_expired': isExpired,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get isEmpty =>
      (id == null || id! <= 0) &&
          (title?.isEmpty ?? true) &&
          (description?.isEmpty ?? true) &&
          (publishDate?.isEmpty ?? true) &&
          (expiredDate?.isEmpty ?? true) &&
          (attachmentUrl?.isEmpty ?? true) &&
          (status?.isEmpty ?? true) &&
          (isPublished == null) &&
          (isExpired == null) &&
          (isActive == null) &&
          (createdAt?.isEmpty ?? true) &&
          (updatedAt?.isEmpty ?? true);

  bool get isNotEmpty =>
      (id != null && id! > 0) ||
          (title?.isNotEmpty ?? false) ||
          (description?.isNotEmpty ?? false) ||
          (publishDate?.isNotEmpty ?? false) ||
          (expiredDate?.isNotEmpty ?? false) ||
          (attachmentUrl?.isNotEmpty ?? false) ||
          (status?.isNotEmpty ?? false) ||
          (isPublished != null) ||
          (isExpired != null) ||
          (isActive != null) ||
          (createdAt?.isNotEmpty ?? false) ||
          (updatedAt?.isNotEmpty ?? false);

  // Helper methods
  bool get hasValidId => id != null && id! > 0;
  bool get hasValidTitle => title != null && title!.isNotEmpty;
  bool get hasValidDescription => description != null && description!.isNotEmpty;
  bool get hasValidPublishDate => publishDate != null && publishDate!.isNotEmpty;
  bool get hasValidExpiredDate => expiredDate != null && expiredDate!.isNotEmpty;
  bool get hasValidAttachmentUrl => attachmentUrl != null && attachmentUrl!.isNotEmpty;
  bool get hasValidStatus => status != null && status!.isNotEmpty;
  bool get hasValidIsPublished => isPublished != null;
  bool get hasValidIsExpired => isExpired != null;
  bool get hasValidIsActive => isActive != null;
  bool get hasValidCreatedAt => createdAt != null && createdAt!.isNotEmpty;
  bool get hasValidUpdatedAt => updatedAt != null && updatedAt!.isNotEmpty;
  bool get isValidForDisplay => hasValidTitle && hasValidDescription;

  // Safe getters with fallbacks
  int get safeId => id ?? 0;
  String get safeTitle => title ?? 'No title';
  String get safeDescription => description ?? 'No description';
  String get safePublishDate => publishDate ?? 'No publish date';
  String get safeExpiredDate => expiredDate ?? 'No expiration date';
  String get safeAttachmentUrl => attachmentUrl ?? '';
  String get safeStatus => status ?? 'No status';
  bool get safeIsPublished => isPublished ?? false;
  bool get safeIsExpired => isExpired ?? false;
  bool get safeIsActive => isActive ?? false;
  String get safeCreatedAt => createdAt ?? 'No creation date';
  String get safeUpdatedAt => updatedAt ?? 'No update date';

  // Status helpers
  bool get isActiveStatus => safeStatus.toLowerCase() == 'active';
  bool get isPublishedStatus => safeIsPublished;
  bool get isNotExpired => !safeIsExpired;
  bool get isViewable => isActiveStatus && isPublishedStatus && isNotExpired;

  // Date formatting helpers
  String get formattedPublishDate {
    if (publishDate == null || publishDate!.isEmpty) return 'No publish date';

    try {
      final date = DateTime.parse(publishDate!);
      return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
    } catch (e) {
      return publishDate!;
    }
  }

  String get formattedExpiredDate {
    if (expiredDate == null || expiredDate!.isEmpty) return 'No expiration date';

    try {
      final date = DateTime.parse(expiredDate!);
      return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
    } catch (e) {
      return expiredDate!;
    }
  }

  String get formattedCreatedAt {
    if (createdAt == null || createdAt!.isEmpty) return 'No creation date';

    try {
      final date = DateTime.parse(createdAt!);
      return '${_getMonthName(date.month)} ${date.day}, ${date.year} at ${_formatTime(date)}';
    } catch (e) {
      return createdAt!;
    }
  }

  String get formattedUpdatedAt {
    if (updatedAt == null || updatedAt!.isEmpty) return 'No update date';

    try {
      final date = DateTime.parse(updatedAt!);
      return '${_getMonthName(date.month)} ${date.day}, ${date.year} at ${_formatTime(date)}';
    } catch (e) {
      return updatedAt!;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Time ago helpers
  String get publishTimeAgo => _getTimeAgo(publishDate);
  String get expireTimeAgo => _getTimeAgo(expiredDate);

  String _getTimeAgo(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Unknown time';

    try {
      final date = DateTime.parse(dateString);
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

  // Attachment helpers
  bool get hasAttachment => safeAttachmentUrl.isNotEmpty;
  String get attachmentFileName {
    if (!hasAttachment) return 'No attachment';

    try {
      final uri = Uri.parse(safeAttachmentUrl);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        // Decode URL-encoded filename
        final fileName = pathSegments.last;
        return Uri.decodeFull(fileName);
      }
      return 'Attachment';
    } catch (e) {
      return 'Attachment';
    }
  }

  // HTML content helper (for FlutterHtml or similar)
  String get sanitizedDescription {
    if (safeDescription.isEmpty) return 'No description available';
    return safeDescription;
  }
}