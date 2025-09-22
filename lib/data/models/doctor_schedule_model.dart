// lib/data/models/doctor_schedule_model.dart

class DoctorScheduleModel {
  final Batch? batch;
  final List<ScheduleDate>? scheduleDates;

  DoctorScheduleModel({this.batch, this.scheduleDates});

  factory DoctorScheduleModel.fromJson(Map<String, dynamic> json) {
    return DoctorScheduleModel(
      batch: json['batch'] is Map<String, dynamic>
          ? Batch.fromJson(json['batch'] as Map<String, dynamic>)
          : null,
      scheduleDates: json['schedule_dates'] is List
          ? (json['schedule_dates'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => ScheduleDate.fromJson(e))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'batch': batch?.toJson(),
        'schedule_dates': scheduleDates?.map((e) => e.toJson()).toList(),
      };

  bool get isEmpty =>
      (batch == null || batch!.isEmpty) &&
          (scheduleDates == null || scheduleDates!.isEmpty);

  bool get isNotEmpty => !isEmpty;

  Batch get safeBatch => batch ?? Batch();

  List<ScheduleDate> get safeScheduleDates => scheduleDates ?? [];
}

// ---------- helpers ----------
bool _toBool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final s = v.trim().toLowerCase();
    return s == 'true' || s == '1' || s == 'yes';
  }
  return false;
}

int? _toInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v.trim());
  return null;
}

String? _toString(dynamic v) {
  if (v == null) return null;
  if (v is String) return v.trim();
  return v.toString();
}

// ---------- Batch ----------
class Batch {
  final int? id;
  final String? bannerUrl;
  final int? batchPackageId;
  final int? coursePackageId;
  final String? coursePackageName;

  // Fields present in your payload
  final String? regNo;
  final String? year;
  final String? batchName;
  final String? courseName;
  final int? progressCount; // <-- NEW: maps "progress_count"

  Batch({
    this.id,
    this.bannerUrl,
    this.batchPackageId,
    this.coursePackageId,
    this.coursePackageName,
    this.regNo,
    this.year,
    this.batchName,
    this.courseName,
    this.progressCount,
  });

  factory Batch.fromJson(Map<String, dynamic> json) =>
      Batch(
        id: _toInt(json['id']),
        bannerUrl: _toString(json['banner_url']),
        batchPackageId: _toInt(json['batch_package_id']),
        coursePackageId: _toInt(json['course_package_id']),
        coursePackageName: _toString(json['course_package_name']),
        regNo: _toString(json['reg_no']),
        year: _toString(json['year']),
        batchName: _toString(json['batch_name']),
        courseName: _toString(json['course_name']),
        progressCount: _toInt(json['progress_count']), // <-- NEW
      );

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'banner_url': bannerUrl,
        'batch_package_id': batchPackageId,
        'course_package_id': coursePackageId,
        'course_package_name': coursePackageName,
        'reg_no': regNo,
        'year': year,
        'batch_name': batchName,
        'course_name': courseName,
        'progress_count': progressCount, // <-- NEW
      };

  bool get isEmpty =>
      (id == null || id! <= 0) &&
          (bannerUrl?.isEmpty ?? true) &&
          (batchPackageId == null || batchPackageId! <= 0) &&
          (coursePackageId == null) &&
          (coursePackageName?.isEmpty ?? true) &&
          (regNo?.isEmpty ?? true) &&
          (year?.isEmpty ?? true) &&
          (batchName?.isEmpty ?? true) &&
          (courseName?.isEmpty ?? true) &&
          (progressCount == null); // consider empty if not provided at all

  bool get isNotEmpty => !isEmpty;

  // -------- Safe getters / helpers --------
  int get safeId => id ?? 0;

  String get admissionId => (id != null && id! > 0) ? id.toString() : '0';

  String get safeBatchName => batchName ?? '';

  String get safeCourseName => courseName ?? '';

  String get safeCoursePackageName => coursePackageName ?? '';

  String get safeRegNo => regNo ?? '';

  String get safeYear => year ?? '';

  int get safeProgressCount => progressCount ?? 0;

  /// A convenient display title: Batch Name → Course Name → fallback
  String get displayTitle =>
      (batchName?.isNotEmpty ?? false)
          ? batchName!
          : (courseName?.isNotEmpty ?? false)
          ? courseName!
          : 'Unnamed Batch';
}

