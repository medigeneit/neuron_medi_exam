import 'dart:convert';

class UnitVideoBkashPaymentStatusModel {
  final bool? success;
  final String? message;
  final UnitVideoBkashPaymentStatusData? data;

  const UnitVideoBkashPaymentStatusModel({
    this.success,
    this.message,
    this.data,
  });

  bool get isSuccess => success == true;

  String get statusMessage {
    final dataMessage = data?.statusMessage;
    if (dataMessage != null && dataMessage.trim().isNotEmpty) {
      return dataMessage;
    }

    return message ?? '';
  }

  factory UnitVideoBkashPaymentStatusModel.fromJson(
      Map<String, dynamic>? json,
      ) {
    if (json == null) return const UnitVideoBkashPaymentStatusModel();

    return UnitVideoBkashPaymentStatusModel(
      success: _toBool(json['success']),
      message: _toStringOrNull(json['message']),
      data: json['data'] is Map<String, dynamic>
          ? UnitVideoBkashPaymentStatusData.fromJson(json['data'])
          : null,
    );
  }

  factory UnitVideoBkashPaymentStatusModel.parse(dynamic source) {
    if (source == null) return const UnitVideoBkashPaymentStatusModel();

    if (source is Map<String, dynamic>) {
      return UnitVideoBkashPaymentStatusModel.fromJson(source);
    }

    if (source is String && source.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(source);
        if (decoded is Map<String, dynamic>) {
          return UnitVideoBkashPaymentStatusModel.fromJson(decoded);
        }
      } catch (_) {}
    }

    return const UnitVideoBkashPaymentStatusModel();
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data?.toJson(),
  };
}

class UnitVideoBkashPaymentStatusData {
  final String? statusCode;
  final String? statusMessage;

  const UnitVideoBkashPaymentStatusData({
    this.statusCode,
    this.statusMessage,
  });

  factory UnitVideoBkashPaymentStatusData.fromJson(
      Map<String, dynamic>? json,
      ) {
    if (json == null) return const UnitVideoBkashPaymentStatusData();

    return UnitVideoBkashPaymentStatusData(
      statusCode: _toStringOrNull(json['statusCode']),
      statusMessage: _toStringOrNull(json['statusMessage']),
    );
  }

  Map<String, dynamic> toJson() => {
    'statusCode': statusCode,
    'statusMessage': statusMessage,
  };
}

/* -------------------------- Safe parsing helpers -------------------------- */

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