class AllEnrolledBatchesModel {
  final List<EnrolledBatch>? enrolledBatches;

  AllEnrolledBatchesModel({
    this.enrolledBatches,
  });

  factory AllEnrolledBatchesModel.fromJson(List<dynamic> json) {
    return AllEnrolledBatchesModel(
      enrolledBatches: json.isNotEmpty
          ? json.map((e) => EnrolledBatch.fromJson(e)).toList()
          : null,
    );
  }

  List<dynamic> toJson() {
    return enrolledBatches?.map((batch) => batch.toJson()).toList() ?? [];
  }

  bool get isEmpty => enrolledBatches == null || enrolledBatches!.isEmpty;
  bool get isNotEmpty => enrolledBatches != null && enrolledBatches!.isNotEmpty;

  // Helper methods
  bool get hasValidBatches => enrolledBatches != null && enrolledBatches!.isNotEmpty;
  bool get isValidForDisplay => hasValidBatches;

  // Safe getters with fallbacks
  List<EnrolledBatch> get safeEnrolledBatches => enrolledBatches ?? [];
}

class EnrolledBatch {
  final int? id;
  final String? regNo;
  final String? year;
  final int? batchId;
  final int? batchPackageId;
  final int? progressCount;
  final String? paymentStatus;
  final String? batchName;
  final int? coursePackageId;
  final String? coursePackageName;
  final int? courseId;
  final String? courseName;

  EnrolledBatch({
    this.id,
    this.regNo,
    this.year,
    this.batchId,
    this.batchPackageId,
    this.progressCount,
    this.paymentStatus,
    this.batchName,
    this.coursePackageId,
    this.coursePackageName,
    this.courseId,
    this.courseName,
  });

