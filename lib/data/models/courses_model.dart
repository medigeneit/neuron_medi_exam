class CoursesModel {
  final List<Course>? courses;

  CoursesModel({
    this.courses,
  });

  factory CoursesModel.fromJson(List<dynamic> json) {
    return CoursesModel(
      courses: json.map((e) => Course.fromJson(e)).toList(),
    );
  }

  List<dynamic> toJson() {
    return courses?.map((course) => course.toJson()).toList() ?? [];
  }
}

class Course {
  final int? courseId;
  final String? courseName;
  final List<Package>? package;

  Course({
    this.courseId,
    this.courseName,
    this.package,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseId: json['course_id'],
      courseName: json['course_name'],
      package: (json['package'] as List<dynamic>?)?.map((e) => Package.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'course_name': courseName,
      'package': package?.map((pkg) => pkg.toJson()).toList(),
    };
  }
}

class Package {
  final int? packageId;
  final String? packageName;

  Package({
    this.packageId,
    this.packageName,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      packageId: json['package_id'],
      packageName: json['package_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'package_id': packageId,
      'package_name': packageName,
    };
  }
}