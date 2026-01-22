class ActiveCourseSpecialtiesModel {
  final List<ActiveCourse>? courses;

  ActiveCourseSpecialtiesModel({this.courses});

  /// API returns List<dynamic>
  factory ActiveCourseSpecialtiesModel.fromJson(List<dynamic> json) {
    return ActiveCourseSpecialtiesModel(
      courses: json.map((e) => ActiveCourse.fromJson(e)).toList(),
    );
  }

  List<dynamic> toJson() {
    return courses?.map((c) => c.toJson()).toList() ?? [];
  }
}

class ActiveCourse {
  final int? courseId;
  final String? courseName;
  final List<Specialty>? specialty;

  ActiveCourse({
    this.courseId,
    this.courseName,
    this.specialty,
  });

  factory ActiveCourse.fromJson(Map<String, dynamic> json) {
    return ActiveCourse(
      courseId: json['course_id'],
      courseName: json['course_name'],
      specialty: (json['specialty'] as List<dynamic>?)
          ?.map((e) => Specialty.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'course_name': courseName,
      'specialty': specialty?.map((s) => s.toJson()).toList(),
    };
  }
}

class Specialty {
  final int? specialtyId;
  final String? specialtyName;

  Specialty({
    this.specialtyId,
    this.specialtyName,
  });

  factory Specialty.fromJson(Map<String, dynamic> json) {
    return Specialty(
      specialtyId: json['specialty_id'],
      specialtyName: json['specialty_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'specialty_id': specialtyId,
      'specialty_name': specialtyName,
    };
  }
}
