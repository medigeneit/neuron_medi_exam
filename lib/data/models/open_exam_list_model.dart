class OpenExamListModel {
  final List<OpenExamModel> items;

  OpenExamListModel({required this.items});

  /// Build from a top-level JSON array (or a wrapped `data` array).
  factory OpenExamListModel.fromJsonList(dynamic json) {
    if (json is List) {
      return OpenExamListModel(
        items: json.map((e) => OpenExamModel.fromJson(_asMap(e))).toList(),
      );
    }
    if (json is Map && json['data'] is List) {
      return OpenExamListModel.fromJsonList(json['data']);
    }
    return OpenExamListModel(items: const []);
  }

  /// Convert back to a JSON array.
  List<Map<String, dynamic>> toJsonList() {
    return items.map((e) => e.toJson()).toList();
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
}

class OpenExamModel {
  final int? examId;
  final String? title;
  final CourseModel? course;

  /// Public endpoint: includes `is_pinned`
  /// Doctor endpoint: also includes `is_pinned`
  final bool? isPinned;

  /// Doctor endpoint: can be null or list
  final List<DoctorOpenExamModel>? doctorOpenExam;

  OpenExamModel({
    this.examId,
    this.title,
    this.course,
    this.isPinned,
    this.doctorOpenExam,
  });

  factory OpenExamModel.fromJson(Map<String, dynamic> json) {
    return OpenExamModel(
      examId: _parseInt(json['exam_id']),
      title: _parseString(json['title']),
      course: json['course'] == null
          ? null
          : CourseModel.fromJson(_asMap(json['course'])),
      isPinned: _parseBool(json['is_pinned']),
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
      'is_pinned': isPinned,
      'doctor_open_exam': doctorOpenExam?.map((e) => e.toJson()).toList(),
    };
  }

  // -------- Convenience --------
  bool get hasTitle => title != null && title!.isNotEmpty;
  bool get hasCourse => course != null;

  bool get safeIsPinned => isPinned ?? false;

  bool get hasDoctorOpenExam =>
      doctorOpenExam != null && doctorOpenExam!.isNotEmpty;

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

  bool get hasStatus => status != null && status!.isNotEmpty;
  int get safeId => id ?? 0;
  int get safeExamId => examId ?? 0;
  int get safeDoctorId => doctorId ?? 0;
  String get safeStatus => status ?? '';
}

// ----------------- Shared helpers -----------------

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

String? _parseString(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  return value.toString();
}

bool? _parseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) {
    final v = value.trim().toLowerCase();
    if (v == 'true' || v == '1' || v == 'yes') return true;
    if (v == 'false' || v == '0' || v == 'no') return false;
  }
  return null;
}

List<T>? _parseList<T>(dynamic value, T Function(dynamic) mapper) {
  if (value == null) return null;
  if (value is List) {
    return value.map(mapper).toList();
  }
  return null;
}

Map<String, dynamic> _asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) {
    return v.map((key, value) => MapEntry(key.toString(), value));
  }
  return <String, dynamic>{};
}