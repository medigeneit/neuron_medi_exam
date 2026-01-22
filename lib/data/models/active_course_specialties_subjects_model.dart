// active_course_specialties_subjects_model.dart

class ActiveCourseSpecialtiesSubjectsModel {
  final List<ActiveCourse>? courses;
  final List<Subject>? subjects;

  ActiveCourseSpecialtiesSubjectsModel({
    this.courses,
    this.subjects,
  });

  /// API returns Map<String, dynamic>
  factory ActiveCourseSpecialtiesSubjectsModel.fromJson(
      Map<String, dynamic> json) {
    return ActiveCourseSpecialtiesSubjectsModel(
      courses: (json['courses'] as List<dynamic>?)
          ?.map((e) => ActiveCourse.fromJson(e as Map<String, dynamic>))
          .toList(),
      subjects: (json['subjects'] as List<dynamic>?)
          ?.map((e) => Subject.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courses': courses?.map((c) => c.toJson()).toList() ?? [],
      'subjects': subjects?.map((s) => s.toJson()).toList() ?? [],
    };
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
      'specialty': specialty?.map((s) => s.toJson()).toList() ?? [],
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

class Subject {
  final int? subjectId;
  final String? subjectName;

  Subject({
    this.subjectId,
    this.subjectName,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      subjectId: json['subject_id'],
      subjectName: json['subject_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject_id': subjectId,
      'subject_name': subjectName,
    };
  }
}
