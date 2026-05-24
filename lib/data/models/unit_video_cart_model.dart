import 'dart:convert';

class UnitVideoCartModel {
  final List<UnitVideoCartItemModel> items;
  final int? totalItems;
  final int? totalAmount;

  const UnitVideoCartModel({
    this.items = const [],
    this.totalItems,
    this.totalAmount,
  });

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  factory UnitVideoCartModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UnitVideoCartModel();

    return UnitVideoCartModel(
      items: _toCartItemList(json['items']),
      totalItems: _toInt(json['total_items']),
      totalAmount: _toInt(json['total_amount']),
    );
  }

  /// Accepts either a Map or a JSON string.
  factory UnitVideoCartModel.parse(dynamic source) {
    if (source == null) return const UnitVideoCartModel();

    if (source is Map<String, dynamic>) {
      return UnitVideoCartModel.fromJson(source);
    }

    if (source is String && source.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(source);
        if (decoded is Map<String, dynamic>) {
          return UnitVideoCartModel.fromJson(decoded);
        }
      } catch (_) {}
    }

    return const UnitVideoCartModel();
  }

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    'total_items': totalItems,
    'total_amount': totalAmount,
  };

  UnitVideoCartModel copyWith({
    List<UnitVideoCartItemModel>? items,
    int? totalItems,
    int? totalAmount,
  }) {
    return UnitVideoCartModel(
      items: items ?? this.items,
      totalItems: totalItems ?? this.totalItems,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}

class UnitVideoCartItemModel {
  final int? cartItemId;
  final int? questionId;
  final String? questionTitle;
  final int? questionVideoLinkId;
  final String? videoLink;
  final String? videoPassword;
  final int? amount;
  final bool? isAvailable;
  final String? createdAt;

  const UnitVideoCartItemModel({
    this.cartItemId,
    this.questionId,
    this.questionTitle,
    this.questionVideoLinkId,
    this.videoLink,
    this.videoPassword,
    this.amount,
    this.isAvailable,
    this.createdAt,
  });

  factory UnitVideoCartItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UnitVideoCartItemModel();

    return UnitVideoCartItemModel(
      cartItemId: _toInt(json['cart_item_id']),
      questionId: _toInt(json['question_id']),
      questionTitle: _toStringOrNull(json['question_title']),
      questionVideoLinkId: _toInt(json['question_video_link_id']),
      videoLink: _toStringOrNull(json['video_link']),
      videoPassword: _toStringOrNull(json['video_password']),
      amount: _toInt(json['amount']),
      isAvailable: _toBool(json['is_available']),
      createdAt: _toStringOrNull(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'cart_item_id': cartItemId,
    'question_id': questionId,
    'question_title': questionTitle,
    'question_video_link_id': questionVideoLinkId,
    'video_link': videoLink,
    'video_password': videoPassword,
    'amount': amount,
    'is_available': isAvailable,
    'created_at': createdAt,
  };

  UnitVideoCartItemModel copyWith({
    int? cartItemId,
    int? questionId,
    String? questionTitle,
    int? questionVideoLinkId,
    String? videoLink,
    String? videoPassword,
    int? amount,
    bool? isAvailable,
    String? createdAt,
  }) {
    return UnitVideoCartItemModel(
      cartItemId: cartItemId ?? this.cartItemId,
      questionId: questionId ?? this.questionId,
      questionTitle: questionTitle ?? this.questionTitle,
      questionVideoLinkId: questionVideoLinkId ?? this.questionVideoLinkId,
      videoLink: videoLink ?? this.videoLink,
      videoPassword: videoPassword ?? this.videoPassword,
      amount: amount ?? this.amount,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/* -------------------------- Safe parsing helpers -------------------------- */

List<UnitVideoCartItemModel> _toCartItemList(dynamic v) {
  if (v == null) return [];

  if (v is List) {
    return v
        .whereType<Map<String, dynamic>>()
        .map(UnitVideoCartItemModel.fromJson)
        .toList();
  }

  return [];
}

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

String? _toStringOrNull(dynamic v) {
  if (v == null) return null;

  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

bool? _toBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is num) return v != 0;

  if (v is String) {
    final s = v.trim().toLowerCase();

    if (s == 'true' || s == '1' || s == 'yes') return true;
    if (s == 'false' || s == '0' || s == 'no') return false;
  }

  return null;
}