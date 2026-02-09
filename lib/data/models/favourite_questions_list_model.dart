import 'dart:convert';

class FavouriteQuestionsListModel {
  final int? currentPage;
  final List<FavouriteQuestionItem>? data;

  final String? firstPageUrl;
  final int? from;

  final int? lastPage;
  final String? lastPageUrl;

  final List<FavouritePaginationLink>? links;

  final String? nextPageUrl;
  final String? path;

  final int? perPage;
  final String? prevPageUrl;

  final int? to;
  final int? total;

  const FavouriteQuestionsListModel({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory FavouriteQuestionsListModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FavouriteQuestionsListModel();

    return FavouriteQuestionsListModel(
      currentPage: _toInt(json['current_page']),
      data: _toList(json['data'])
          ?.map((e) => e is Map<String, dynamic>
          ? FavouriteQuestionItem.fromJson(e)
          : const FavouriteQuestionItem())
          .toList(),
      firstPageUrl: _toStringOrNull(json['first_page_url']),
      from: _toInt(json['from']),
      lastPage: _toInt(json['last_page']),
      lastPageUrl: _toStringOrNull(json['last_page_url']),
      links: _toList(json['links'])
          ?.map((e) => e is Map<String, dynamic>
          ? FavouritePaginationLink.fromJson(e)
          : const FavouritePaginationLink())
          .toList(),
      nextPageUrl: _toStringOrNull(json['next_page_url']),
      path: _toStringOrNull(json['path']),
      perPage: _toInt(json['per_page']),
      prevPageUrl: _toStringOrNull(json['prev_page_url']),
      to: _toInt(json['to']),
      total: _toInt(json['total']),
    );
  }

  /// Accepts either a Map or a JSON string.
  factory FavouriteQuestionsListModel.parse(dynamic source) {
    if (source == null) return const FavouriteQuestionsListModel();

    if (source is Map<String, dynamic>) {
      return FavouriteQuestionsListModel.fromJson(source);
    }

    if (source is String && source.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(source);
        if (decoded is Map<String, dynamic>) {
          return FavouriteQuestionsListModel.fromJson(decoded);
        }
      } catch (_) {}
    }

    return const FavouriteQuestionsListModel();
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'data': data?.map((e) => e.toJson()).toList(),
    'first_page_url': firstPageUrl,
    'from': from,
    'last_page': lastPage,
    'last_page_url': lastPageUrl,
    'links': links?.map((e) => e.toJson()).toList(),
    'next_page_url': nextPageUrl,
    'path': path,
    'per_page': perPage,
    'prev_page_url': prevPageUrl,
    'to': to,
    'total': total,
  };

  FavouriteQuestionsListModel copyWith({
    int? currentPage,
    List<FavouriteQuestionItem>? data,
    String? firstPageUrl,
    int? from,
    int? lastPage,
    String? lastPageUrl,
    List<FavouritePaginationLink>? links,
    String? nextPageUrl,
    String? path,
    int? perPage,
    String? prevPageUrl,
    int? to,
    int? total,
  }) =>
      FavouriteQuestionsListModel(
        currentPage: currentPage ?? this.currentPage,
        data: data ?? this.data,
        firstPageUrl: firstPageUrl ?? this.firstPageUrl,
        from: from ?? this.from,
        lastPage: lastPage ?? this.lastPage,
        lastPageUrl: lastPageUrl ?? this.lastPageUrl,
        links: links ?? this.links,
        nextPageUrl: nextPageUrl ?? this.nextPageUrl,
        path: path ?? this.path,
        perPage: perPage ?? this.perPage,
        prevPageUrl: prevPageUrl ?? this.prevPageUrl,
        to: to ?? this.to,
        total: total ?? this.total,
      );
}

class FavouriteQuestionItem {
  final int? id;
  final int? topicId;
  final int? questionTypeId;

  final String? title;

  final List<FavouriteQuestionOption>? options;

  /// SBA: "A" / MCQ: "TTFTF"
  final String? answerScript;

  final String? reference;

  final int? optionInRow;

  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  final FavouriteQuestionPivot? pivot;

