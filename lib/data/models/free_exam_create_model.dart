class FreeExamCreateRequestModel {
  final int? subjectId;
  final int? specialtyId;
  final List<int>? chapterIds;
  final List<int>? topicIds;
  final List<FreeExamCreateQuestionSetRequest>? questionSets;

  FreeExamCreateRequestModel({
    this.subjectId,
    this.specialtyId,
    this.chapterIds,
    this.topicIds,
    this.questionSets,
  });

  factory FreeExamCreateRequestModel.fromJson(Map<String, dynamic> json) {
    return FreeExamCreateRequestModel(
      subjectId: json['subject_id'] is int ? json['subject_id'] : null,
      specialtyId: json['specialty_id'] is int ? json['specialty_id'] : null,
      chapterIds: json['chapter_ids'] is List
          ? (json['chapter_ids'] as List)
          .where((e) => e is int)
          .cast<int>()
          .toList()
          : null,
      topicIds: json['topic_ids'] is List
          ? (json['topic_ids'] as List)
          .where((e) => e is int)
          .cast<int>()
          .toList()
          : null,
      questionSets: json['question_sets'] is List
          ? (json['question_sets'] as List)
          .where((e) => e is Map<String, dynamic>)
          .map((e) => FreeExamCreateQuestionSetRequest.fromJson(
          e as Map<String, dynamic>))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "subject_id": subjectId,
      "specialty_id": specialtyId,
      "chapter_ids": chapterIds ?? [],
      "topic_ids": topicIds ?? [],
      "question_sets": questionSets?.map((e) => e.toJson()).toList() ?? [],
    };
  }

  bool get isEmpty =>
      (subjectId == null || subjectId! <= 0) &&
          (specialtyId == null || specialtyId! <= 0) &&
          (chapterIds == null || chapterIds!.isEmpty) &&
          (topicIds == null || topicIds!.isEmpty) &&
          (questionSets == null || questionSets!.isEmpty);

  bool get isNotEmpty => !isEmpty;

  // Safe getters
  int get safeSubjectId => subjectId ?? 0;
  int get safeSpecialtyId => specialtyId ?? 0;
  List<int> get safeChapterIds => chapterIds ?? [];
  List<int> get safeTopicIds => topicIds ?? [];
  List<FreeExamCreateQuestionSetRequest> get safeQuestionSets =>
      questionSets ?? [];
}

class FreeExamCreateQuestionSetRequest {
  final int? freeExamTypeId;
  final int? totalQuestions;

  FreeExamCreateQuestionSetRequest({
    this.freeExamTypeId,
    this.totalQuestions,
  });

  factory FreeExamCreateQuestionSetRequest.fromJson(Map<String, dynamic> json) {
    return FreeExamCreateQuestionSetRequest(
      freeExamTypeId:
      json['free_exam_type_id'] is int ? json['free_exam_type_id'] : null,
      totalQuestions:
      json['total_questions'] is int ? json['total_questions'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "free_exam_type_id": freeExamTypeId,
      "total_questions": totalQuestions,
    };
  }

  bool get isEmpty =>
      (freeExamTypeId == null || freeExamTypeId! <= 0) &&
          (totalQuestions == null || totalQuestions! <= 0);

  bool get isNotEmpty => !isEmpty;

  int get safeFreeExamTypeId => freeExamTypeId ?? 0;
  int get safeTotalQuestions => totalQuestions ?? 0;
}

// ======================= RESPONSE MODEL =======================

class FreeExamCreateResponseModel {
  final bool? ok;
  final String? message;
  final FreeExamCreateExam? exam;
  final List<FreeExamCreateQuestionSet>? questionSets;
  final FreeExamCreateQuota? quota;

  FreeExamCreateResponseModel({
    this.ok,
    this.message,
    this.exam,
    this.questionSets,
    this.quota,
  });

