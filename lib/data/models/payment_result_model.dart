// lib/data/models/payment_result_model.dart
import 'dart:convert';

class PaymentResultModel {
  final String status;          // "success" | "failed"
  final String statusMessage;   // e.g. "Successful" | "Invalid Payment State"
  final String? trxID;          // e.g. "CIU70NI9NT" or null
  final String gateway;         // "bkash"

  const PaymentResultModel({
    required this.status,
    required this.statusMessage,
    required this.trxID,
    required this.gateway,
  });

  bool get isSuccess => status.toLowerCase() == 'success';

  factory PaymentResultModel.fromMap(Map<String, dynamic> map) {
    return PaymentResultModel(
      status: (map['status'] ?? '').toString(),
      statusMessage: (map['statusMessage'] ?? '').toString(),
      trxID: map['trxID']?.toString(),
      gateway: (map['gateway'] ?? '').toString(),
    );
  }

  factory PaymentResultModel.fromJson(String source) =>
      PaymentResultModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'statusMessage': statusMessage,
      'trxID': trxID,
      'gateway': gateway,
    };
  }

  String toJson() => json.encode(toMap());
}
