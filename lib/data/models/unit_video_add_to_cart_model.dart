import 'dart:convert';

class UnitVideoAddToCartModel {
  final bool? success;
  final String? message;
  final UnitVideoAddToCartData? data;

  const UnitVideoAddToCartModel({
    this.success,
    this.message,
    this.data,
  });

  factory UnitVideoAddToCartModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UnitVideoAddToCartModel();

    return UnitVideoAddToCartModel(
      success: _toBool(json['success']),
      message: _toStringOrNull(json['message']),
      data: json['data'] is Map<String, dynamic>
          ? UnitVideoAddToCartData.fromJson(json['data'])
          : null,
    );
  }

  /// Accepts either a Map or a JSON string.
  factory UnitVideoAddToCartModel.parse(dynamic source) {
    if (source == null) return const UnitVideoAddToCartModel();

    if (source is Map<String, dynamic>) {
      return UnitVideoAddToCartModel.fromJson(source);
    }

    if (source is String && source.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(source);
        if (decoded is Map<String, dynamic>) {
          return UnitVideoAddToCartModel.fromJson(decoded);
        }
      } catch (_) {}
    }

    return const UnitVideoAddToCartModel();
  }

  UnitVideoCartItem? get cartItem => data?.cartItem;
  UnitVideoCart? get cart => data?.cart;

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data?.toJson(),
  };

  UnitVideoAddToCartModel copyWith({
    bool? success,
    String? message,
    UnitVideoAddToCartData? data,
  }) =>
      UnitVideoAddToCartModel(
        success: success ?? this.success,
        message: message ?? this.message,
        data: data ?? this.data,
      );
}

class UnitVideoAddToCartData {
  final UnitVideoCartItem? cartItem;
  final UnitVideoCart? cart;

  const UnitVideoAddToCartData({
    this.cartItem,
    this.cart,
  });

  factory UnitVideoAddToCartData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UnitVideoAddToCartData();

    return UnitVideoAddToCartData(
      cartItem: json['cart_item'] is Map<String, dynamic>
          ? UnitVideoCartItem.fromJson(json['cart_item'])
          : null,
      cart: json['cart'] is Map<String, dynamic>
          ? UnitVideoCart.fromJson(json['cart'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'cart_item': cartItem?.toJson(),
    'cart': cart?.toJson(),
  };

  UnitVideoAddToCartData copyWith({
    UnitVideoCartItem? cartItem,
    UnitVideoCart? cart,
  }) =>
      UnitVideoAddToCartData(
        cartItem: cartItem ?? this.cartItem,
        cart: cart ?? this.cart,
      );
}

class UnitVideoCart {
  final List<UnitVideoCartItem> items;
  final int? totalItems;
  final int? totalAmount;

  const UnitVideoCart({
    this.items = const [],
    this.totalItems,
    this.totalAmount,
  });

  factory UnitVideoCart.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UnitVideoCart();

    return UnitVideoCart(
      items: _toCartItems(json['items']),
      totalItems: _toInt(json['total_items']),
      totalAmount: _toInt(json['total_amount']),
    );
  }

  bool get hasItems => items.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    'total_items': totalItems,
    'total_amount': totalAmount,
  };

  UnitVideoCart copyWith({
    List<UnitVideoCartItem>? items,
    int? totalItems,
    int? totalAmount,
  }) =>
      UnitVideoCart(
        items: items ?? this.items,
        totalItems: totalItems ?? this.totalItems,
        totalAmount: totalAmount ?? this.totalAmount,
      );
}

class UnitVideoCartItem {
  final int? cartItemId;
  final int? questionId;
  final String? questionTitle;
  final int? questionVideoLinkId;
  final String? videoLink;
  final String? videoPassword;
  final int? amount;
  final bool? isAvailable;
  final String? createdAt;

  const UnitVideoCartItem({
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

  factory UnitVideoCartItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UnitVideoCartItem();

    return UnitVideoCartItem(
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

  UnitVideoCartItem copyWith({
    int? cartItemId,
    int? questionId,
    String? questionTitle,
    int? questionVideoLinkId,
    String? videoLink,
    String? videoPassword,
    int? amount,
    bool? isAvailable,
    String? createdAt,
  }) =>
      UnitVideoCartItem(
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

/* -------------------------- Safe parsing helpers -------------------------- */

List<UnitVideoCartItem> _toCartItems(dynamic v) {
  if (v == null) return [];

  if (v is List) {
    return v
        .whereType<Map<String, dynamic>>()
        .map(UnitVideoCartItem.fromJson)
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
