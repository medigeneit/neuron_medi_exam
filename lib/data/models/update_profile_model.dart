// lib/data/models/update_profile_model.dart
import 'dart:convert';

/// Root response for "update profile" API.
class UpdateProfileResponse {
  /// Overall success flag (can be null if the server omitted or sent empty).
  final bool? status;

  /// Human-readable message (can be null/empty).
  final String? message;

  /// Updated doctor profile (can be null).
  final UpdateProfileDoctor? doctor;

  const UpdateProfileResponse({
    this.status,
    this.message,
    this.doctor,
  });

  /// Build from a raw JSON string. Returns null on parse failure.
  static UpdateProfileResponse? fromJsonString(String source) {
    try {
      final dynamic decoded = jsonDecode(source);
      if (decoded is Map<String, dynamic>) {
        return UpdateProfileResponse.fromJson(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Build from a JSON map (tolerant to nulls/empties).
  factory UpdateProfileResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const UpdateProfileResponse();
    }

    return UpdateProfileResponse(
      status: _asBool(json['status']),
      message: _asString(json['message']),
      doctor: (json['doctor'] is Map<String, dynamic>)
          ? UpdateProfileDoctor.fromJson(json['doctor'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert back to JSON (keeps nulls).
  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'doctor': doctor?.toJson(),
  };

  UpdateProfileResponse copyWith({
    bool? status,
    String? message,
    UpdateProfileDoctor? doctor,
  }) {
    return UpdateProfileResponse(
      status: status ?? this.status,
      message: message ?? this.message,
      doctor: doctor ?? this.doctor,
    );
  }
}

/// Doctor profile payload.
class UpdateProfileDoctor {
  final int? id;
  final String? name;
  final String? phoneNumber;
  final String? email;

  /// May be int, string, null, or empty -> coerced to int? (null if empty/invalid).
  final int? medicalCollegeId;

  /// Full URL or path; null if missing/empty.
  final String? photo;

  final bool? status;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const UpdateProfileDoctor({
    this.id,
    this.name,
    this.phoneNumber,
    this.email,
    this.medicalCollegeId,
    this.photo,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory UpdateProfileDoctor.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const UpdateProfileDoctor();
    }

    return UpdateProfileDoctor(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      phoneNumber: _asString(json['phone_number']),
      email: _asString(json['email']),
      medicalCollegeId: _asInt(json['medical_college_id']),
      photo: _asString(json['photo']),
      status: _asBool(json['status']),
      createdAt: _asDateTime(json['created_at']),
      updatedAt: _asDateTime(json['updated_at']),
      deletedAt: _asDateTime(json['deleted_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone_number': phoneNumber,
    'email': email,
    'medical_college_id': medicalCollegeId,
    'photo': photo,
    'status': status,
    'created_at': _dateToString(createdAt),
    'updated_at': _dateToString(updatedAt),
    'deleted_at': _dateToString(deletedAt),
  };

  UpdateProfileDoctor copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    String? email,
    int? medicalCollegeId,
    String? photo,
    bool? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return UpdateProfileDoctor(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      medicalCollegeId: medicalCollegeId ?? this.medicalCollegeId,
      photo: photo ?? this.photo,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

/* ------------------------- Robust parsing helpers ------------------------- */

String? _asString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) {
    final t = v.trim();
    if (t.isEmpty) return null;
    return int.tryParse(t);
  }
  return null;
}

bool? _asBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final t = v.trim().toLowerCase();
    if (t.isEmpty) return null;
    if (t == 'true' || t == '1' || t == 'yes' || t == 'y') return true;
    if (t == 'false' || t == '0' || t == 'no' || t == 'n') return false;
  }
  return null;
}

DateTime? _asDateTime(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String) {
    final t = v.trim();
    if (t.isEmpty) return null;
    try {
      return DateTime.parse(t);
    } catch (_) {
      return null;
    }
  }
  return null;
}

String? _dateToString(DateTime? dt) => dt?.toIso8601String();