  factory FreeExamCreateResponseModel.fromJson(Map<String, dynamic> json) {
    return FreeExamCreateResponseModel(
      ok: json['ok'] is bool ? json['ok'] : null,
      message: json['message'] is String ? json['message'] : null,
      exam: json['exam'] is Map<String, dynamic>
          ? FreeExamCreateExam.fromJson(json['exam'])
          : null,
      questionSets: json['question_sets'] is List
          ? (json['question_sets'] as List)
          .where((e) => e is Map<String, dynamic>)
          .map((e) => FreeExamCreateQuestionSet.fromJson(
          e as Map<String, dynamic>))
          .toList()
          : null,
      quota: json['quota'] is Map<String, dynamic>
          ? FreeExamCreateQuota.fromJson(json['quota'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "ok": ok,
      "message": message,
      "exam": exam?.toJson(),
      "question_sets": questionSets?.map((e) => e.toJson()).toList(),
      "quota": quota?.toJson(),
    };
  }

  bool get isEmpty =>
      (ok == null) &&
          (message?.isEmpty ?? true) &&
          (exam == null || exam!.isEmpty) &&
          (questionSets == null || questionSets!.isEmpty) &&
          (quota == null || quota!.isEmpty);

  bool get isNotEmpty => !isEmpty;

  // Helpers
  bool get isSuccess => ok == true;

  // Safe getters
  bool get safeOk => ok ?? false;
  String get safeMessage => message ?? 'No message';
  FreeExamCreateExam get safeExam => exam ?? FreeExamCreateExam();
  List<FreeExamCreateQuestionSet> get safeQuestionSets => questionSets ?? [];
  FreeExamCreateQuota get safeQuota => quota ?? FreeExamCreateQuota();
}

class FreeExamCreateExam {
  final int? examId;
  final String? date;
  final int? totalQuestions;
  final String? status;

  FreeExamCreateExam({
    this.examId,
    this.date,
    this.totalQuestions,
    this.status,
  });

  factory FreeExamCreateExam.fromJson(Map<String, dynamic> json) {
    return FreeExamCreateExam(
      examId: json['exam_id'] is int ? json['exam_id'] : null,
      date: json['date'] is String ? json['date'] : null,
      totalQuestions:
      json['total_questions'] is int ? json['total_questions'] : null,
      status: json['status'] is String ? json['status'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "exam_id": examId,
      "date": date,
      "total_questions": totalQuestions,
      "status": status,
    };
  }

  bool get isEmpty =>
      (examId == null || examId! <= 0) &&
          (date?.isEmpty ?? true) &&
          (totalQuestions == null || totalQuestions! <= 0) &&
          (status?.isEmpty ?? true);

  bool get isNotEmpty => !isEmpty;

  // Safe getters
  int get safeExamId => examId ?? 0;
  String get safeDate => date ?? 'No date';
  int get safeTotalQuestions => totalQuestions ?? 0;
  String get safeStatus => status ?? 'unknown';
}

class FreeExamCreateQuestionSet {
  final int? freeExamTypeId;
  final int? totalQuestions;

  FreeExamCreateQuestionSet({
    this.freeExamTypeId,
    this.totalQuestions,
  });

  factory FreeExamCreateQuestionSet.fromJson(Map<String, dynamic> json) {
    return FreeExamCreateQuestionSet(
      freeExamTypeId:
      json['free_exam_type_id'] is int ? json['free_exam_type_id'] : null,
      totalQuestions:
      json['total_questions'] is int ? json['total_questions'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "free_exam_type_id": freeExamTypeId,
      "total_questions": totalQuestions,
    };
  }

  bool get isEmpty =>
      (freeExamTypeId == null || freeExamTypeId! <= 0) &&
          (totalQuestions == null || totalQuestions! <= 0);

  bool get isNotEmpty => !isEmpty;

  // Safe getters
  int get safeFreeExamTypeId => freeExamTypeId ?? 0;
  int get safeTotalQuestions => totalQuestions ?? 0;
}

class FreeExamCreateQuota {
  final int? dailyLimit;
  final int? usedBefore;
  final int? remainingBefore;
  final int? remainingAfter;

  FreeExamCreateQuota({
    this.dailyLimit,
    this.usedBefore,
    this.remainingBefore,
    this.remainingAfter,
  });

  factory FreeExamCreateQuota.fromJson(Map<String, dynamic> json) {
    return FreeExamCreateQuota(
      dailyLimit: json['daily_limit'] is int ? json['daily_limit'] : null,
      usedBefore: json['used_before'] is int ? json['used_before'] : null,
      remainingBefore:
      json['remaining_before'] is int ? json['remaining_before'] : null,
      remainingAfter:
      json['remaining_after'] is int ? json['remaining_after'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "daily_limit": dailyLimit,
      "used_before": usedBefore,
      "remaining_before": remainingBefore,
      "remaining_after": remainingAfter,
    };
  }

  bool get isEmpty =>
      (dailyLimit == null || dailyLimit! <= 0) &&
          (usedBefore == null || usedBefore! < 0) &&
          (remainingBefore == null || remainingBefore! < 0) &&
          (remainingAfter == null || remainingAfter! < 0);

  bool get isNotEmpty => !isEmpty;

  // Safe getters
  int get safeDailyLimit => dailyLimit ?? 0;
  int get safeUsedBefore => usedBefore ?? 0;
  int get safeRemainingBefore => remainingBefore ?? 0;
  int get safeRemainingAfter => remainingAfter ?? 0;
}
