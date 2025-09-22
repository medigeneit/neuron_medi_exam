
class VideoLinkModel {
  final String? videoPlatform; // raw (may be null/empty/messy case)
  final String? videoLink;     // raw (may be null/empty)
  final String? errorMessage;  // raw (may be null/empty)

  const VideoLinkModel({
    this.videoPlatform,
    this.videoLink,
    this.errorMessage,
  });

  /// Tolerant factory: accepts any json-like map.
  factory VideoLinkModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const VideoLinkModel();
    return VideoLinkModel(
      videoPlatform: _s(json['video_platform'] ?? json['platform']),
      videoLink: _s(json['video_link'] ?? json['link'] ?? json['url']),
      errorMessage: _s(json['error_message'] ?? json['message'] ?? json['error']),
    );
  }

  Map<String, dynamic> toJson() => {
    'video_platform': videoPlatform,
    'video_link': videoLink,
    'error_message': errorMessage,
  };

  VideoLinkModel copyWith({
    String? videoPlatform,
    String? videoLink,
    String? errorMessage,
  }) {
    return VideoLinkModel(
      videoPlatform: videoPlatform ?? this.videoPlatform,
      videoLink: videoLink ?? this.videoLink,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // -----------------------------
  // Safe getters / normalization
  // -----------------------------

  /// Trimmed platform string (or empty).
  String get safePlatformRaw => (videoPlatform ?? '').trim();

  /// Trimmed link string (or empty).
  String get safeLink => (videoLink ?? '').trim();

  /// Trimmed error message (or empty).
  String get safeError => (errorMessage ?? '').trim();

  /// Normalized platform as enum (tries raw first, then infers from URL).
  VideoPlatform get platform {
    final p = _normalizePlatform(safePlatformRaw);
    if (p != VideoPlatform.unknown) return p;
    // Fallback: infer from link if platform missing/unknown.
    return _inferPlatformFromUrl(safeLink);
  }

  // -----------------------------
  // Convenience flags
  // -----------------------------

  bool get hasLink => safeLink.isNotEmpty;
  bool get hasError => safeError.isNotEmpty;

  bool get isYouTube => platform == VideoPlatform.youtube;
  bool get isVimeo => platform == VideoPlatform.vimeo;
  bool get isVdoCipher => platform == VideoPlatform.vdocipher;
  bool get isGumlet => platform == VideoPlatform.gumlet;

  /// Considered playable if we can recognize the platform and have a non-empty link.
  bool get isPlayable => platform != VideoPlatform.unknown && hasLink;

  /// Empty if nothing meaningful is present.
  bool get isEmpty => safePlatformRaw.isEmpty && safeLink.isEmpty && safeError.isEmpty;
  bool get isNotEmpty => !isEmpty;

  // -----------------------------
  // Static helpers
  // -----------------------------

  static String? _s(dynamic v) {
    if (v == null) return null;
    if (v is String) return v.trim();
    return v.toString().trim();
  }

  static VideoPlatform _normalizePlatform(String raw) {
    if (raw.isEmpty) return VideoPlatform.unknown;
    final s = raw.toLowerCase();
    if (s.contains('youtube') || s == 'yt') return VideoPlatform.youtube;
    if (s.contains('vimeo')) return VideoPlatform.vimeo;
    if (s.contains('vdocipher') || s.contains('vdo cipher')) return VideoPlatform.vdocipher;
    if (s.contains('gumlet')) return VideoPlatform.gumlet;
    return VideoPlatform.unknown;
  }

  static VideoPlatform _inferPlatformFromUrl(String url) {
    if (url.isEmpty) return VideoPlatform.unknown;

    final lower = url.toLowerCase();

    // YouTube
    if (lower.contains('youtube.com') || lower.contains('youtu.be')) {
      return VideoPlatform.youtube;
    }

    // Vimeo
    if (lower.contains('vimeo.com') || lower.contains('player.vimeo.com')) {
      return VideoPlatform.vimeo;
    }

    // VdoCipher
    if (lower.contains('vdocipher') || lower.contains('vdo.ai')) {
      // Some integrations use vdocipher domains or vdo.ai player
      return VideoPlatform.vdocipher;
    }

    // Gumlet
    if (lower.contains('gumlet') || lower.contains('player.gumlet') || lower.contains('gumlet.io') || lower.contains('gumlet.com')) {
      return VideoPlatform.gumlet;
    }

    return VideoPlatform.unknown;
  }
}

/// Supported platforms. `unknown` when unrecognized or missing.
enum VideoPlatform { youtube, vimeo, vdocipher, gumlet, unknown }