  const FavouriteQuestionItem({
    this.id,
    this.topicId,
    this.questionTypeId,
    this.title,
    this.options,
    this.answerScript,
    this.reference,
    this.optionInRow,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.pivot,
  });

  bool get isSba => questionTypeId == 2;
  bool get isMcq => questionTypeId == 1;

  factory FavouriteQuestionItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FavouriteQuestionItem();

    return FavouriteQuestionItem(
      id: _toInt(json['id']),
      topicId: _toInt(json['topic_id']),
      questionTypeId: _toInt(json['question_type_id']),
      title: _toStringOrNull(json['title']),
      options: _toList(json['options'])
          ?.map((e) => e is Map<String, dynamic>
          ? FavouriteQuestionOption.fromJson(e)
          : const FavouriteQuestionOption())
          .toList(),
      answerScript: _toStringOrNull(json['answer_script']),
      reference: _toStringOrNull(json['reference']),
      optionInRow: _toInt(json['option_in_row']),
      createdAt: _toStringOrNull(json['created_at']),
      updatedAt: _toStringOrNull(json['updated_at']),
      deletedAt: _toStringOrNull(json['deleted_at']),
      pivot: json['pivot'] is Map<String, dynamic>
          ? FavouriteQuestionPivot.fromJson(json['pivot'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'topic_id': topicId,
    'question_type_id': questionTypeId,
    'title': title,
    'options': options?.map((e) => e.toJson()).toList(),
    'answer_script': answerScript,
    'reference': reference,
    'option_in_row': optionInRow,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'deleted_at': deletedAt,
    'pivot': pivot?.toJson(),
  };

  FavouriteQuestionItem copyWith({
    int? id,
    int? topicId,
    int? questionTypeId,
    String? title,
    List<FavouriteQuestionOption>? options,
    String? answerScript,
    String? reference,
    int? optionInRow,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
    FavouriteQuestionPivot? pivot,
  }) =>
      FavouriteQuestionItem(
        id: id ?? this.id,
        topicId: topicId ?? this.topicId,
        questionTypeId: questionTypeId ?? this.questionTypeId,
        title: title ?? this.title,
        options: options ?? this.options,
        answerScript: answerScript ?? this.answerScript,
        reference: reference ?? this.reference,
        optionInRow: optionInRow ?? this.optionInRow,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
        pivot: pivot ?? this.pivot,
      );
}

class FavouriteQuestionOption {
  final String? serial; // A..E
  final String? title;

  const FavouriteQuestionOption({
    this.serial,
    this.title,
  });

  factory FavouriteQuestionOption.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FavouriteQuestionOption();
    return FavouriteQuestionOption(
      serial: _toStringOrNull(json['serial']),
      title: _toStringOrNull(json['title']),
    );
  }

  Map<String, dynamic> toJson() => {
    'serial': serial,
    'title': title,
  };
}

class FavouriteQuestionPivot {
  final int? doctorId;
  final int? questionId;
  final String? createdAt;
  final String? updatedAt;

  const FavouriteQuestionPivot({
    this.doctorId,
    this.questionId,
    this.createdAt,
    this.updatedAt,
  });

  factory FavouriteQuestionPivot.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FavouriteQuestionPivot();
    return FavouriteQuestionPivot(
      doctorId: _toInt(json['doctor_id']),
      questionId: _toInt(json['question_id']),
      createdAt: _toStringOrNull(json['created_at']),
      updatedAt: _toStringOrNull(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'doctor_id': doctorId,
    'question_id': questionId,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class FavouritePaginationLink {
  final String? url;
  final String? label;
  final bool? active;

  const FavouritePaginationLink({
    this.url,
    this.label,
    this.active,
  });

  factory FavouritePaginationLink.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FavouritePaginationLink();
    return FavouritePaginationLink(
      url: _toStringOrNull(json['url']),
      label: _toStringOrNull(json['label']),
      active: _toBool(json['active']),
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'label': label,
    'active': active,
  };
}

/* -------------------------- Safe parsing helpers -------------------------- */

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

List<dynamic>? _toList(dynamic v) {
  if (v == null) return null;
  if (v is List) return v;
  return null;
}
