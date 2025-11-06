// free_exam_list_model.dart
//
// Matches your previous model style: robust parsing helpers,
// has*/safe* getters, fromJson/toJson, and graceful null handling.

class FreeExamListModel {
  final List<FreeExamModel> items;

  FreeExamListModel({required this.items});

  /// Build from a top-level JSON array (or a wrapped `data` array).
  factory FreeExamListModel.fromJsonList(dynamic json) {
    if (json is List) {
      return FreeExamListModel(
        items: json.map((e) => FreeExamModel.fromJson(_asMap(e))).toList(),
      );
    }
    if (json is Map && json['data'] is List) {
      return FreeExamListModel.fromJsonList(json['data']);
    }
    return FreeExamListModel(items: const []);
  }

  /// Convert back to a JSON array.
  List<Map<String, dynamic>> toJsonList() {
    return items.map((e) => e.toJson()).toList();
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
}

class FreeExamModel {
  final int? examId;
  final String? title;
  final CourseModel? course;
  /// May be null (server can send `null`) or a list.
  final List<DoctorOpenExamModel>? doctorOpenExam;

  FreeExamModel({
    this.examId,
    this.title,
    this.course,
    this.doctorOpenExam,
  });

  factory FreeExamModel.fromJson(Map<String, dynamic> json) {
    return FreeExamModel(
      examId: _parseInt(json['exam_id']),
      title: _parseString(json['title']),
      course: json['course'] == null
          ? null
          : CourseModel.fromJson(_asMap(json['course'])),
      doctorOpenExam: _parseList<DoctorOpenExamModel>(
        json['doctor_open_exam'],
            (e) => DoctorOpenExamModel.fromJson(_asMap(e)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exam_id': examId,
      'title': title,
      'course': course?.toJson(),
      'doctor_open_exam': doctorOpenExam?.map((e) => e.toJson()).toList(),
    };
  }

  // -------- Convenience: has* checks --------
  bool get hasTitle => title != null && title!.isNotEmpty;
  bool get hasCourse => course != null;
  bool get hasDoctorOpenExam =>
      doctorOpenExam != null && doctorOpenExam!.isNotEmpty;

  // -------- Convenience: safe getters --------
  int get safeExamId => examId ?? 0;
  String get safeTitle => title ?? '';
  CourseModel get safeCourse => course ?? CourseModel();
  List<DoctorOpenExamModel> get safeDoctorOpenExam =>
      doctorOpenExam ?? const [];
}

class CourseModel {
  final int? id;
  final String? name;

  CourseModel({this.id, this.name});

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: _parseInt(json['id']),
      name: _parseString(json['name']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  // Convenience
  bool get hasName => name != null && name!.isNotEmpty;
  int get safeId => id ?? 0;
  String get safeName => name ?? '';
}

class DoctorOpenExamModel {
  final int? id;
  final int? examId;
  final int? doctorId;
  final String? status;

  DoctorOpenExamModel({
    this.id,
    this.examId,
    this.doctorId,
    this.status,
  });

  factory DoctorOpenExamModel.fromJson(Map<String, dynamic> json) {
    return DoctorOpenExamModel(
      id: _parseInt(json['id']),
      examId: _parseInt(json['exam_id']),
      doctorId: _parseInt(json['doctor_id']),
      status: _parseString(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exam_id': examId,
      'doctor_id': doctorId,
      'status': status,
    };
  }

  // Convenience
  bool get hasStatus => status != null && status!.isNotEmpty;
  int get safeId => id ?? 0;
  int get safeExamId => examId ?? 0;
  int get safeDoctorId => doctorId ?? 0;
  String get safeStatus => status ?? '';
}

// ----------------- Shared helpers (same pattern as your previous model) -----------------

// Parse integers with null/empty handling
int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) {
    final v = value.trim();
    if (v.isEmpty) return null;
    return int.tryParse(v);
  }
  if (value is double) return value.toInt();
  return null;
}

// Parse strings with null/empty handling
String? _parseString(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  return value.toString();
}

// Safely parse lists (returns null if source is null or not a List)
List<T>? _parseList<T>(dynamic value, T Function(dynamic) mapper) {
  if (value == null) return null;
  if (value is List) {
    return value.map(mapper).toList();
  }
  return null;
}

// Ensure dynamic is a Map<String, dynamic>
Map<String, dynamic> _asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) {
    return v.map((key, value) => MapEntry(key.toString(), value));
  }
  return <String, dynamic>{};
}
