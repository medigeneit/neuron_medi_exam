// lib/data/models/free_exam_list_model.dart
import 'dart:convert';

class FreeExamListModel {
  final bool? ok;
  final FreeExamListPagination? pagination;
  final List<FreeExamListItem>? items;

  const FreeExamListModel({
    this.ok,
    this.pagination,
    this.items,
  });

  factory FreeExamListModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FreeExamListModel();
    return FreeExamListModel(
      ok: _toBool(json['ok']),
      pagination: json['pagination'] is Map<String, dynamic>
          ? FreeExamListPagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
      items: _toList(json['items'])
          ?.map((e) => e is Map<String, dynamic> ? FreeExamListItem.fromJson(e) : const FreeExamListItem())
          .toList(),
    );
  }

  /// Accepts either a Map or a JSON string.
  factory FreeExamListModel.parse(dynamic source) {
    if (source == null) return const FreeExamListModel();

    if (source is Map<String, dynamic>) {
      return FreeExamListModel.fromJson(source);
    }

    if (source is String && source.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(source);
        if (decoded is Map<String, dynamic>) {
          return FreeExamListModel.fromJson(decoded);
        }
      } catch (_) {}
    }

    return const FreeExamListModel();
  }

  Map<String, dynamic> toJson() => {
    'ok': ok,
    'pagination': pagination?.toJson(),
    'items': items?.map((e) => e.toJson()).toList(),
  };

  FreeExamListModel copyWith({
    bool? ok,
    FreeExamListPagination? pagination,
    List<FreeExamListItem>? items,
  }) =>
      FreeExamListModel(
        ok: ok ?? this.ok,
        pagination: pagination ?? this.pagination,
        items: items ?? this.items,
      );
}

class FreeExamListPagination {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;

  const FreeExamListPagination({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
  });

  factory FreeExamListPagination.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FreeExamListPagination();
    return FreeExamListPagination(
      currentPage: _toInt(json['current_page']),
      lastPage: _toInt(json['last_page']),
      perPage: _toInt(json['per_page']),
      total: _toInt(json['total']),
    );
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'last_page': lastPage,
    'per_page': perPage,
    'total': total,
  };

  FreeExamListPagination copyWith({
    int? currentPage,
    int? lastPage,
    int? perPage,
    int? total,
  }) =>
      FreeExamListPagination(
        currentPage: currentPage ?? this.currentPage,
        lastPage: lastPage ?? this.lastPage,
        perPage: perPage ?? this.perPage,
        total: total ?? this.total,
      );
}

class FreeExamListItem {
  final int? examId;
  final String? status;
  final String? title;
  final int? totalQuestions;

  const FreeExamListItem({
    this.examId,
    this.status,
    this.title,
    this.totalQuestions,
  });

  factory FreeExamListItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FreeExamListItem();
    return FreeExamListItem(
      examId: _toInt(json['exam_id']),
      status: _toStringOrNull(json['status']),
      title: _toStringOrNull(json['title']),
      totalQuestions: _toInt(json['total_questions']),
    );
  }

  Map<String, dynamic> toJson() => {
    'exam_id': examId,
    'status': status,
    'title': title,
    'total_questions': totalQuestions,
  };

  FreeExamListItem copyWith({
    int? examId,
    String? status,
    String? title,
    int? totalQuestions,
  }) =>
      FreeExamListItem(
        examId: examId ?? this.examId,
        status: status ?? this.status,
        title: title ?? this.title,
        totalQuestions: totalQuestions ?? this.totalQuestions,
      );
}

/* -------------------------- Safe parsing helpers -------------------------- */

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is num) return v.toInt();
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return null;
    return int.tryParse(s);
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

List<dynamic>? _toList(dynamic v) {
  if (v == null) return null;
  if (v is List) return v;
  return null;
}
