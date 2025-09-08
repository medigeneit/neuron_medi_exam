import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormattedDate extends StatelessWidget {
  const FormattedDate({
    super.key,
    required this.date,
    this.pattern = 'd MMM yyyy', // -> 12 Sep 2025
    this.locale,                 // e.g. 'en_US', 'bn_BD'
    this.style,
    this.placeholder = '—',      // shown if date is null
  });

  final DateTime? date;
  final String pattern;
  final String? locale;
  final TextStyle? style;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final text = date == null
        ? placeholder
        : DateFormat(pattern, locale).format(date!.toLocal());
    return Text(text, style: style);
  }
}

String formatDateStr(
    String? raw, {
      String out = 'd MMM yyyy',      // -> 12 Sep 2025
      String? inPattern,              // e.g. 'yyyy-MM-dd'
      String? locale,
    }) {
  if (raw == null || raw.trim().isEmpty) return '—';

  DateTime? dt;

  // If you know the incoming pattern, use it (more reliable)
  if (inPattern != null) {
    try {
      dt = DateFormat(inPattern, locale).parse(raw, true);
    } catch (_) {}
  }

  // Fallbacks: try ISO8601 first, then a few common patterns
  dt ??= DateTime.tryParse(raw);
  if (dt == null) {
    for (final p in [
      'yyyy-MM-dd',
      'yyyy-MM-ddTHH:mm:ss',
      'yyyy-MM-ddTHH:mm:ssZ',
      'dd/MM/yyyy',
      'MM/dd/yyyy',
    ]) {
      try {
        dt = DateFormat(p, locale).parse(raw, true);
        break;
      } catch (_) {}
    }
  }

  if (dt == null) return raw; // show raw if un-parseable
  return DateFormat(out, locale).format(dt.toLocal());
}
