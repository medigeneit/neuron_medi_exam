import 'package:flutter/material.dart';

class CareerGuidelinesListModel {
  final List<CareerGuideline>? careerGuidelines;

  CareerGuidelinesListModel({
    this.careerGuidelines,
  });

  factory CareerGuidelinesListModel.fromJson(Map<String, dynamic> json) {
    return CareerGuidelinesListModel(
      careerGuidelines: json['data'] is List
          ? (json['data'] as List)
          .map((e) => CareerGuideline.fromJson(e))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': careerGuidelines
          ?.map((careerGuideline) => careerGuideline.toJson())
          .toList(),
    };
  }

  bool get isEmpty =>
      careerGuidelines == null || careerGuidelines!.isEmpty;

  bool get isNotEmpty =>
      careerGuidelines != null && careerGuidelines!.isNotEmpty;

  bool get hasValidCareerGuidelines =>
      careerGuidelines != null && careerGuidelines!.isNotEmpty;

  bool get isValidForDisplay => hasValidCareerGuidelines;

  List<CareerGuideline> get safeCareerGuidelines => careerGuidelines ?? [];

  List<CareerGuideline> get activeCareerGuidelines =>
      safeCareerGuidelines.where((item) => item.safeIsActive).toList();

  List<CareerGuideline> get inactiveCareerGuidelines =>
      safeCareerGuidelines.where((item) => !item.safeIsActive).toList();

  int get activeCount => activeCareerGuidelines.length;
  int get inactiveCount => inactiveCareerGuidelines.length;
}

class CareerGuideline {
  final int? id;
  final String? name;
  final int? parentId;
  final String? color;
  final bool? isActive;
  final List<CareerGuideline>? children;

  CareerGuideline({
    this.id,
    this.name,
    this.parentId,
    this.color,
    this.isActive,
    this.children,
  });

  factory CareerGuideline.fromJson(Map<String, dynamic> json) {
    return CareerGuideline(
      id: json['id'] is int ? json['id'] : null,
      name: json['name'] is String ? json['name'] : null,
      parentId: json['parent_id'] is int ? json['parent_id'] : null,
      color: json['color'] is String ? json['color'] : null,
      isActive: json['is_active'] is bool ? json['is_active'] : null,
      children: json['children'] is List
          ? (json['children'] as List)
          .map((e) => CareerGuideline.fromJson(e))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'color': color,
      'is_active': isActive,
      'children': children?.map((child) => child.toJson()).toList(),
    };
  }

  bool get isEmpty =>
      (id == null || id! <= 0) &&
          (name?.isEmpty ?? true) &&
          (parentId == null) &&
          (color?.isEmpty ?? true) &&
          (isActive == null) &&
          (children == null || children!.isEmpty);

  bool get isNotEmpty =>
      (id != null && id! > 0) ||
          (name?.isNotEmpty ?? false) ||
          (parentId != null) ||
          (color?.isNotEmpty ?? false) ||
          (isActive != null) ||
          (children != null && children!.isNotEmpty);

  bool get hasValidId => id != null && id! > 0;
  bool get hasValidName => name != null && name!.isNotEmpty;
  bool get hasValidColor => color != null && color!.isNotEmpty;
  bool get hasValidParentId => parentId != null;
  bool get hasChildren => children != null && children!.isNotEmpty;
  bool get isParent => (parentId ?? 0) == 0;
  bool get isChild => (parentId ?? 0) > 0;
  bool get isEnabled => isActive ?? false;
  bool get isValidForDisplay => hasValidName;

  int get safeId => id ?? 0;
  String get safeName => name ?? 'No name';
  int get safeParentId => parentId ?? 0;
  String get safeColor => color ?? '#000000';
  bool get safeIsActive => isActive ?? false;
  List<CareerGuideline> get safeChildren => children ?? [];

  Color get parsedColor {
    try {
      final hexColor = safeColor.replaceFirst('#', '');
      return Color(int.parse('FF$hexColor', radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  String get statusText => safeIsActive ? 'Active' : 'Inactive';

  CareerGuideline copyWith({
    int? id,
    String? name,
    int? parentId,
    String? color,
    bool? isActive,
    List<CareerGuideline>? children,
  }) {
    return CareerGuideline(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      children: children ?? this.children,
    );
  }
}