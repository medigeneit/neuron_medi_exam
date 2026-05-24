import 'dart:convert';

class UnitVideoBkashCheckoutModel {
  final bool? success;
  final String? message;
  final UnitVideoBkashCheckoutData? data;

  const UnitVideoBkashCheckoutModel({
    this.success,
    this.message,
    this.data,
  });

  factory UnitVideoBkashCheckoutModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UnitVideoBkashCheckoutModel();

    return UnitVideoBkashCheckoutModel(
      success: _toBool(json['success']),
      message: _toStringOrNull(json['message']),
      data: json['data'] is Map<String, dynamic>
          ? UnitVideoBkashCheckoutData.fromJson(json['data'])
          : null,
    );
  }

  factory UnitVideoBkashCheckoutModel.parse(dynamic source) {
    if (source == null) return const UnitVideoBkashCheckoutModel();

    if (source is Map<String, dynamic>) {
      return UnitVideoBkashCheckoutModel.fromJson(source);
    }

    if (source is String && source.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(source);
        if (decoded is Map<String, dynamic>) {
          return UnitVideoBkashCheckoutModel.fromJson(decoded);
        }
      } catch (_) {}
    }

    return const UnitVideoBkashCheckoutModel();
  }

  String get paymentUrl => data?.paymentUrl ?? '';

  String get bkashPaymentId => data?.bkashPaymentId ?? '';

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data?.toJson(),
  };
}

class UnitVideoBkashCheckoutData {
  final int? orderId;
  final String? orderNo;
  final int? paymentId;
  final String? bkashPaymentId;
  final String? paymentUrl;
  final int? totalItems;
  final int? totalAmount;
  final String? currency;

  const UnitVideoBkashCheckoutData({
    this.orderId,
    this.orderNo,
    this.paymentId,
    this.bkashPaymentId,
    this.paymentUrl,
    this.totalItems,
    this.totalAmount,
    this.currency,
  });

  factory UnitVideoBkashCheckoutData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UnitVideoBkashCheckoutData();

    return UnitVideoBkashCheckoutData(
      orderId: _toInt(json['order_id']),
      orderNo: _toStringOrNull(json['order_no']),
      paymentId: _toInt(json['payment_id']),
      bkashPaymentId: _toStringOrNull(json['bkash_payment_id']),
      paymentUrl: _toStringOrNull(json['payment_url']),
      totalItems: _toInt(json['total_items']),
      totalAmount: _toInt(json['total_amount']),
      currency: _toStringOrNull(json['currency']),
    );
  }

  Map<String, dynamic> toJson() => {
    'order_id': orderId,
    'order_no': orderNo,
    'payment_id': paymentId,
    'bkash_payment_id': bkashPaymentId,
    'payment_url': paymentUrl,
    'total_items': totalItems,
    'total_amount': totalAmount,
    'currency': currency,
  };
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