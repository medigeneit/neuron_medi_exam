// lib/data/models/doctor_profile_model.dart
import 'dart:convert';

class DoctorProfileModel {
  final bool? status;
  final Doctor? doctor;

  const DoctorProfileModel({
    this.status,
    this.doctor,
  });

  factory DoctorProfileModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DoctorProfileModel();
    return DoctorProfileModel(
      status: _toBool(json['status']),
      doctor: Doctor.fromJson(_toMap(json['doctor'])),
    );
  }

  /// Accepts either a Map or a JSON string.
  factory DoctorProfileModel.parse(dynamic source) {
    if (source == null) return const DoctorProfileModel();
    if (source is Map<String, dynamic>) return DoctorProfileModel.fromJson(source);
    if (source is String && source.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(source);
        if (decoded is Map<String, dynamic>) {
          return DoctorProfileModel.fromJson(decoded);
        }
      } catch (_) {}
    }
    return const DoctorProfileModel();
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'doctor': doctor?.toJson(),
  };

  DoctorProfileModel copyWith({
    bool? status,
    Doctor? doctor,
  }) =>
      DoctorProfileModel(
        status: status ?? this.status,
        doctor: doctor ?? this.doctor,
      );
}

class Doctor {
  final int? id;
  final String? name;
  final String? phoneNumber;
  final String? email;
  final bool? status;
  final String? photo;

  const Doctor({
    this.id,
    this.name,
    this.phoneNumber,
    this.email,
    this.status,
    this.photo,
  });

  factory Doctor.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const Doctor();
    return Doctor(
      id: _toInt(json['id']),
      name: _toStringOrNull(json['name']),
      phoneNumber: _toStringOrNull(json['phone_number']),
      email: _toStringOrNull(json['email']),
      status: _toBool(json['status']),
      photo: _toStringOrNull(json['photo']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone_number': phoneNumber,
    'email': email,
    'status': status,
    'photo': photo,
  };

  Doctor copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    String? email,
    bool? status,
    String? photo,
  }) =>
      Doctor(
        id: id ?? this.id,
        name: name ?? this.name,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        email: email ?? this.email,
        status: status ?? this.status,
        photo: photo ?? this.photo,
      );
}

/* -------------------------- Safe parsing helpers -------------------------- */

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return null;
    final n = int.tryParse(s);
    return n;
  }
  return null;
}

bool? _toBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final s = v.trim().toLowerCase();
    if (s.isEmpty) return null;
    if (['true', '1', 'yes', 'y'].contains(s)) return true;
    if (['false', '0', 'no', 'n'].contains(s)) return false;
  }
  return null;
}

String? _toStringOrNull(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

Map<String, dynamic>? _toMap(dynamic v) {
  if (v == null) return null;
  if (v is Map<String, dynamic>) return v;
  if (v is String && v.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(v);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
  }
  return null;
}
