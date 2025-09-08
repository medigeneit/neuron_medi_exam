class SlideItemsModel {
  final List<SlideItem>? slideItems;

  SlideItemsModel({
    this.slideItems,
  });

  factory SlideItemsModel.fromJson(Map<String, dynamic> json) {
    return SlideItemsModel(
      slideItems: json['slide_items'] is List
          ? (json['slide_items'] as List)
          .map((e) => SlideItem.fromJson(e))
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
  bool get isNotEmpty => slideItems != null && slideItems!.isNotEmpty;
}

class SlideItem {
  final int? id;
  final String? title;
  final String? link;
  final String? linkType;
  final String? thumb;
  final int? priority;
  final int? repeatAfter;

  SlideItem({
    this.id,
    this.title,
    this.link,
    this.linkType,
    this.thumb,
    this.priority,
    this.repeatAfter,
  });

  factory SlideItem.fromJson(Map<String, dynamic> json) {
    return SlideItem(
      id: json['id'] is int ? json['id'] : null,
      title: json['title'] is String ? json['title']?.toString() : null,
      link: json['link'] is String ? json['link']?.toString() : null,
      linkType: json['link_type'] is String ? json['link_type']?.toString() : null,
      thumb: json['thumb'] is String ? json['thumb']?.toString() : null,
      priority: json['priority'] is int ? json['priority'] : null,
      repeatAfter: json['repeat_after'] is int ? json['repeat_after'] : null,
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
    };
  }

  bool get isEmpty =>
      title?.isEmpty ?? true &&
          link!.isEmpty ?? true &&
          thumb!.isEmpty ?? true;

  bool get isNotEmpty =>
      title?.isNotEmpty ?? false ||
          link!.isNotEmpty ?? false ||
          thumb!.isNotEmpty ?? false;

  // Helper methods to check specific properties
  bool get hasValidId => id != null && id! > 0;
  bool get hasValidTitle => title != null && title!.isNotEmpty;
  bool get hasValidLink => link != null && link!.isNotEmpty;
  bool get hasValidThumb => thumb != null && thumb!.isNotEmpty;
  bool get hasValidPriority => priority != null && priority! >= 0;
  bool get isValidForDisplay => hasValidLink && hasValidThumb;

  // Get safe values with fallbacks
  String get safeTitle => title ?? 'Untitled';
  String get safeLink => link ?? '';
  String get safeThumb => thumb ?? '';
  String get safeLinkType => linkType ?? 'web_link';
  int get safePriority => priority ?? 0;
  int get safeRepeatAfter => repeatAfter ?? 0;
}