  factory EnrolledBatch.fromJson(Map<String, dynamic> json) {
    return EnrolledBatch(
      id: json['id'] is int ? json['id'] : null,
      regNo: json['reg_no'] is String ? json['reg_no'] : null,
      year: json['year'] is String ? json['year'] : null,
      batchId: json['batch_id'] is int ? json['batch_id'] : null,
      batchPackageId: json['batch_package_id'] is int ? json['batch_package_id'] : null,
      progressCount: json['progress_count'] is int ? json['progress_count'] : null,
      paymentStatus: json['payment_status'] is String ? json['payment_status'] : null,
      batchName: json['batch_name'] is String ? json['batch_name'] : null,
      coursePackageId: json['course_package_id'] is int ? json['course_package_id'] : null,
      coursePackageName: json['course_package_name'] is String ? json['course_package_name'] : null,
      courseId: json['course_id'] is int ? json['course_id'] : null,
      courseName: json['course_name'] is String ? json['course_name'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reg_no': regNo,
      'year': year,
      'batch_id': batchId,
      'batch_package_id': batchPackageId,
      'progress_count': progressCount,
      'payment_status': paymentStatus,
      'batch_name': batchName,
      'course_package_id': coursePackageId,
      'course_package_name': coursePackageName,
      'course_id': courseId,
      'course_name': courseName,
    };
  }

  bool get isEmpty =>
      (id == null || id! <= 0) &&
          (regNo?.isEmpty ?? true) &&
          (year?.isEmpty ?? true) &&
          (batchId == null || batchId! <= 0) &&
          (batchPackageId == null || batchPackageId! <= 0) &&
          (progressCount == null || progressCount! < 0) &&
          (paymentStatus?.isEmpty ?? true) &&
          (batchName?.isEmpty ?? true) &&
          (coursePackageId == null || coursePackageId! <= 0) &&
          (coursePackageName?.isEmpty ?? true) &&
          (courseId == null || courseId! <= 0) &&
          (courseName?.isEmpty ?? true);

  bool get isNotEmpty =>
      (id != null && id! > 0) ||
          (regNo?.isNotEmpty ?? false) ||
          (year?.isNotEmpty ?? false) ||
          (batchId != null && batchId! > 0) ||
          (batchPackageId != null && batchPackageId! > 0) ||
          (progressCount != null && progressCount! >= 0) ||
          (paymentStatus?.isNotEmpty ?? false) ||
          (batchName?.isNotEmpty ?? false) ||
          (coursePackageId != null && coursePackageId! > 0) ||
          (coursePackageName?.isNotEmpty ?? false) ||
          (courseId != null && courseId! > 0) ||
          (courseName?.isNotEmpty ?? false);

  // Helper methods
  bool get hasValidId => id != null && id! > 0;
  bool get hasValidRegNo => regNo != null && regNo!.isNotEmpty;
  bool get hasValidYear => year != null && year!.isNotEmpty;
  bool get hasValidBatchId => batchId != null && batchId! > 0;
  bool get hasValidBatchPackageId => batchPackageId != null && batchPackageId! > 0;
  bool get hasValidProgressCount => progressCount != null && progressCount! >= 0;
  bool get hasValidPaymentStatus => paymentStatus != null && paymentStatus!.isNotEmpty;
  bool get hasValidBatchName => batchName != null && batchName!.isNotEmpty;
  bool get hasValidCoursePackageId => coursePackageId != null && coursePackageId! > 0;
  bool get hasValidCoursePackageName => coursePackageName != null && coursePackageName!.isNotEmpty;
  bool get hasValidCourseId => courseId != null && courseId! > 0;
  bool get hasValidCourseName => courseName != null && courseName!.isNotEmpty;
  bool get isValidForDisplay => hasValidBatchName && hasValidCourseName;

  // Safe getters with fallbacks
  int get safeId => id ?? 0;
  String get safeRegNo => regNo ?? 'No registration number';
  String get safeYear => year ?? 'No year';
  int get safeBatchId => batchId ?? 0;
  int get safeBatchPackageId => batchPackageId ?? 0;
  int get safeProgressCount => progressCount ?? 0;
  String get safePaymentStatus => paymentStatus ?? 'No payment status';
  String get safeBatchName => batchName ?? 'No batch name';
  int get safeCoursePackageId => coursePackageId ?? 0;
  String get safeCoursePackageName => coursePackageName ?? 'No course package';
  int get safeCourseId => courseId ?? 0;
  String get safeCourseName => courseName ?? 'No course name';

  // Progress helpers
  bool get hasProgress => safeProgressCount > 0;
  String get progressSummary => '${safeProgressCount}% completed';
  bool get isCompleted => safeProgressCount >= 100;

  // Payment status helpers
  bool get isPaymentComplete => safePaymentStatus.toLowerCase().contains('paid');
  bool get isPaymentPending => safePaymentStatus.toLowerCase().contains('pending');
  bool get isNoPayment => safePaymentStatus.toLowerCase().contains('no payment');
  bool get hasPaymentDue => !isPaymentComplete;

  // Status color helpers
  String get paymentStatusColor {
    if (isPaymentComplete) return 'green';
    if (isPaymentPending) return 'orange';
    if (isNoPayment) return 'red';
    return 'gray';
  }

  // Batch summary
  String get batchSummary {
    final List<String> parts = [];
    if (hasValidCourseName) parts.add(safeCourseName);
    if (hasValidCoursePackageName) parts.add(safeCoursePackageName);
    if (hasValidBatchName) parts.add(safeBatchName);

    return parts.isNotEmpty ? parts.join(' • ') : 'No batch information';
  }

  // Short summary for lists
  String get shortSummary {
    if (hasValidBatchName && hasValidCourseName) {
      return '$safeBatchName - $safeCourseName';
    } else if (hasValidBatchName) {
      return safeBatchName!;
    } else if (hasValidCourseName) {
      return safeCourseName!;
    }
    return 'Unnamed Batch';
  }

  // Registration info
  String get registrationInfo {
    final List<String> info = [];
    if (hasValidRegNo) info.add('Reg: $safeRegNo');
    if (hasValidYear) info.add('Year: $safeYear');
    return info.join(' • ');
  }
}