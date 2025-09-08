class BatchDetailsModel {
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

  // Helper method to parse integers with null/empty handling
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      if (value.isEmpty) return null;
      return int.tryParse(value);
    }
    if (value is double) return value.toInt();
    return null;
  }

  // Helper method to parse strings with null/empty handling
  static String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return value.isEmpty ? null : value;
    }
    return value.toString();
  }

  // Convenience methods to check if fields have meaningful values
  bool get hasBannerUrl => bannerUrl != null && bannerUrl!.isNotEmpty;
  bool get hasDescription => description != null && description!.isNotEmpty;
  bool get hasCourseOutline => courseOutline != null && courseOutline!.isNotEmpty;
  bool get hasCourseFeeOffer => courseFeeOffer != null && courseFeeOffer!.isNotEmpty;
  bool get hasRegistrationProcess => registrationProcess != null && registrationProcess!.isNotEmpty;
  bool get hasCoursePackageName => coursePackageName != null && coursePackageName!.isNotEmpty;

  // Convenience methods to get safe values with defaults
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