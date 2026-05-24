import 'dart:convert';

class UnitVideoModel {
  final int? questionId;
  final List<UnitVideoItemModel> videos;

  const UnitVideoModel({
    this.questionId,
    this.videos = const [],
  });

  factory UnitVideoModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UnitVideoModel();

    return UnitVideoModel(
      questionId: _toInt(json['question_id']),
      videos: _toUnitVideoList(json['videos']),
    );
  }

  /// Accepts either a Map or a JSON string.
  factory UnitVideoModel.parse(dynamic source) {
    if (source == null) return const UnitVideoModel();

    if (source is Map<String, dynamic>) {
      return UnitVideoModel.fromJson(source);
    }

    if (source is String && source.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(source);
        if (decoded is Map<String, dynamic>) {
          return UnitVideoModel.fromJson(decoded);
        }
      } catch (_) {}
    }

    return const UnitVideoModel();
  }

  bool get hasVideos => videos.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'question_id': questionId,
    'videos': videos.map((e) => e.toJson()).toList(),
  };

  UnitVideoModel copyWith({
    int? questionId,
    List<UnitVideoItemModel>? videos,
  }) =>
      UnitVideoModel(
        questionId: questionId ?? this.questionId,
        videos: videos ?? this.videos,
      );
}

class UnitVideoItemModel {
  final int? id;
  final int? questionId;
  final String? videoLink;
  final String? videoPassword;
  final int? amount;
  final bool? isFree;
  final bool? isPaid;
  final bool? canAddToCart;
  final bool? isAddedToCart;
  final bool? isPurchased;
  final String? accessStatus;

  const UnitVideoItemModel({
    this.id,
    this.questionId,
    this.videoLink,
    this.videoPassword,
    this.amount,
    this.isFree,
    this.isPaid,
    this.canAddToCart,
    this.isAddedToCart,
    this.isPurchased,
    this.accessStatus,
  });

  factory UnitVideoItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UnitVideoItemModel();

    return UnitVideoItemModel(
      id: _toInt(json['id']),
      questionId: _toInt(json['question_id']),
      videoLink: _toStringOrNull(json['video_link']),
      videoPassword: _toStringOrNull(json['video_password']),
      amount: _toInt(json['amount']),
      isFree: _toBool(json['is_free']),
      isPaid: _toBool(json['is_paid']),
      canAddToCart: _toBool(json['can_add_to_cart']),
      isAddedToCart: _toBool(json['is_added_to_cart']),
      isPurchased: _toBool(json['is_purchased']),
      accessStatus: _toStringOrNull(json['access_status']),
    );
  }

  bool get hasVideoLink => videoLink != null && videoLink!.isNotEmpty;

  bool get isLocked => accessStatus == 'locked';

  bool get isAccessible =>
      isFree == true || isPurchased == true || accessStatus == 'free';

  Map<String, dynamic> toJson() => {
    'id': id,
    'question_id': questionId,
    'video_link': videoLink,
    'video_password': videoPassword,
    'amount': amount,
    'is_free': isFree,
    'is_paid': isPaid,
    'can_add_to_cart': canAddToCart,
    'is_added_to_cart': isAddedToCart,
    'is_purchased': isPurchased,
    'access_status': accessStatus,
  };

  UnitVideoItemModel copyWith({
    int? id,
    int? questionId,
    String? videoLink,
    String? videoPassword,
    int? amount,
    bool? isFree,
    bool? isPaid,
    bool? canAddToCart,
    bool? isAddedToCart,
    bool? isPurchased,
    String? accessStatus,
  }) =>
      UnitVideoItemModel(
        id: id ?? this.id,
        questionId: questionId ?? this.questionId,
        videoLink: videoLink ?? this.videoLink,
        videoPassword: videoPassword ?? this.videoPassword,
        amount: amount ?? this.amount,
        isFree: isFree ?? this.isFree,
        isPaid: isPaid ?? this.isPaid,
        canAddToCart: canAddToCart ?? this.canAddToCart,
        isAddedToCart: isAddedToCart ?? this.isAddedToCart,
        isPurchased: isPurchased ?? this.isPurchased,
        accessStatus: accessStatus ?? this.accessStatus,
      );
}

/* -------------------------- Safe parsing helpers -------------------------- */

List<UnitVideoItemModel> _toUnitVideoList(dynamic v) {
  if (v == null) return [];

  if (v is List) {
    return v
        .whereType<Map<String, dynamic>>()
        .map(UnitVideoItemModel.fromJson)
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