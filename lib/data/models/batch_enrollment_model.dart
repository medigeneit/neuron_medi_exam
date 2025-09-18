class BatchEnrollmentModel {
  final bool? isEnroll;
  final String? message;
  final Admission? admission;

  BatchEnrollmentModel({
    this.isEnroll,
    this.message,
    this.admission,
  });

  factory BatchEnrollmentModel.fromJson(Map<String, dynamic> json) {
    return BatchEnrollmentModel(
      isEnroll: json['is_enroll'] is bool ? json['is_enroll'] : null,
      message: json['message'] is String ? json['message'] : null,
      admission: json['admission'] is Map<String, dynamic>
          ? Admission.fromJson(json['admission'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_enroll': isEnroll,
      'message': message,
      'admission': admission?.toJson(),
    };
  }

  bool get isEmpty =>
      (isEnroll == null) &&
          (message?.isEmpty ?? true) &&
          (admission == null || admission!.isEmpty);

  bool get isNotEmpty =>
      (isEnroll != null) ||
          (message?.isNotEmpty ?? false) ||
          (admission != null && admission!.isNotEmpty);

  // Helper methods
  bool get hasValidEnrollment => isEnroll == true;
  bool get hasValidMessage => message != null && message!.isNotEmpty;
  bool get hasValidAdmission => admission != null && admission!.isNotEmpty;
  bool get isValidForDisplay => hasValidEnrollment && hasValidAdmission;

  // Safe getters with fallbacks
  bool get safeIsEnroll => isEnroll ?? false;
  String get safeMessage => message ?? 'No message';
  Admission get safeAdmission => admission ?? Admission();
}

class Admission {
  final int? doctorId;
  final String? regNo;
  final int? yearAdmissionCount;
  final int? year;
  final int? batchId;
  final int? batchPackageId;
  final String? updatedAt;
  final String? createdAt;
  final int? id;
  final double? coursePrice;
  final String? doctorDiscountTitle;
  final double? doctorDiscountAmount;
  final double? totalAmount;

  Admission({
    this.doctorId,
    this.regNo,
    this.yearAdmissionCount,
    this.year,
    this.batchId,
    this.batchPackageId,
    this.updatedAt,
    this.createdAt,
    this.id,
    this.coursePrice,
    this.doctorDiscountTitle,
    this.doctorDiscountAmount,
    this.totalAmount,
  });

  factory Admission.fromJson(Map<String, dynamic> json) {
    return Admission(
      doctorId: json['doctor_id'] is int ? json['doctor_id'] : null,
      regNo: json['reg_no'] is String ? json['reg_no'] : null,
      yearAdmissionCount: json['year_admission_count'] is int
          ? json['year_admission_count']
          : null,
      year: json['year'] is int ? json['year'] : null,
      batchId: json['batch_id'] is int ? json['batch_id'] : null,
      batchPackageId:
      json['batch_package_id'] is int ? json['batch_package_id'] : null,
      updatedAt: json['updated_at'] is String ? json['updated_at'] : null,
      createdAt: json['created_at'] is String ? json['created_at'] : null,
      id: json['id'] is int ? json['id'] : null,
      coursePrice: json['course_price'] is num
          ? (json['course_price'] as num).toDouble()
          : null,
      doctorDiscountTitle: json['doctor_discount_title'] is String
          ? json['doctor_discount_title']
          : null,
      doctorDiscountAmount: json['doctor_discount_amount'] is num
          ? (json['doctor_discount_amount'] as num).toDouble()
          : null,
      totalAmount: json['total_amount'] is num
          ? (json['total_amount'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctor_id': doctorId,
      'reg_no': regNo,
      'year_admission_count': yearAdmissionCount,
      'year': year,
      'batch_id': batchId,
      'batch_package_id': batchPackageId,
      'updated_at': updatedAt,
      'created_at': createdAt,
      'id': id,
      'course_price': coursePrice,
      'doctor_discount_title': doctorDiscountTitle,
      'doctor_discount_amount': doctorDiscountAmount,
      'total_amount': totalAmount,
    };
  }

  bool get isEmpty =>
      (doctorId == null || doctorId! <= 0) &&
          (regNo?.isEmpty ?? true) &&
          (yearAdmissionCount == null || yearAdmissionCount! <= 0) &&
          (year == null || year! <= 0) &&
          (batchId == null || batchId! <= 0) &&
          (batchPackageId == null || batchPackageId! <= 0) &&
          (updatedAt?.isEmpty ?? true) &&
          (createdAt?.isEmpty ?? true) &&
          (id == null || id! <= 0) &&
          (coursePrice == null || coursePrice! <= 0) &&
          (doctorDiscountTitle?.isEmpty ?? true) &&
          (doctorDiscountAmount == null || doctorDiscountAmount! <= 0) &&
          (totalAmount == null || totalAmount! <= 0);

  bool get isNotEmpty =>
      (doctorId != null && doctorId! > 0) ||
          (regNo?.isNotEmpty ?? false) ||
          (yearAdmissionCount != null && yearAdmissionCount! > 0) ||
          (year != null && year! > 0) ||
          (batchId != null && batchId! > 0) ||
          (batchPackageId != null && batchPackageId! > 0) ||
          (updatedAt?.isNotEmpty ?? false) ||
          (createdAt?.isNotEmpty ?? false) ||
          (id != null && id! > 0) ||
          (coursePrice != null && coursePrice! > 0) ||
          (doctorDiscountTitle?.isNotEmpty ?? false) ||
          (doctorDiscountAmount != null && doctorDiscountAmount! > 0) ||
          (totalAmount != null && totalAmount! > 0);

  // Helper methods
  bool get hasValidDoctorId => doctorId != null && doctorId! > 0;
  bool get hasValidRegNo => regNo != null && regNo!.isNotEmpty;
  bool get hasValidYearAdmissionCount =>
      yearAdmissionCount != null && yearAdmissionCount! > 0;
  bool get hasValidYear => year != null && year! > 0;
  bool get hasValidBatchId => batchId != null && batchId! > 0;
  bool get hasValidBatchPackageId =>
      batchPackageId != null && batchPackageId! > 0;
  bool get hasValidUpdatedAt => updatedAt != null && updatedAt!.isNotEmpty;
  bool get hasValidCreatedAt => createdAt != null && createdAt!.isNotEmpty;
  bool get hasValidId => id != null && id! > 0;
  bool get hasValidCoursePrice => coursePrice != null && coursePrice! >= 0;
  bool get hasValidDoctorDiscountTitle =>
      doctorDiscountTitle != null && doctorDiscountTitle!.isNotEmpty;
  bool get hasValidDoctorDiscountAmount =>
      doctorDiscountAmount != null && doctorDiscountAmount! >= 0;
  bool get hasValidTotalAmount => totalAmount != null && totalAmount! >= 0;
  bool get isValidForDisplay => hasValidId && hasValidBatchId;

  // Safe getters with fallbacks
  int get safeDoctorId => doctorId ?? 0;
  String get safeRegNo => regNo ?? 'No registration number';
  int get safeYearAdmissionCount => yearAdmissionCount ?? 0;
  int get safeYear => year ?? DateTime.now().year;
  int get safeBatchId => batchId ?? 0;
  int get safeBatchPackageId => batchPackageId ?? 0;
  String get safeUpdatedAt => updatedAt ?? 'No update date';
  String get safeCreatedAt => createdAt ?? 'No creation date';
  int get safeId => id ?? 0;
  double get safeCoursePrice => coursePrice ?? 0.0;
  String get safeDoctorDiscountTitle =>
      doctorDiscountTitle ?? 'No discount title';
  double get safeDoctorDiscountAmount => doctorDiscountAmount ?? 0.0;
  double get safeTotalAmount => totalAmount ?? 0.0;

  // Date formatting helpers
  String get formattedCreatedAt {
    if (createdAt == null || createdAt!.isEmpty) return 'No date';
    try {
      final date = DateTime.parse(createdAt!);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return createdAt!;
    }
  }

  String get formattedUpdatedAt {
    if (updatedAt == null || updatedAt!.isEmpty) return 'No date';
    try {
      final date = DateTime.parse(updatedAt!);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return updatedAt!;
    }
  }

  // Price formatting helpers
  String get formattedCoursePrice {
    return '৳${safeCoursePrice.toStringAsFixed(2)}';
  }

  String get formattedDoctorDiscountAmount {
    return '৳${safeDoctorDiscountAmount.toStringAsFixed(2)}';
  }

  String get formattedTotalAmount {
    return '৳${safeTotalAmount.toStringAsFixed(2)}';
  }

  // Discount summary
  String get discountSummary {
    if (!hasValidDoctorDiscountTitle && safeDoctorDiscountAmount <= 0) {
      return 'No discount applied';
    }
    if (!hasValidDoctorDiscountTitle) {
      return 'Discount: ${formattedDoctorDiscountAmount}';
    }
    if (safeDoctorDiscountAmount <= 0) {
      return safeDoctorDiscountTitle;
    }
    return '$safeDoctorDiscountTitle: ${formattedDoctorDiscountAmount}';
  }
}