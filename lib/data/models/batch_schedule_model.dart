class BatchScheduleModel {
  final Batch? batch;
  final List<ScheduleDate>? scheduleDates;

  BatchScheduleModel({
    this.batch,
    this.scheduleDates,
  });

  factory BatchScheduleModel.fromJson(Map<String, dynamic> json) {
    return BatchScheduleModel(
      batch: json['batch'] is Map<String, dynamic>
          ? Batch.fromJson(json['batch'])
          : null,
      scheduleDates: json['schedule_dates'] is List
          ? (json['schedule_dates'] as List)
          .map((e) => ScheduleDate.fromJson(e))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batch': batch?.toJson(),
      'schedule_dates': scheduleDates?.map((date) => date.toJson()).toList(),
    };
  }

  bool get isEmpty =>
      (batch == null || batch!.isEmpty) &&
          (scheduleDates == null || scheduleDates!.isEmpty);

  bool get isNotEmpty =>
      (batch != null && batch!.isNotEmpty) ||
          (scheduleDates != null && scheduleDates!.isNotEmpty);

  // Helper methods
  bool get hasValidBatch => batch != null && batch!.isNotEmpty;
  bool get hasValidScheduleDates =>
      scheduleDates != null && scheduleDates!.isNotEmpty;
  bool get isValidForDisplay => hasValidBatch && hasValidScheduleDates;
}

class Batch {
  final int? id;
  final String? bannerUrl;
  final int? batchPackageId;
  final int? coursePackageId;
  final String? coursePackageName;

  Batch({
    this.id,
    this.bannerUrl,
    this.batchPackageId,
    this.coursePackageId,
    this.coursePackageName,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['id'] is int ? json['id'] : null,
      bannerUrl: json['banner_url'] is String ? json['banner_url'] : null,
      batchPackageId:
      json['batch_package_id'] is int ? json['batch_package_id'] : null,
      coursePackageId:
      json['course_package_id'] is int ? json['course_package_id'] : null,
      coursePackageName: json['course_package_name'] is String
          ? json['course_package_name']
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'banner_url': bannerUrl,
      'batch_package_id': batchPackageId,
      'course_package_id': coursePackageId,
      'course_package_name': coursePackageName,
    };
  }

  bool get isEmpty =>
      (id == null || id! <= 0) &&
          (bannerUrl?.isEmpty ?? true) &&
          (batchPackageId == null || batchPackageId! <= 0) &&
          (coursePackageId == null || coursePackageId! <= 0) &&
          (coursePackageName?.isEmpty ?? true);

  bool get isNotEmpty =>
      (id != null && id! > 0) ||
          (bannerUrl?.isNotEmpty ?? false) ||
          (batchPackageId != null && batchPackageId! > 0) ||
          (coursePackageId != null && coursePackageId! > 0) ||
          (coursePackageName?.isNotEmpty ?? false);

  // Helper methods
  bool get hasValidId => id != null && id! > 0;
  bool get hasValidBannerUrl => bannerUrl != null && bannerUrl!.isNotEmpty;
  bool get hasValidBatchPackageId =>
      batchPackageId != null && batchPackageId! > 0;
  bool get hasValidCoursePackageId =>
      coursePackageId != null && coursePackageId! > 0;
  bool get hasValidCoursePackageName =>
      coursePackageName != null && coursePackageName!.isNotEmpty;
  bool get isValidForDisplay => hasValidId && hasValidCoursePackageName;

  // Safe getters with fallbacks
  int get safeId => id ?? 0;
  String get safeBannerUrl => bannerUrl ?? '';
  int get safeBatchPackageId => batchPackageId ?? 0;
  int get safeCoursePackageId => coursePackageId ?? 0;
  String get safeCoursePackageName => coursePackageName ?? 'Unnamed Package';
}

class ScheduleDate {
  final String? time;
  final String? date;
  final String? dateFormatted;
  final int? scheduleDetailId;
  final List<Content>? contents;

  ScheduleDate({
    this.time,
    this.date,
    this.dateFormatted,
    this.scheduleDetailId,
    this.contents,
  });

