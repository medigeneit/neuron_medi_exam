// lib/data/models/easy_finder_keywords_model.dart
import 'dart:convert';

class EasyFinderKeywordsModel {
  final List<String> items;

  const EasyFinderKeywordsModel({this.items = const <String>[]});

  factory EasyFinderKeywordsModel.fromAny(dynamic json) {
    // API may return raw List<String>
    if (json is List) {
      return EasyFinderKeywordsModel(
        items: json
            .map((e) => e?.toString() ?? '')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
      );
    }

    // Or wrapped: { data: [...] } / { keywords: [...] }
    if (json is Map<String, dynamic>) {
      final raw = json['data'] ?? json['keywords'] ?? json['items'];
      if (raw is List) {
        return EasyFinderKeywordsModel(
          items: raw
              .map((e) => e?.toString() ?? '')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList(),
        );
      }
    }

    return const EasyFinderKeywordsModel(items: <String>[]);
  }

  factory EasyFinderKeywordsModel.fromRawJson(String source) {
    final decoded = jsonDecode(source);
    return EasyFinderKeywordsModel.fromAny(decoded);
  }

  Map<String, dynamic> toJson() => {'data': items};

  String toRawJson() => jsonEncode(toJson());
}