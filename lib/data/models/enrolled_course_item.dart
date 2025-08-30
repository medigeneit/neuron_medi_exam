import 'package:flutter/material.dart';

class EnrolledCourseItem {
  final String title;
  final String courseName;
  final String disciplineName;
  final String sessionName;
  final double progress;
  final String regNo;
  final CourseStatus status;
  final VoidCallback? onViewDetails;
  final VoidCallback? onContinue;

  const EnrolledCourseItem({
    required this.title,
    required this.courseName,
    required this.disciplineName,
    required this.sessionName,
    required this.progress,
    required this.regNo,
    required this.status,
    this.onViewDetails,
    this.onContinue,
  });
}

enum CourseStatus {
  active,
  unpaid,
  previous,
}

class DemoEnrolledCourses {
  static final List<EnrolledCourseItem> enrolledCourses = [
    EnrolledCourseItem(
      title: 'FCPS Part-1 Medicine',
      courseName: 'FCPS Part-1',
      disciplineName: 'Medicine',
      sessionName: 'Morning Session',
      progress: 0.65,
      regNo: 'REG-2025-001',
      status: CourseStatus.active,
    ),
    EnrolledCourseItem(
      title: 'BCS Health Full Course',
      courseName: 'BCS Health',
      disciplineName: 'Public Health',
      sessionName: 'Evening Session',
      progress: 0.25,
      regNo: 'REG-2025-002',
      status: CourseStatus.active,
    ),
    EnrolledCourseItem(
      title: 'FCPS Part-2 Surgery',
      courseName: 'FCPS Part-2',
      disciplineName: 'Surgery',
      sessionName: 'Weekend Session',
      progress: 0.0,
      regNo: 'REG-2025-003',
      status: CourseStatus.unpaid,
    ),
    EnrolledCourseItem(
      title: 'MRCP Part-1 Preparation',
      courseName: 'MRCP Part-1',
      disciplineName: 'Medicine',
      sessionName: 'Morning Session',
      progress: 1.0,
      regNo: 'REG-2024-001',
      status: CourseStatus.previous,
    ),
    EnrolledCourseItem(
      title: 'FCPS Part-1 Surgery',
      courseName: 'FCPS Part-1',
      disciplineName: 'Surgery',
      sessionName: 'Evening Session',
      progress: 0.0,
      regNo: 'REG-2025-004',
      status: CourseStatus.unpaid,
    ),
    EnrolledCourseItem(
      title: 'BCS Health Crash Course',
      courseName: 'BCS Health',
      disciplineName: 'Public Health',
      sessionName: 'Weekend Session',
      progress: 0.85,
      regNo: 'REG-2024-002',
      status: CourseStatus.previous,
    ),
    EnrolledCourseItem(
      title: 'FCPS Part-2 Medicine',
      courseName: 'FCPS Part-2',
      disciplineName: 'Medicine',
      sessionName: 'Morning Session',
      progress: 0.45,
      regNo: 'REG-2025-005',
      status: CourseStatus.active,
    ),
    EnrolledCourseItem(
      title: 'FCPS Part-1 Gynae & Obs',
      courseName: 'FCPS Part-1',
      disciplineName: 'Gynaecology & Obstetrics',
      sessionName: 'Evening Session',
      progress: 1.0,
      regNo: 'REG-2024-003',
      status: CourseStatus.previous,
    ),
  ];

  // Helper method to get courses by status
  static List<EnrolledCourseItem> getCoursesByStatus(CourseStatus status) {
    return enrolledCourses.where((course) => course.status == status).toList();
  }

  // Get active courses
  static List<EnrolledCourseItem> get activeCourses =>
      getCoursesByStatus(CourseStatus.active);

  // Get unpaid courses
  static List<EnrolledCourseItem> get unpaidCourses =>
      getCoursesByStatus(CourseStatus.unpaid);

  // Get previous courses
  static List<EnrolledCourseItem> get previousCourses =>
      getCoursesByStatus(CourseStatus.previous);
}