// get_bkash_url_model.dart
import 'dart:convert';

class GetBkashUrlModel {

  final String bkashUrl;


  final bool success;


  final String message;

  const GetBkashUrlModel({
    required this.bkashUrl,
    required this.success,
    required this.message,
  });

  /// Create from a decoded JSON map.
  factory GetBkashUrlModel.fromMap(Map<String, dynamic> map) {
    return GetBkashUrlModel(
      bkashUrl: map['bkash_url']?.toString() ?? '',
      // Be tolerant of different boolean encodings
      success: map['success'] == true ||
          map['success'] == 1 ||
          map['success'] == 'true',
      message: map['message']?.toString() ?? '',
    );
  }

  /// Convert to a JSON-serializable map using the original API keys.
  Map<String, dynamic> toMap() {
    return {
      'bkash_url': bkashUrl,
      'success': success,
      'message': message,
    };
  }

  /// Parse from a raw JSON string.
  factory GetBkashUrlModel.fromJson(String source) =>
      GetBkashUrlModel.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  /// Convert to a raw JSON string.
  String toJson() => json.encode(toMap());

  /// Create a modified copy.
  GetBkashUrlModel copyWith({
    String? bkashUrl,
    bool? success,
    String? message,
  }) {
    return GetBkashUrlModel(
      bkashUrl: bkashUrl ?? this.bkashUrl,
      success: success ?? this.success,
      message: message ?? this.message,
    );
  }

  @override
  String toString() =>
      'GetBkashUrlModel(bkashUrl: $bkashUrl, success: $success, message: $message)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetBkashUrlModel &&
        other.bkashUrl == bkashUrl &&
        other.success == success &&
        other.message == message;
  }

  @override
  int get hashCode => bkashUrl.hashCode ^ success.hashCode ^ message.hashCode;
}