  factory ScheduleDate.fromJson(Map<String, dynamic> json) {
    return ScheduleDate(
      time: json['time'] is String ? json['time'] : null,
      date: json['date'] is String ? json['date'] : null,
      dateFormatted:
      json['date_formatted'] is String ? json['date_formatted'] : null,
      scheduleDetailId: json['schedule_detail_id'] is int
          ? json['schedule_detail_id']
          : null,
      contents: json['contents'] is List
          ? (json['contents'] as List).map((e) => Content.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'date': date,
      'date_formatted': dateFormatted,
      'schedule_detail_id': scheduleDetailId,
      'contents': contents?.map((content) => content.toJson()).toList(),
    };
  }

  bool get isEmpty =>
      (time?.isEmpty ?? true) &&
          (date?.isEmpty ?? true) &&
          (dateFormatted?.isEmpty ?? true) &&
          (scheduleDetailId == null || scheduleDetailId! <= 0) &&
          (contents?.isEmpty ?? true);

  bool get isNotEmpty =>
      (time?.isNotEmpty ?? false) ||
          (date?.isNotEmpty ?? false) ||
          (dateFormatted?.isNotEmpty ?? false) ||
          (scheduleDetailId != null && scheduleDetailId! > 0) ||
          (contents?.isNotEmpty ?? false);

  // Helper methods
  bool get hasValidTime => time != null && time!.isNotEmpty;
  bool get hasValidDate => date != null && date!.isNotEmpty;
  bool get hasValidDateFormatted =>
      dateFormatted != null && dateFormatted!.isNotEmpty;
  bool get hasValidScheduleDetailId =>
      scheduleDetailId != null && scheduleDetailId! > 0;
  bool get hasValidContents => contents != null && contents!.isNotEmpty;
  bool get isValidForDisplay =>
      hasValidDateFormatted && hasValidTime && hasValidContents;

  // Safe getters with fallbacks
  String get safeTime => time ?? 'No time specified';
  String get safeDate => date ?? 'No date specified';
  String get safeDateFormatted => dateFormatted ?? 'No date';
  int get safeScheduleDetailId => scheduleDetailId ?? 0;
  List<Content> get safeContents => contents ?? [];

  // Date formatting helper
  String get formattedDate {
    if (date == null || date!.isEmpty) return safeDateFormatted;

    try {
      final dateTime = DateTime.parse(date!);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return date!;
    }
  }
}

class Content {
  final int? id;
  final String? examOrClassId;
  final String? type;
  final String? topicName;

  Content({
    this.id,
    this.examOrClassId,
    this.type,
    this.topicName,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id'] is int ? json['id'] : null,
      examOrClassId:
      json['exam_or_class_id'] is String ? json['exam_or_class_id'] : null,
      type: json['type'] is String ? json['type'] : null,
      topicName: json['topic_name'] is String ? json['topic_name'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exam_or_class_id': examOrClassId,
      'type': type,
      'topic_name': topicName,
    };
  }

  bool get isEmpty =>
      (id == null || id! <= 0) &&
          (examOrClassId?.isEmpty ?? true) &&
          (type?.isEmpty ?? true) &&
          (topicName?.isEmpty ?? true);

  bool get isNotEmpty =>
      (id != null && id! > 0) ||
          (examOrClassId?.isNotEmpty ?? false) ||
          (type?.isNotEmpty ?? false) ||
          (topicName?.isNotEmpty ?? false);

  // Helper methods
  bool get hasValidId => id != null && id! > 0;
  bool get hasValidExamOrClassId =>
      examOrClassId != null && examOrClassId!.isNotEmpty;
  bool get hasValidType => type != null && type!.isNotEmpty;
  bool get hasValidTopicName => topicName != null && topicName!.isNotEmpty;
  bool get isValidForDisplay => hasValidTopicName && hasValidType;

  // Safe getters with fallbacks
  int get safeId => id ?? 0;
  String get safeExamOrClassId => examOrClassId ?? '';
  String get safeType => type ?? 'Unknown type';
  String get safeTopicName => topicName ?? 'Untitled topic';

  // Type check helpers
  bool get isExam => safeType.toLowerCase() == 'exam';
  bool get isClass => safeType.toLowerCase() == 'class';
}