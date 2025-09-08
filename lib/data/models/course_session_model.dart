class CourseSessionModel {
  final List<CourseSession>? courseSessions;

  CourseSessionModel({
    this.courseSessions,
  });

  factory CourseSessionModel.fromJson(List<dynamic> json) {
    return CourseSessionModel(
      courseSessions: json.isNotEmpty
          ? json.map((e) => CourseSession.fromJson(e)).toList()
          : null,
    );
  }

  List<dynamic> toJson() {
    return courseSessions?.map((session) => session.toJson()).toList() ?? [];
  }

  bool get isEmpty => courseSessions == null || courseSessions!.isEmpty;
  bool get isNotEmpty => courseSessions != null && courseSessions!.isNotEmpty;
}

class CourseSession {
  final int? courseSessionId;
  final String? courseSessionName;
  final List<Batch>? batches;

  CourseSession({
    this.courseSessionId,
    this.courseSessionName,
    this.batches,
  });

  factory CourseSession.fromJson(Map<String, dynamic> json) {
    return CourseSession(
      courseSessionId: json['course_session_id'] is int ? json['course_session_id'] : null,
      courseSessionName: json['course_session_name'] is String ? json['course_session_name'] : null,
      batches: json['batches'] is List
          ? (json['batches'] as List).map((e) => Batch.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_session_id': courseSessionId,
      'course_session_name': courseSessionName,
      'batches': batches?.map((batch) => batch.toJson()).toList(),
    };
  }

  bool get isEmpty =>
      (courseSessionId == null || courseSessionId! <= 0) &&
          (courseSessionName?.isEmpty ?? true) &&
          (batches?.isEmpty ?? true);

  bool get isNotEmpty =>
      (courseSessionId != null && courseSessionId! > 0) ||
          (courseSessionName?.isNotEmpty ?? false) ||
          (batches?.isNotEmpty ?? false);

  // Helper methods
  bool get hasValidId => courseSessionId != null && courseSessionId! > 0;
  bool get hasValidName => courseSessionName != null && courseSessionName!.isNotEmpty;
  bool get hasValidBatches => batches != null && batches!.isNotEmpty;
  bool get isValidForDisplay => hasValidName && hasValidBatches;

  // Safe getters with fallbacks
  String get safeCourseSessionName => courseSessionName ?? 'Unnamed Session';
  int get safeCourseSessionId => courseSessionId ?? 0;
}

class Batch {
  final int? id;
  final String? name;
  final String? startDate;
  final String? examDays;
  final String? examTime;
  final String? bannerUrl;

  Batch({
    this.id,
    this.name,
    this.startDate,
    this.examDays,
    this.examTime,
    this.bannerUrl,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['id'] is int ? json['id'] : null,
      name: json['name'] is String ? json['name'] : null,
      startDate: json['start_date'] is String ? json['start_date'] : null,
      examDays: json['exam_days'] is String ? json['exam_days'] : null,
      examTime: json['exam_time'] is String ? json['exam_time'] : null,
      bannerUrl: json['banner_url'] is String ? json['banner_url'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'start_date': startDate,
      'exam_days': examDays,
      'exam_time': examTime,
      'banner_url': bannerUrl,
    };
  }

  bool get isEmpty =>
      (id == null || id! <= 0) &&
          (name?.isEmpty ?? true) &&
          (startDate?.isEmpty ?? true) &&
          (examDays?.isEmpty ?? true) &&
          (examTime?.isEmpty ?? true) &&
          (bannerUrl?.isEmpty ?? true);

  bool get isNotEmpty =>
      (id != null && id! > 0) ||
          (name?.isNotEmpty ?? false) ||
          (startDate?.isNotEmpty ?? false) ||
          (examDays?.isNotEmpty ?? false) ||
          (examTime?.isNotEmpty ?? false) ||
          (bannerUrl?.isNotEmpty ?? false);

  // Helper methods
  bool get hasValidId => id != null && id! > 0;
  bool get hasValidName => name != null && name!.isNotEmpty;
  bool get hasValidStartDate => startDate != null && startDate!.isNotEmpty;
  bool get hasValidExamDays => examDays != null && examDays!.isNotEmpty;
  bool get hasValidExamTime => examTime != null && examTime!.isNotEmpty;
  bool get hasValidBannerUrl => bannerUrl != null && bannerUrl!.isNotEmpty;
  bool get isValidForDisplay => hasValidName && hasValidStartDate;

  // Safe getters with fallbacks
  String get safeName => name ?? 'Unnamed Batch';
  String get safeStartDate => startDate ?? 'No start date';
  String get safeExamDays => examDays ?? 'No schedule';
  String get safeExamTime => examTime ?? 'No time specified';
  String get safeBannerUrl => bannerUrl ?? '';
  int get safeId => id ?? 0;

  // Date formatting helper
  String get formattedStartDate {
    if (startDate == null || startDate!.isEmpty) return 'No start date';

    try {
      final date = DateTime.parse(startDate!);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return startDate!;
    }
  }

  // Schedule summary
  String get scheduleSummary {
    if (examDays == null && examTime == null) return 'Schedule not available';
    if (examDays == null) return 'At $safeExamTime';
    if (examTime == null) return 'On $safeExamDays';
    return '$safeExamDays at $safeExamTime';
  }
}