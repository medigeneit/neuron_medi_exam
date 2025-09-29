// lib/data/models/helpline_model.dart
import 'dart:convert';

/// Quick decode from a raw JSON string.
HelplineModel helplineFromJsonString(String source) =>
    HelplineModel.fromAny(jsonDecode(source));

/// Quick encode to a raw JSON string.
String helplineToJsonString(HelplineModel model) => jsonEncode(model.toJson());

class HelplineModel {
  /// e.g. "https://www.messenger.com/t/106488708841492"
  final String? messenger;

  /// e.g. "01617794123"
  final String? whatsapp;

  /// e.g. "01617794123"
  final String? phone;

  /// e.g. "https://www.youtube.com/watch?v=oXKBTwcZH2k"
  /// NOTE: backend may use the misspelled key "promosional_video_url".
  final String? promotionalVideoUrl;

  const HelplineModel({
    this.messenger,
    this.whatsapp,
    this.phone,
    this.promotionalVideoUrl,
  });

  /// Accepts:
  /// - Map<String, dynamic>
  /// - String (raw JSON)
  /// - null / anything else -> empty model
  factory HelplineModel.fromAny(dynamic any) {
    if (any == null) return const HelplineModel();
    if (any is String) {
      try {
        final decoded = jsonDecode(any);
        if (decoded is Map<String, dynamic>) {
          return HelplineModel.fromJson(decoded);
        }
      } catch (_) {}
      return const HelplineModel();
    }
    if (any is Map<String, dynamic>) {
      return HelplineModel.fromJson(any);
    }
    return const HelplineModel();
  }

  factory HelplineModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const HelplineModel();

    // Handle both "promosional_video_url" (as in sample) and a correct spelling fallback.
    final promoRaw = json.containsKey('promosional_video_url')
        ? json['promosional_video_url']
        : (json['promotional_video_url'] ?? json['promo_video_url']);

    return HelplineModel(
      messenger: _Json.toStringNonEmpty(json['messenger']),
      whatsapp: _Json.toStringNonEmpty(json['whatsapp']),
      phone: _Json.toStringNonEmpty(json['phone']),
      promotionalVideoUrl: _Json.toStringNonEmpty(promoRaw),
    );
  }

  Map<String, dynamic> toJson() => {
    'messenger': messenger,
    'whatsapp': whatsapp,
    'phone': phone,
    'promosional_video_url': promotionalVideoUrl,
  };

  HelplineModel copyWith({
    String? messenger,
    String? whatsapp,
    String? phone,
    String? promotionalVideoUrl,
  }) {
    return HelplineModel(
      messenger: messenger ?? this.messenger,
      whatsapp: whatsapp ?? this.whatsapp,
      phone: phone ?? this.phone,
      promotionalVideoUrl: promotionalVideoUrl ?? this.promotionalVideoUrl,
    );
  }

  /// True if any non-empty field exists.
  bool get hasAny =>
      (messenger != null && messenger!.isNotEmpty) ||
          (whatsapp != null && whatsapp!.isNotEmpty) ||
          (phone != null && phone!.isNotEmpty) ||
          (promotionalVideoUrl != null && promotionalVideoUrl!.isNotEmpty);
}

/// Forgiving converters for strings.
class _Json {
  /// Returns a trimmed string or null if:
  /// - value is null
  /// - value (after toString + trim) is empty
  static String? toStringNonEmpty(dynamic v) {
    if (v == null) return null;
    final s = v is String ? v.trim() : v.toString().trim();
    if (s.isEmpty) return null;
    return s;
  }
}
