// free_exam_list_public_model.dart

class FreeExamListPublicModel {
  final List<FreeExamPublicModel> items;

  FreeExamListPublicModel({required this.items});

  /// Build from a top-level JSON array (or a wrapped `data` array).
  factory FreeExamListPublicModel.fromJsonList(dynamic json) {
    if (json is List) {
      return FreeExamListPublicModel(
        items: json.map((e) => FreeExamPublicModel.fromJson(_asMap(e))).toList(),
      );
    }
    if (json is Map && json['data'] is List) {
      return FreeExamListPublicModel.fromJsonList(json['data']);
    }
    return FreeExamListPublicModel(items: const []);
  }

  /// Convert back to a JSON array.
  List<Map<String, dynamic>> toJsonList() {
    return items.map((e) => e.toJson()).toList();
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
}

class FreeExamPublicModel {
  final int? examId;
  final String? title;
  final CourseModel? course;

  FreeExamPublicModel({
    this.examId,
    this.title,
    this.course,
  });

  factory FreeExamPublicModel.fromJson(Map<String, dynamic> json) {
    return FreeExamPublicModel(
      examId: _parseInt(json['exam_id']),
      title: _parseString(json['title']),
      course: json['course'] == null
          ? null
          : CourseModel.fromJson(_asMap(json['course'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exam_id': examId,
      'title': title,
      'course': course?.toJson(),
    };
  }

  // -------- Convenience: has* checks --------
  bool get hasTitle => title != null && title!.isNotEmpty;
  bool get hasCourse => course != null;

  // -------- Convenience: safe getters --------
  int get safeExamId => examId ?? 0;
  String get safeTitle => title ?? '';
  CourseModel get safeCourse => course ?? CourseModel();
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

// Ensure dynamic is a Map<String, dynamic>
Map<String, dynamic> _asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) {
    return v.map((key, value) => MapEntry(key.toString(), value));
  }
  return <String, dynamic>{};
}