// ---------- ScheduleDate ----------
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

  factory ScheduleDate.fromJson(Map<String, dynamic> json) =>
      ScheduleDate(
        time: _toString(json['time']),
        date: _toString(json['date']),
        dateFormatted: _toString(json['date_formatted']),
        scheduleDetailId: _toInt(json['schedule_detail_id']),
        contents: json['contents'] is List
            ? (json['contents'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => Content.fromJson(e))
            .toList()
            : const <Content>[],
      );

  Map<String, dynamic> toJson() =>
      {
        'time': time,
        'date': date,
        'date_formatted': dateFormatted,
        'schedule_detail_id': scheduleDetailId,
        'contents': contents?.map((e) => e.toJson()).toList(),
      };

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
          (contents?.isNotEmpty ?? false); // Helper methods
  bool get hasValidTime => time != null && time!.isNotEmpty;

  bool get hasValidDate => date != null && date!.isNotEmpty;

  bool get hasValidDateFormatted =>
      dateFormatted != null && dateFormatted!.isNotEmpty;

  bool get hasValidScheduleDetailId =>
      scheduleDetailId != null && scheduleDetailId! > 0;

  bool get hasValidContents => contents != null && contents!.isNotEmpty;

  bool get isValidForDisplay =>
      hasValidDateFormatted &&
          hasValidTime &&
          hasValidContents; // Safe getters with fallbacks
  String get safeTime => time ?? 'No time specified';

  String get safeDate => date ?? 'No date specified';

  String get safeDateFormatted => dateFormatted ?? 'No date';

  int get safeScheduleDetailId => scheduleDetailId ?? 0;

  List<Content> get safeContents =>
      contents ??
          []; // Date formatting helper


  String get formattedDate {
    if (date == null || date!.isEmpty) return safeDateFormatted;
    try {
      final dateTime = DateTime.parse(date!);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return date!;
    }
  } // Status helpers
  bool get hasUnlockedContents =>
      safeContents.any((content) => content.contentStatus == 'unlocked');

  bool get hasLockedContents =>
      safeContents.any((content) => content.contentStatus == 'locked');
}

// ---------- Content ----------
class Content {
  final int? id;
  final String? examId;
  final String? type;
  final String? topicName;
  final String? contentStatus;
  final String? statusMessage;
  final String? examStatus;
  final bool? isExamRunning;
  final int? isShowSolve;
  final bool? isUnlockedSolve;
  final String? solveStatusMessage;
  final List<SolveLink>? solveLinks;
  final dynamic examFeedback;

  Content({
    this.id,
    this.examId,
    this.type,
    this.topicName,
    this.contentStatus,
    this.statusMessage,
    this.examStatus,
    this.isExamRunning,
    this.isShowSolve,
    this.isUnlockedSolve,
    this.solveStatusMessage,
    this.solveLinks,
    this.examFeedback,
  });

  factory Content.fromJson(Map<String, dynamic> json) =>
      Content(
        id: _toInt(json['id']),
        examId: _toString(json['exam_id']),
        type: _toString(json['type']),
        topicName: _toString(json['topic_name']),
        contentStatus: _toString(json['content_status']),
        statusMessage: _toString(json['status_message']),
        examStatus: _toString(json['exam_status']),
        isExamRunning: _toBool(json['is_exam_running']),
        isShowSolve: _toInt(json['is_show_solve']),
        isUnlockedSolve: _toBool(json['is_unlocked_solve']),
        solveStatusMessage: _toString(json['solve_status_message']),
        solveLinks: json['solve_links'] is List
            ? (json['solve_links'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => SolveLink.fromJson(e))
            .toList()
            : const <SolveLink>[],
        examFeedback: json['exam_feedback'],
      );

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'exam_id': examId,
        'type': type,
        'topic_name': topicName,
        'content_status': contentStatus,
        'status_message': statusMessage,
        'exam_status': examStatus,
        'is_exam_running': isExamRunning,
        'is_show_solve': isShowSolve,
        'is_unlocked_solve': isUnlockedSolve,
        'solve_status_message': solveStatusMessage,
        'solve_links': solveLinks?.map((e) => e.toJson()).toList(),
        'exam_feedback': examFeedback,
      };

  // ---- normalized safe getters
  String get safeType => (type ?? 'unknown').trim();

  String get safeTopicName => (topicName ?? 'No topic name').trim();

  String get safeContentStatus => (contentStatus ?? 'unknown').trim();

  String get safeStatusMessage => (statusMessage ?? '').trim();

  String get safeExamStatus => (examStatus ?? 'Not Started').trim();

  bool get safeIsExamRunning => isExamRunning ?? false;

  int get safeIsShowSolve => isShowSolve ?? 0;

  bool get safeIsUnlockedSolve => isUnlockedSolve ?? false;

  String get safeSolveStatusMessage => (solveStatusMessage ?? '').trim();

  List<SolveLink> get safeSolveLinks => solveLinks ?? const [];

  // ---- derived flags (trim + lowercase)
  bool get isExam => safeType.toLowerCase() == 'exam';

  bool get isUnlocked => safeContentStatus.toLowerCase() == 'unlocked';

  bool get isLocked => safeContentStatus.toLowerCase() == 'locked';

  bool get isExamCompleted => safeExamStatus.toLowerCase() == 'completed';

  bool get isExamNotCompleted =>
      safeExamStatus.toLowerCase() == 'not completed';

  bool get canShowSolve => safeIsShowSolve == 1;

  bool get canAccessSolve => canShowSolve && safeIsUnlockedSolve;

  bool get hasSolveLinks => safeSolveLinks.isNotEmpty;
}

// ---------- SolveLink ----------
class SolveLink {
  final int? id;
  final String? name;

  SolveLink({this.id, this.name});

  factory SolveLink.fromJson(Map<String, dynamic> json) =>
      SolveLink(
        id: _toInt(json['id']),
        name: _toString(json['name']),
      );

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'name': name,
      };

  int get safeId => id ?? 0;

  String get safeName => name ?? 'Unnamed link';
}
