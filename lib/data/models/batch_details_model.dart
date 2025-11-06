class BatchDetailsModel {
  // New fields from the response
  final String? name;
  final int? courseId;
  final String? courseName;
  final DateTime? startDate; // parsed from "YYYY-MM-DD"
  final String? examDays;    // e.g., "Sun, Mon"
  final String? examTime;    // e.g., "10:00 AM"

  // Existing fields
  final int? id;
  final String? bannerUrl;
  final String? description;
  final String? courseOutline;
  final String? courseFeeOffer;
  final String? registrationProcess;
  final int? batchPackageId;
  final int? coursePrice;
  final int? newDoctorDiscount;
  final int? oldDoctorDiscount;
  final String? coursePackageId;
  final String? coursePackageName;

  BatchDetailsModel({
    // new
    this.name,
    this.courseId,
    this.courseName,
    this.startDate,
    this.examDays,
    this.examTime,
    // existing
    this.id,
    this.bannerUrl,
    this.description,
    this.courseOutline,
    this.courseFeeOffer,
    this.registrationProcess,
    this.batchPackageId,
    this.coursePrice,
    this.newDoctorDiscount,
    this.oldDoctorDiscount,
    this.coursePackageId,
    this.coursePackageName,
  });

  factory BatchDetailsModel.fromJson(Map<String, dynamic> json) {
    return BatchDetailsModel(
      // new
      name: _parseString(json['name']),
      courseId: _parseInt(json['course_id']),
      courseName: _parseString(json['course_name']),
      startDate: _parseDate(json['start_date']),
      examDays: _parseString(json['exam_days']),
      examTime: _parseString(json['exam_time']),
      // existing
      id: _parseInt(json['id']),
      bannerUrl: _parseString(json['banner_url']),
      description: _parseString(json['description']),
      courseOutline: _parseString(json['course_outline']),
      courseFeeOffer: _parseString(json['course_fee_offer']),
      registrationProcess: _parseString(json['registration_process']),
      batchPackageId: _parseInt(json['batch_package_id']),
      coursePrice: _parseInt(json['course_price']),
      newDoctorDiscount: _parseInt(json['new_doctor_discount']),
      oldDoctorDiscount: _parseInt(json['old_doctor_discount']),
      coursePackageId: _parseString(json['course_package_id']),
      coursePackageName: _parseString(json['course_package_name']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // new
      'name': name,
      'course_id': courseId,
      'course_name': courseName,
      'start_date': _formatDate(startDate), // back to "YYYY-MM-DD"
      'exam_days': examDays,
      'exam_time': examTime,
      // existing
      'id': id,
      'banner_url': bannerUrl,
      'description': description,
      'course_outline': courseOutline,
      'course_fee_offer': courseFeeOffer,
      'registration_process': registrationProcess,
      'batch_package_id': batchPackageId,
      'course_price': coursePrice,
      'new_doctor_discount': newDoctorDiscount,
      'old_doctor_discount': oldDoctorDiscount,
      'course_package_id': coursePackageId,
      'course_package_name': coursePackageName,
    };
  }

  // ---------- Helpers ----------

  // Parse integers with null/empty handling
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      if (value.trim().isEmpty) return null;
      return int.tryParse(value);
    }
    if (value is double) return value.toInt();
    return null;
  }

  // Parse strings with null/empty handling
  static String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return value.toString();
  }

  // Parse date in "YYYY-MM-DD" (or null/empty) to DateTime (UTC at midnight)
  static DateTime? _parseDate(dynamic value) {
    final s = _parseString(value);
    if (s == null) return null;
    try {
      // Keep it simple: treat as local date with no time component
      final parts = s.split('-');
      if (parts.length != 3) return null;
      final y = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final d = int.parse(parts[2]);
      return DateTime(y, m, d);
    } catch (_) {
      return null;
    }
  }

  // Format DateTime to "YYYY-MM-DD"
  static String? _formatDate(DateTime? date) {
    if (date == null) return null;
    String two(int n) => n < 10 ? '0$n' : '$n';
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }

  // ---------- Convenience: has* checks ----------

  bool get hasName => name != null && name!.isNotEmpty;
  bool get hasCourseName => courseName != null && courseName!.isNotEmpty;
  bool get hasStartDate => startDate != null;
  bool get hasExamDays => examDays != null && examDays!.isNotEmpty;
  bool get hasExamTime => examTime != null && examTime!.isNotEmpty;

  bool get hasBannerUrl => bannerUrl != null && bannerUrl!.isNotEmpty;
  bool get hasDescription => description != null && description!.isNotEmpty;
  bool get hasCourseOutline => courseOutline != null && courseOutline!.isNotEmpty;
  bool get hasCourseFeeOffer => courseFeeOffer != null && courseFeeOffer!.isNotEmpty;
  bool get hasRegistrationProcess => registrationProcess != null && registrationProcess!.isNotEmpty;
  bool get hasCoursePackageName => coursePackageName != null && coursePackageName!.isNotEmpty;

  // ---------- Convenience: safe getters ----------

  String get safeName => name ?? '';
  int get safeCourseId => courseId ?? 0;
  String get safeCourseName => courseName ?? '';
  String get safeStartDate => _formatDate(startDate) ?? '';
  String get safeExamDays => examDays ?? '';
  String get safeExamTime => examTime ?? '';

  String get safeBannerUrl => bannerUrl ?? '';
  String get safeDescription => description ?? '';
  String get safeCourseOutline => courseOutline ?? '';
  String get safeCourseFeeOffer => courseFeeOffer ?? '';
  String get safeRegistrationProcess => registrationProcess ?? '';
  String get safeCoursePackageName => coursePackageName ?? '';
  int get safeCoursePrice => coursePrice ?? 0;
  int get safeNewDoctorDiscount => newDoctorDiscount ?? 0;
  int get safeOldDoctorDiscount => oldDoctorDiscount ?? 0;
}
