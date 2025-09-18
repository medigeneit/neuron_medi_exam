class SlideItemsModel {
  final List<SlideItem>? slideItems;

  SlideItemsModel({this.slideItems});

  factory SlideItemsModel.fromJson(Map<String, dynamic> json) {
    return SlideItemsModel(
      slideItems: json['slide_items'] is List
          ? (json['slide_items'] as List)
          .whereType<Map<String, dynamic>>()
          .map(SlideItem.fromJson)
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slide_items': slideItems?.map((item) => item.toJson()).toList(),
    };
  }

  bool get isEmpty => slideItems == null || slideItems!.isEmpty;
  bool get isNotEmpty => !isEmpty;

  List<SlideItem> get sortedByPriorityDesc {
    final items = List<SlideItem>.from(slideItems ?? const []);
    items.sort((a, b) => (b.safePriority).compareTo(a.safePriority));
    return items;
  }
}

class SlideItem {
  final int? id;
  final String? title;
  final String? link;
  final String? linkType;
  final String? thumb;
  final int? priority;
  final int? repeatAfter;

  // NEW fields from API
  final int? batchId;
  final int? coursePackageId;

  SlideItem({
    this.id,
    this.title,
    this.link,
    this.linkType,
    this.thumb,
    this.priority,
    this.repeatAfter,
    this.batchId,
    this.coursePackageId,
  });

  factory SlideItem.fromJson(Map<String, dynamic> json) {
    int? _asInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    return SlideItem(
      id: _asInt(json['id']),
      title: json['title']?.toString(),
      link: json['link']?.toString(),
      linkType: json['link_type']?.toString(),
      thumb: json['thumb']?.toString(),
      priority: _asInt(json['priority']),
      repeatAfter: _asInt(json['repeat_after']),
      batchId: _asInt(json['batch_id']),
      coursePackageId: _asInt(json['course_package_id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'link': link,
      'link_type': linkType,
      'thumb': thumb,
      'priority': priority,
      'repeat_after': repeatAfter,
      'batch_id': batchId,
      'course_package_id': coursePackageId,
    };
  }

  // ----- Safety & validation -----
  bool get isEmpty =>
      (title?.isEmpty ?? true) &&
          (link?.isEmpty ?? true) &&
          (thumb?.isEmpty ?? true);

  bool get isNotEmpty => !isEmpty;

  bool get hasValidId => id != null && id! > 0;
  bool get hasValidTitle => title != null && title!.isNotEmpty;
  bool get hasValidLink => link != null && link!.trim().isNotEmpty;
  bool get hasValidThumb => thumb != null && thumb!.trim().isNotEmpty;

  bool get hasTargetBatch => batchId != null && batchId! > 0;
  bool get hasTargetCoursePackage => coursePackageId != null && coursePackageId! > 0;
  bool get hasAnyTarget => hasTargetBatch || hasTargetCoursePackage;

  // ----- Link type helpers -----
  String get safeLinkType => (linkType ?? 'web_link').toLowerCase();
  bool get isVideoLink => safeLinkType == 'video_link';
  bool get isWebLink => safeLinkType == 'web_link';
  bool get isBatchType => safeLinkType == 'batch_type';


  bool get isValidForDisplay =>
      hasValidThumb && (isBatchType ? hasAnyTarget : true);

  // ----- Safe getters -----
  String get safeTitle => title ?? 'Untitled';
  String get safeLink => link ?? '';
  String get safeThumb => thumb ?? '';
  int get safePriority => priority ?? 0;
  int get safeRepeatAfter => repeatAfter ?? 0;
  int get safeBatchId => batchId ?? 0;
  int get safeCoursePackageId => coursePackageId ?? 0;

  // Optional: convenience for rendering badges
  String get displayTypeLabel {
    if (isVideoLink) return 'Video';
    if (isBatchType) return 'Batch';
    return 'Web';
  }
}
