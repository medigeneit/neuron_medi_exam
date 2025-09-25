// lib/data/models/payment_history_model.dart
import 'dart:convert';

/// Quick helper to parse directly from a raw JSON string.
/// Returns an empty list if parsing fails.
List<PaymentHistoryItem> paymentHistoryFromJson(String source) {
  try {
    final decoded = jsonDecode(source);
    return PaymentHistoryModel.fromAny(decoded).items ?? const <PaymentHistoryItem>[];
  } catch (_) {
    return const <PaymentHistoryItem>[];
  }
}

/// Wrapper model (like ExamAnswersModel) that holds a list.
class PaymentHistoryModel {
  final List<PaymentHistoryItem>? items;

  const PaymentHistoryModel({this.items});

  /// Accepts a raw List, or a Map that wraps a list under common keys.
  factory PaymentHistoryModel.fromAny(dynamic json) {
    if (json is List) {
      return PaymentHistoryModel(
        items: json
            .whereType<Map<String, dynamic>>()
            .map(PaymentHistoryItem.fromJson)
            .toList(),
      );
    }
    if (json is Map<String, dynamic>) {
      // Try to find the list under common keys
      final candidates = [
        json['history'],
        json['items'],
        json['data'],
        json['payments'],
        json['invoices'],
        json['transactions'],
      ];
      List<dynamic> list = const [];
      for (final c in candidates) {
        if (c is List) {
          list = c;
          break;
        }
      }
      return PaymentHistoryModel(
        items: list
            .whereType<Map<String, dynamic>>()
            .map(PaymentHistoryItem.fromJson)
            .toList(),
      );
    }
    return const PaymentHistoryModel(items: []);
  }

  Map<String, dynamic> toJson() => {
    'history': items?.map((e) => e.toJson()).toList(),
  };

  String toRawJson() => jsonEncode(toJson());
}

/// A single payment/invoice row.
/// Every field is nullable and parsed safely (null or empty tolerated).
class PaymentHistoryItem {
  // Strings
  final String? invoiceNumber;
  final String? invoiceDateIso;
  final String? invoiceDateHuman;

  final String? doctorName;
  final String? doctorPhoneNumber;

  final String? admissionRegNo;
  final String? admissionYear;
  final String? admissionCreatedAtIso;
  final String? admissionCreatedAt;

  final String? paymentStatus;

  final String? batchName;
  final String? courseName;
  final String? sessionName;

  final String? currency;

  final String? discountTitle;

  final String? transactionGateways; // comma-separated or single gateway
  final String? transactionIds;      // comma-separated IDs

  // Ints
  final int? doctorId;
  final int? admissionId;
  final int? batchId;
  final int? transactionCount;

  // Money/Numbers (int or double)
  final num? coursePrice;
  final num? discountAmount;
  final num? totalPayable;
  final num? paidAmount;
  final num? dueAmount;

  const PaymentHistoryItem({
    this.invoiceNumber,
    this.invoiceDateIso,
    this.invoiceDateHuman,
    this.doctorId,
    this.doctorName,
    this.doctorPhoneNumber,
    this.admissionId,
    this.admissionRegNo,
    this.admissionYear,
    this.admissionCreatedAtIso,
    this.admissionCreatedAt,
    this.paymentStatus,
    this.batchId,
    this.batchName,
    this.courseName,
    this.sessionName,
    this.currency,
    this.coursePrice,
    this.discountTitle,
    this.discountAmount,
    this.totalPayable,
    this.paidAmount,
    this.dueAmount,
    this.transactionCount,
    this.transactionGateways,
    this.transactionIds,
  });

