// active_course_specialties_subjects_model.dart

class ActiveCourseSpecialtiesSubjectsModel {
  final List<ActiveCourse>? courses;

  ActiveCourseSpecialtiesSubjectsModel({
    this.courses,
  });

  /// API returns Map<String, dynamic>
  factory ActiveCourseSpecialtiesSubjectsModel.fromJson(
      Map<String, dynamic> json) {
    return ActiveCourseSpecialtiesSubjectsModel(
      courses: (json['courses'] as List<dynamic>?)
          ?.map((e) => ActiveCourse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courses': courses?.map((c) => c.toJson()).toList() ?? [],
    };
  }
}

class ActiveCourse {
  final int? courseId;
  final String? courseName;
  final List<Specialty>? specialties;

  ActiveCourse({
    this.courseId,
    this.courseName,
    this.specialties,
  });

  factory ActiveCourse.fromJson(Map<String, dynamic> json) {
    return ActiveCourse(
      courseId: json['course_id'],
      courseName: json['course_name'],
      specialties: (json['specialties'] as List<dynamic>?)
          ?.map((e) => Specialty.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'course_name': courseName,
      'specialties': specialties?.map((s) => s.toJson()).toList() ?? [],
    };
  }
}

class Specialty {
  final int? specialtyId;
  final String? specialtyName;
  final List<Subject>? subjects;

  Specialty({
    this.specialtyId,
    this.specialtyName,
    this.subjects,
  });

  factory Specialty.fromJson(Map<String, dynamic> json) {
    return Specialty(
      specialtyId: json['specialty_id'],
      specialtyName: json['specialty_name'],
      subjects: (json['subjects'] as List<dynamic>?)
          ?.map((e) => Subject.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'specialty_id': specialtyId,
      'specialty_name': specialtyName,
      'subjects': subjects?.map((s) => s.toJson()).toList() ?? [],
    };
  }
}

class Subject {
  final int? subjectId;
  final String? subjectName;
  final bool? isOpen;

  Subject({
    this.subjectId,
    this.subjectName,
    this.isOpen,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      subjectId: json['subject_id'],
      subjectName: json['subject_name'],
      isOpen: json['is_open'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject_id': subjectId,
      'subject_name': subjectName,
      'is_open': isOpen,
    };
  }
}