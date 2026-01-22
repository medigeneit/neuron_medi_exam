// lib/data/models/subject_wise_chapter_topics_model.dart
// Matches the JSON you shared (specialty, subject, chapters -> topics)
// Style follows your active_course_specialties_subjects_model.dart

class SubjectWiseChapterTopicsModel {
  final SpecialtyInfo? specialty;
  final SubjectInfo? subject;
  final List<Chapter>? chapters;

  SubjectWiseChapterTopicsModel({
    this.specialty,
    this.subject,
    this.chapters,
  });

  /// API returns Map<String, dynamic>
  factory SubjectWiseChapterTopicsModel.fromJson(Map<String, dynamic> json) {
    return SubjectWiseChapterTopicsModel(
      specialty: json['specialty'] == null
          ? null
          : SpecialtyInfo.fromJson(json['specialty'] as Map<String, dynamic>),
      subject: json['subject'] == null
          ? null
          : SubjectInfo.fromJson(json['subject'] as Map<String, dynamic>),
      chapters: (json['chapters'] as List<dynamic>?)
          ?.map((e) => Chapter.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'specialty': specialty?.toJson() ?? {},
      'subject': subject?.toJson() ?? {},
      'chapters': chapters?.map((c) => c.toJson()).toList() ?? [],
    };
  }
}

class SpecialtyInfo {
  final int? specialtyId;
  final String? specialtyTitle;

  SpecialtyInfo({
    this.specialtyId,
    this.specialtyTitle,
  });

  factory SpecialtyInfo.fromJson(Map<String, dynamic> json) {
    return SpecialtyInfo(
      specialtyId: json['specialty_id'],
      specialtyTitle: json['specialty_title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'specialty_id': specialtyId,
      'specialty_title': specialtyTitle,
    };
  }
}

class SubjectInfo {
  final int? subjectId;
  final String? subjectName;

  SubjectInfo({
    this.subjectId,
    this.subjectName,
  });

  factory SubjectInfo.fromJson(Map<String, dynamic> json) {
    return SubjectInfo(
      subjectId: json['subject_id'],
      subjectName: json['subject_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject_id': subjectId,
      'subject_name': subjectName,
    };
  }
}

class Chapter {
  final int? chapterId;
  final String? chapterName;
  final int? questionCount;
  final List<Topic>? topics;

  Chapter({
    this.chapterId,
    this.chapterName,
    this.questionCount,
    this.topics,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapterId: json['chapter_id'],
      chapterName: json['chapter_name'],
      questionCount: json['question_count'],
      topics: (json['topics'] as List<dynamic>?)
          ?.map((e) => Topic.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapter_id': chapterId,
      'chapter_name': chapterName,
      'question_count': questionCount,
      'topics': topics?.map((t) => t.toJson()).toList() ?? [],
    };
  }
}

class Topic {
  final int? topicId;
  final String? topicName;
  final int? questionCount;

  Topic({
    this.topicId,
    this.topicName,
    this.questionCount,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      topicId: json['topic_id'],
      topicName: json['topic_name'],
      questionCount: json['question_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topic_id': topicId,
      'topic_name': topicName,
      'question_count': questionCount,
    };
  }
}