  factory PaymentHistoryItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PaymentHistoryItem();
    return PaymentHistoryItem(
      invoiceNumber: PaymentJsonUtils.toStringOrNull(json['invoice_number']),
      invoiceDateIso: PaymentJsonUtils.toStringOrNull(json['invoice_date_iso']),
      invoiceDateHuman: PaymentJsonUtils.toStringOrNull(json['invoice_date_human']),

      doctorId: PaymentJsonUtils.toInt(json['doctor_id']),
      doctorName: PaymentJsonUtils.toStringOrNull(json['doctor_name']),
      doctorPhoneNumber: PaymentJsonUtils.toStringOrNull(json['doctor_phone_number']),

      admissionId: PaymentJsonUtils.toInt(json['admission_id']),
      admissionRegNo: PaymentJsonUtils.toStringOrNull(json['admission_reg_no']),
      // API sometimes sends year as string or number → keep as string for safety
      admissionYear: PaymentJsonUtils.toStringOrNull(json['admission_year']),
      admissionCreatedAtIso: PaymentJsonUtils.toStringOrNull(json['admission_created_at_iso']),
      admissionCreatedAt: PaymentJsonUtils.toStringOrNull(json['admission_created_at']),

      paymentStatus: PaymentJsonUtils.toStringOrNull(json['payment_status']),

      batchId: PaymentJsonUtils.toInt(json['batch_id']),
      batchName: PaymentJsonUtils.toStringOrNull(json['batch_name']),
      courseName: PaymentJsonUtils.toStringOrNull(json['course_name']),
      sessionName: PaymentJsonUtils.toStringOrNull(json['session_name']),

      currency: PaymentJsonUtils.toStringOrNull(json['currency']),
      coursePrice: PaymentJsonUtils.toNum(json['course_price']),

      discountTitle: PaymentJsonUtils.toStringOrNull(json['discount_title']),
      discountAmount: PaymentJsonUtils.toNum(json['discount_amount']),
      totalPayable: PaymentJsonUtils.toNum(json['total_payable']),
      paidAmount: PaymentJsonUtils.toNum(json['paid_amount']),
      dueAmount: PaymentJsonUtils.toNum(json['due_amount']),

      transactionCount: PaymentJsonUtils.toInt(json['transaction_count']),
      transactionGateways: PaymentJsonUtils.toStringOrNull(json['transaction_gateways']),
      transactionIds: PaymentJsonUtils.toStringOrNull(json['transaction_ids']),
    );
  }

  Map<String, dynamic> toJson() => {
    'invoice_number': invoiceNumber,
    'invoice_date_iso': invoiceDateIso,
    'invoice_date_human': invoiceDateHuman,
    'doctor_id': doctorId,
    'doctor_name': doctorName,
    'doctor_phone_number': doctorPhoneNumber,
    'admission_id': admissionId,
    'admission_reg_no': admissionRegNo,
    'admission_year': admissionYear,
    'admission_created_at_iso': admissionCreatedAtIso,
    'admission_created_at': admissionCreatedAt,
    'payment_status': paymentStatus,
    'batch_id': batchId,
    'batch_name': batchName,
    'course_name': courseName,
    'session_name': sessionName,
    'currency': currency,
    'course_price': coursePrice,
    'discount_title': discountTitle,
    'discount_amount': discountAmount,
    'total_payable': totalPayable,
    'paid_amount': paidAmount,
    'due_amount': dueAmount,
    'transaction_count': transactionCount,
    'transaction_gateways': transactionGateways,
    'transaction_ids': transactionIds,
  };

  PaymentHistoryItem copyWith({
    String? invoiceNumber,
    String? invoiceDateIso,
    String? invoiceDateHuman,
    int? doctorId,
    String? doctorName,
    String? doctorPhoneNumber,
    int? admissionId,
    String? admissionRegNo,
    String? admissionYear,
    String? admissionCreatedAtIso,
    String? admissionCreatedAt,
    String? paymentStatus,
    int? batchId,
    String? batchName,
    String? courseName,
    String? sessionName,
    String? currency,
    num? coursePrice,
    String? discountTitle,
    num? discountAmount,
    num? totalPayable,
    num? paidAmount,
    num? dueAmount,
    int? transactionCount,
    String? transactionGateways,
    String? transactionIds,
  }) {
    return PaymentHistoryItem(
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDateIso: invoiceDateIso ?? this.invoiceDateIso,
      invoiceDateHuman: invoiceDateHuman ?? this.invoiceDateHuman,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorPhoneNumber: doctorPhoneNumber ?? this.doctorPhoneNumber,
      admissionId: admissionId ?? this.admissionId,
      admissionRegNo: admissionRegNo ?? this.admissionRegNo,
      admissionYear: admissionYear ?? this.admissionYear,
      admissionCreatedAtIso: admissionCreatedAtIso ?? this.admissionCreatedAtIso,
      admissionCreatedAt: admissionCreatedAt ?? this.admissionCreatedAt,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      batchId: batchId ?? this.batchId,
      batchName: batchName ?? this.batchName,
      courseName: courseName ?? this.courseName,
      sessionName: sessionName ?? this.sessionName,
      currency: currency ?? this.currency,
      coursePrice: coursePrice ?? this.coursePrice,
      discountTitle: discountTitle ?? this.discountTitle,
      discountAmount: discountAmount ?? this.discountAmount,
      totalPayable: totalPayable ?? this.totalPayable,
      paidAmount: paidAmount ?? this.paidAmount,
      dueAmount: dueAmount ?? this.dueAmount,
      transactionCount: transactionCount ?? this.transactionCount,
      transactionGateways: transactionGateways ?? this.transactionGateways,
      transactionIds: transactionIds ?? this.transactionIds,
    );
  }
}

/// Safe parsing helpers (null & empty tolerant), similar to AnswerJsonUtils.
class PaymentJsonUtils {
  static String? toStringOrNull(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static int? toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) {
      final t = v.trim();
      if (t.isEmpty) return null;
      final i = int.tryParse(t);
      if (i != null) return i;
      // Sometimes numeric strings may be decimals; try double->int
      final d = double.tryParse(t);
      return d?.toInt();
    }
    return null;
  }

  /// Returns an int or double (as num) if parsable; otherwise null.
  static num? toNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    if (v is String) {
      final t = v.trim();
      if (t.isEmpty) return null;
      final i = int.tryParse(t);
      if (i != null) return i;
      final d = double.tryParse(t);
      if (d != null) return d;
    }
    return null;
  }

  static bool? toBool(dynamic v) {
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
}
