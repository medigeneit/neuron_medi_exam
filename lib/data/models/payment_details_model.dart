class PaymentDetailsModel {
  final Admission? admission;
  final List<PaymentGateway>? paymentGateways;

  PaymentDetailsModel({
    this.admission,
    this.paymentGateways,
  });

  factory PaymentDetailsModel.fromJson(Map<String, dynamic> json) {
    return PaymentDetailsModel(
      admission: json['admission'] is Map<String, dynamic>
          ? Admission.fromJson(json['admission'] as Map<String, dynamic>)
          : null,
      // NOTE: API key remains `payment_getway`
      paymentGateways: json['payment_getway'] is List
          ? (json['payment_getway'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => PaymentGateway.fromJson(e))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admission': admission?.toJson(),
      'payment_getway':
      paymentGateways?.map((gateway) => gateway.toJson()).toList(),
    };
  }

  bool get isEmpty =>
      (admission == null || admission!.isEmpty) &&
          (paymentGateways == null || paymentGateways!.isEmpty);

  bool get isNotEmpty =>
      (admission != null && admission!.isNotEmpty) ||
          (paymentGateways != null && paymentGateways!.isNotEmpty);

  // Helper methods
  bool get hasValidAdmission => admission != null && admission!.isNotEmpty;
  bool get hasValidPaymentGateways =>
      paymentGateways != null && paymentGateways!.isNotEmpty;
  bool get isValidForDisplay => hasValidAdmission && hasValidPaymentGateways;

  // Safe getters with fallbacks
  Admission get safeAdmission => admission ?? Admission();
  List<PaymentGateway> get safePaymentGateways => paymentGateways ?? [];
}

class Admission {
  final int? id;
  final String? regNo;
  final String? year;
  final int? batchId;
  final int? batchPackageId;
  final String? paymentStatus;
  final String? batchName;

  // NEW FIELDS from API
  final String? startDate;   // e.g. "2025-09-20"
  final String? examDays;    // e.g. "Everyday"
  final String? examTime;    // e.g. "10:00 AM"
  final String? bannerUrl;   // full URL

  final int? coursePackageId;
  final String? coursePackageName;
  final int? courseId;
  final String? courseName;
  final double? coursePrice;
  final String? doctorDiscountTitle;
  final double? doctorDiscountAmount;
  final double? totalAmount;
  final double? paidAmount;
  final double? payableAmount;

  Admission({
    this.id,
    this.regNo,
    this.year,
    this.batchId,
    this.batchPackageId,
    this.paymentStatus,
    this.batchName,
    this.startDate,
    this.examDays,
    this.examTime,
    this.bannerUrl,
    this.coursePackageId,
    this.coursePackageName,
    this.courseId,
    this.courseName,
    this.coursePrice,
    this.doctorDiscountTitle,
    this.doctorDiscountAmount,
    this.totalAmount,
    this.paidAmount,
    this.payableAmount,
  });

  factory Admission.fromJson(Map<String, dynamic> json) {
    return Admission(
      id: json['id'] is int ? json['id'] as int : null,
      regNo: json['reg_no'] is String ? json['reg_no'] as String : null,
      year: json['year'] is String ? json['year'] as String : null,
      batchId: json['batch_id'] is int ? json['batch_id'] as int : null,
      batchPackageId:
      json['batch_package_id'] is int ? json['batch_package_id'] as int : null,
      paymentStatus: json['payment_status'] is String
          ? json['payment_status'] as String
          : null,
      batchName:
      json['batch_name'] is String ? json['batch_name'] as String : null,

      // NEW FIELDS
      startDate:
      json['start_date'] is String ? json['start_date'] as String : null,
      examDays: json['exam_days'] is String ? json['exam_days'] as String : null,
      examTime: json['exam_time'] is String ? json['exam_time'] as String : null,
      bannerUrl:
      json['banner_url'] is String ? json['banner_url'] as String : null,

      coursePackageId:
      json['course_package_id'] is int ? json['course_package_id'] as int : null,
      coursePackageName: json['course_package_name'] is String
          ? json['course_package_name'] as String
          : null,
      courseId: json['course_id'] is int ? json['course_id'] as int : null,
      courseName:
      json['course_name'] is String ? json['course_name'] as String : null,
      coursePrice: json['course_price'] is num
          ? (json['course_price'] as num).toDouble()
          : null,
      doctorDiscountTitle: json['doctor_discount_title'] is String
          ? json['doctor_discount_title'] as String
          : null,
      doctorDiscountAmount: json['doctor_discount_amount'] is num
          ? (json['doctor_discount_amount'] as num).toDouble()
          : null,
      totalAmount: json['total_amount'] is num
          ? (json['total_amount'] as num).toDouble()
          : null,
      paidAmount: json['paid_amount'] is num
          ? (json['paid_amount'] as num).toDouble()
          : null,
      payableAmount: json['payable_amount'] is num
          ? (json['payable_amount'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reg_no': regNo,
      'year': year,
      'batch_id': batchId,
      'batch_package_id': batchPackageId,
      'payment_status': paymentStatus,
      'batch_name': batchName,

      // NEW FIELDS
      'start_date': startDate,
      'exam_days': examDays,
      'exam_time': examTime,
      'banner_url': bannerUrl,

      'course_package_id': coursePackageId,
      'course_package_name': coursePackageName,
      'course_id': courseId,
      'course_name': courseName,
      'course_price': coursePrice,
      'doctor_discount_title': doctorDiscountTitle,
      'doctor_discount_amount': doctorDiscountAmount,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'payable_amount': payableAmount,
    };
  }

  bool get isEmpty =>
      (id == null || id! <= 0) &&
          (regNo?.isEmpty ?? true) &&
          (year?.isEmpty ?? true) &&
          (batchId == null || batchId! <= 0) &&
          (batchPackageId == null || batchPackageId! <= 0) &&
          (paymentStatus?.isEmpty ?? true) &&
          (batchName?.isEmpty ?? true) &&
          // NEW FIELDS
          (startDate?.isEmpty ?? true) &&
          (examDays?.isEmpty ?? true) &&
          (examTime?.isEmpty ?? true) &&
          (bannerUrl?.isEmpty ?? true) &&
          //
          (coursePackageId == null || coursePackageId! <= 0) &&
          (coursePackageName?.isEmpty ?? true) &&
          (courseId == null || courseId! <= 0) &&
          (courseName?.isEmpty ?? true) &&
          (coursePrice == null || coursePrice! <= 0) &&
          (doctorDiscountTitle?.isEmpty ?? true) &&
          (doctorDiscountAmount == null || doctorDiscountAmount! <= 0) &&
          (totalAmount == null || totalAmount! <= 0) &&
          (paidAmount == null || paidAmount! <= 0) &&
          (payableAmount == null || payableAmount! <= 0);

  bool get isNotEmpty =>
      (id != null && id! > 0) ||
          (regNo?.isNotEmpty ?? false) ||
          (year?.isNotEmpty ?? false) ||
          (batchId != null && batchId! > 0) ||
          (batchPackageId != null && batchPackageId! > 0) ||
          (paymentStatus?.isNotEmpty ?? false) ||
          (batchName?.isNotEmpty ?? false) ||
          // NEW FIELDS
          (startDate?.isNotEmpty ?? false) ||
          (examDays?.isNotEmpty ?? false) ||
          (examTime?.isNotEmpty ?? false) ||
          (bannerUrl?.isNotEmpty ?? false) ||
          //
          (coursePackageId != null && coursePackageId! > 0) ||
          (coursePackageName?.isNotEmpty ?? false) ||
          (courseId != null && courseId! > 0) ||
          (courseName?.isNotEmpty ?? false) ||
          (coursePrice != null && coursePrice! > 0) ||
          (doctorDiscountTitle?.isNotEmpty ?? false) ||
          (doctorDiscountAmount != null && doctorDiscountAmount! > 0) ||
          (totalAmount != null && totalAmount! > 0) ||
          (paidAmount != null && paidAmount! > 0) ||
          (payableAmount != null && payableAmount! > 0);

  // Helper methods (existing)
  bool get hasValidId => id != null && id! > 0;
  bool get hasValidRegNo => regNo != null && regNo!.isNotEmpty;
  bool get hasValidYear => year != null && year!.isNotEmpty;
  bool get hasValidBatchId => batchId != null && batchId! > 0;
  bool get hasValidBatchPackageId => batchPackageId != null && batchPackageId! > 0;
  bool get hasValidPaymentStatus =>
      paymentStatus != null && paymentStatus!.isNotEmpty;
  bool get hasValidBatchName => batchName != null && batchName!.isNotEmpty;

  // NEW helpers
  bool get hasValidStartDate => startDate != null && startDate!.isNotEmpty;
  bool get hasValidExamDays => examDays != null && examDays!.isNotEmpty;
  bool get hasValidExamTime => examTime != null && examTime!.isNotEmpty;
  bool get hasValidBannerUrl => bannerUrl != null && bannerUrl!.isNotEmpty;

  bool get hasValidCoursePackageId =>
      coursePackageId != null && coursePackageId! > 0;
  bool get hasValidCoursePackageName =>
      coursePackageName != null && coursePackageName!.isNotEmpty;
  bool get hasValidCourseId => courseId != null && courseId! > 0;
  bool get hasValidCourseName => courseName != null && courseName!.isNotEmpty;
  bool get hasValidCoursePrice => coursePrice != null && coursePrice! >= 0;
  bool get hasValidDoctorDiscountTitle =>
      doctorDiscountTitle != null && doctorDiscountTitle!.isNotEmpty;
  bool get hasValidDoctorDiscountAmount =>
      doctorDiscountAmount != null && doctorDiscountAmount! >= 0;
  bool get hasValidTotalAmount => totalAmount != null && totalAmount! >= 0;
  bool get hasValidPaidAmount => paidAmount != null && paidAmount! >= 0;
  bool get hasValidPayableAmount => payableAmount != null && payableAmount! >= 0;
  bool get isFullyPaid => safePaidAmount >= safePayableAmount;
  bool get hasPaymentDue => safePayableAmount > 0;

  // Safe getters with fallbacks
  int get safeId => id ?? 0;
  String get safeRegNo => regNo ?? 'No registration number';
  String get safeYear => year ?? 'No year';
  int get safeBatchId => batchId ?? 0;
  int get safeBatchPackageId => batchPackageId ?? 0;
  String get safePaymentStatus => paymentStatus ?? 'No payment status';
  String get safeBatchName => batchName ?? 'No batch name';

  // NEW safe getters
  String get safeStartDate => startDate ?? '';
  String get safeExamDays => examDays ?? '';
  String get safeExamTime => examTime ?? '';
  String get safeBannerUrl => bannerUrl ?? '';

  int get safeCoursePackageId => coursePackageId ?? 0;
  String get safeCoursePackageName => coursePackageName ?? 'No course package';
  int get safeCourseId => courseId ?? 0;
  String get safeCourseName => courseName ?? 'No course name';
  double get safeCoursePrice => coursePrice ?? 0.0;
  String get safeDoctorDiscountTitle => doctorDiscountTitle ?? 'No discount';
  double get safeDoctorDiscountAmount => doctorDiscountAmount ?? 0.0;
  double get safeTotalAmount => totalAmount ?? 0.0;
  double get safePaidAmount => paidAmount ?? 0.0;
  double get safePayableAmount => payableAmount ?? 0.0;

  // Convenience parsing
  DateTime? get parsedStartDate {
    try {
      return hasValidStartDate ? DateTime.tryParse(startDate!) : null;
    } catch (_) {
      return null;
    }
  }

  Uri? get bannerUri {
    try {
      return hasValidBannerUrl ? Uri.tryParse(bannerUrl!) : null;
    } catch (_) {
      return null;
    }
  }

  // Price formatting helpers
  String get formattedCoursePrice => '৳${safeCoursePrice.toStringAsFixed(2)}';
  String get formattedDoctorDiscountAmount =>
      '৳${safeDoctorDiscountAmount.toStringAsFixed(2)}';
  String get formattedTotalAmount => '৳${safeTotalAmount.toStringAsFixed(2)}';
  String get formattedPaidAmount => '৳${safePaidAmount.toStringAsFixed(2)}';
  String get formattedPayableAmount =>
      '৳${safePayableAmount.toStringAsFixed(2)}';

  // Payment status helpers
  bool get isPaymentComplete =>
      safePaymentStatus.toLowerCase().contains('paid') || isFullyPaid;
  bool get isPaymentPending =>
      safePaymentStatus.toLowerCase().contains('pending') || hasPaymentDue;
  bool get isNoPayment => safePaymentStatus.toLowerCase().contains('no payment');
}

class PaymentGateway {
  final String? name;
  final String? vendor;

  PaymentGateway({
    this.name,
    this.vendor,
  });

  factory PaymentGateway.fromJson(Map<String, dynamic> json) {
    return PaymentGateway(
      name: json['name'] is String ? json['name'] as String : null,
      vendor: json['vendor'] is String ? json['vendor'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'vendor': vendor,
    };
  }

  bool get isEmpty => (name?.isEmpty ?? true) && (vendor?.isEmpty ?? true);

  bool get isNotEmpty => (name?.isNotEmpty ?? false) || (vendor?.isNotEmpty ?? false);

  // Helper methods
  bool get hasValidName => name != null && name!.isNotEmpty;
  bool get hasValidVendor => vendor != null && vendor!.isNotEmpty;

  String get safeName => name ?? 'Unknown Gateway';
  String get safeVendor => vendor ?? 'unknown';

  // Vendor type helpers
  bool get isBkash => safeVendor.toLowerCase() == 'bkash';
  bool get isSslCommerz => safeVendor.toLowerCase() == 'sslcommerz';
  bool get isNagad => safeVendor.toLowerCase() == 'nagad';
}
