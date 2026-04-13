import 'package:flutter/material.dart';

class CareerGuidelineFolderModel {
  final CareerGuidelineFolder? folder;
  final List<CareerGuidelineFile>? files;
  final CareerGuidelinePagination? pagination;

  CareerGuidelineFolderModel({
    this.folder,
    this.files,
    this.pagination,
  });

  factory CareerGuidelineFolderModel.fromJson(Map<String, dynamic> json) {
    return CareerGuidelineFolderModel(
      folder: json['folder'] is Map<String, dynamic>
          ? CareerGuidelineFolder.fromJson(json['folder'] as Map<String, dynamic>)
          : null,
      files: json['files'] is List
          ? (json['files'] as List)
          .map((e) => CareerGuidelineFile.fromJson(e))
          .toList()
          : null,
      pagination: json['pagination'] is Map<String, dynamic>
          ? CareerGuidelinePagination.fromJson(
        json['pagination'] as Map<String, dynamic>,
      )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'folder': folder?.toJson(),
      'files': files?.map((file) => file.toJson()).toList(),
      'pagination': pagination?.toJson(),
    };
  }

  bool get isEmpty =>
      folder == null &&
          (files == null || files!.isEmpty) &&
          pagination == null;

  bool get isNotEmpty => !isEmpty;

  bool get hasValidFolder => folder != null && folder!.isNotEmpty;
  bool get hasValidFiles => files != null && files!.isNotEmpty;
  bool get hasPagination => pagination != null;
  bool get isValidForDisplay => hasValidFolder || hasValidFiles;

  CareerGuidelineFolder get safeFolder => folder ?? CareerGuidelineFolder();
  List<CareerGuidelineFile> get safeFiles => files ?? [];
  CareerGuidelinePagination get safePagination =>
      pagination ?? CareerGuidelinePagination();

  List<CareerGuidelineFile> get pdfFiles =>
      safeFiles.where((file) => file.safeIsPdf).toList();

  List<CareerGuidelineFile> get imageFiles =>
      safeFiles.where((file) => file.safeIsImage).toList();

  List<CareerGuidelineFile> get otherFiles =>
      safeFiles
          .where((file) => !file.safeIsPdf && !file.safeIsImage)
          .toList();

  int get fileCount => safeFiles.length;
  int get pdfCount => pdfFiles.length;
  int get imageCount => imageFiles.length;
}

class CareerGuidelineFolder {
  final int? id;
  final String? name;
  final int? parentId;
  final String? color;
  final bool? isActive;
  final List<CareerGuidelineFolder>? children;

  CareerGuidelineFolder({
    this.id,
    this.name,
    this.parentId,
    this.color,
    this.isActive,
    this.children,
  });

  factory CareerGuidelineFolder.fromJson(Map<String, dynamic> json) {
    return CareerGuidelineFolder(
      id: json['id'] is int ? json['id'] : null,
      name: json['name'] is String ? json['name'] : null,
      parentId: json['parent_id'] is int ? json['parent_id'] : null,
      color: json['color'] is String ? json['color'] : null,
      isActive: json['is_active'] is bool ? json['is_active'] : null,
      children: json['children'] is List
          ? (json['children'] as List)
          .map((e) => CareerGuidelineFolder.fromJson(e))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'color': color,
      'is_active': isActive,
      'children': children?.map((child) => child.toJson()).toList(),
    };
  }

  bool get isEmpty =>
      (id == null || id! <= 0) &&
          (name?.isEmpty ?? true) &&
          (parentId == null) &&
          (color?.isEmpty ?? true) &&
          (isActive == null) &&
          (children == null || children!.isEmpty);

  bool get isNotEmpty =>
      (id != null && id! > 0) ||
          (name?.isNotEmpty ?? false) ||
          (parentId != null) ||
          (color?.isNotEmpty ?? false) ||
          (isActive != null) ||
          (children != null && children!.isNotEmpty);

  bool get hasValidId => id != null && id! > 0;
  bool get hasValidName => name != null && name!.isNotEmpty;
  bool get hasValidColor => color != null && color!.isNotEmpty;
  bool get hasChildren => children != null && children!.isNotEmpty;
  bool get isParent => (parentId ?? 0) == 0;
  bool get isChild => (parentId ?? 0) > 0;
  bool get isEnabled => isActive ?? false;
  bool get isValidForDisplay => hasValidName;

  int get safeId => id ?? 0;
  String get safeName => name ?? 'No name';
  int get safeParentId => parentId ?? 0;
  String get safeColor => color ?? '#000000';
  bool get safeIsActive => isActive ?? false;
  List<CareerGuidelineFolder> get safeChildren => children ?? [];

  Color get parsedColor {
    try {
      final hexColor = safeColor.replaceFirst('#', '');
      return Color(int.parse('FF$hexColor', radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  String get statusText => safeIsActive ? 'Active' : 'Inactive';

  CareerGuidelineFolder copyWith({
    int? id,
    String? name,
    int? parentId,
    String? color,
    bool? isActive,
    List<CareerGuidelineFolder>? children,
  }) {
    return CareerGuidelineFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      children: children ?? this.children,
    );
  }
}

class CareerGuidelineFile {
  final int? id;
  final String? title;
  final String? originalName;
  final String? fileType;
  final String? mimeType;
  final String? extension;
  final int? size;
  final String? url;
  final bool? isImage;
  final bool? isPdf;
  final String? createdAt;

  CareerGuidelineFile({
    this.id,
    this.title,
    this.originalName,
    this.fileType,
    this.mimeType,
    this.extension,
    this.size,
    this.url,
    this.isImage,
    this.isPdf,
    this.createdAt,
  });

  factory CareerGuidelineFile.fromJson(Map<String, dynamic> json) {
    return CareerGuidelineFile(
      id: json['id'] is int ? json['id'] : null,
      title: json['title'] is String ? json['title'] : null,
      originalName:
      json['original_name'] is String ? json['original_name'] : null,
      fileType: json['file_type'] is String ? json['file_type'] : null,
      mimeType: json['mime_type'] is String ? json['mime_type'] : null,
      extension: json['extension'] is String ? json['extension'] : null,
      size: json['size'] is int ? json['size'] : null,
      url: json['url'] is String ? json['url'] : null,
      isImage: json['is_image'] is bool ? json['is_image'] : null,
      isPdf: json['is_pdf'] is bool ? json['is_pdf'] : null,
      createdAt: json['created_at'] is String ? json['created_at'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'original_name': originalName,
      'file_type': fileType,
      'mime_type': mimeType,
      'extension': extension,
      'size': size,
      'url': url,
      'is_image': isImage,
      'is_pdf': isPdf,
      'created_at': createdAt,
    };
  }

  bool get isEmpty =>
      (id == null || id! <= 0) &&
          (title?.isEmpty ?? true) &&
          (originalName?.isEmpty ?? true) &&
          (fileType?.isEmpty ?? true) &&
          (mimeType?.isEmpty ?? true) &&
          (extension?.isEmpty ?? true) &&
          (size == null || size! <= 0) &&
          (url?.isEmpty ?? true) &&
          (isImage == null) &&
          (isPdf == null) &&
          (createdAt?.isEmpty ?? true);

  bool get isNotEmpty =>
      (id != null && id! > 0) ||
          (title?.isNotEmpty ?? false) ||
          (originalName?.isNotEmpty ?? false) ||
          (fileType?.isNotEmpty ?? false) ||
          (mimeType?.isNotEmpty ?? false) ||
          (extension?.isNotEmpty ?? false) ||
          (size != null && size! > 0) ||
          (url?.isNotEmpty ?? false) ||
          (isImage != null) ||
          (isPdf != null) ||
          (createdAt?.isNotEmpty ?? false);

  bool get hasValidId => id != null && id! > 0;
  bool get hasValidTitle => title != null && title!.isNotEmpty;
  bool get hasValidUrl => url != null && url!.isNotEmpty;
  bool get hasValidCreatedAt => createdAt != null && createdAt!.isNotEmpty;
  bool get isValidForDisplay => hasValidTitle && hasValidUrl;

  int get safeId => id ?? 0;
  String get safeTitle => title ?? 'No title';
  String get safeOriginalName => originalName ?? 'No file name';
  String get safeFileType => fileType ?? 'Unknown';
  String get safeMimeType => mimeType ?? 'Unknown';
  String get safeExtension => extension ?? '';
  int get safeSize => size ?? 0;
  String get safeUrl => url ?? '';
  bool get safeIsImage => isImage ?? false;
  bool get safeIsPdf => isPdf ?? false;
  String get safeCreatedAt => createdAt ?? '';

  String get fileCategory {
    if (safeIsPdf) return 'PDF';
    if (safeIsImage) return 'Image';
    return safeFileType.toUpperCase();
  }

  String get formattedFileSize {
    if (safeSize <= 0) return '0 B';

    if (safeSize < 1024) {
      return '$safeSize B';
    } else if (safeSize < 1024 * 1024) {
      return '${(safeSize / 1024).toStringAsFixed(2)} KB';
    } else if (safeSize < 1024 * 1024 * 1024) {
      return '${(safeSize / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(safeSize / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  String get formattedCreatedAt {
    if (createdAt == null || createdAt!.isEmpty) return 'No date';

    try {
      final date = DateTime.parse(createdAt!);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return createdAt!;
    }
  }

  CareerGuidelineFile copyWith({
    int? id,
    String? title,
    String? originalName,
    String? fileType,
    String? mimeType,
    String? extension,
    int? size,
    String? url,
    bool? isImage,
    bool? isPdf,
    String? createdAt,
  }) {
    return CareerGuidelineFile(
      id: id ?? this.id,
      title: title ?? this.title,
      originalName: originalName ?? this.originalName,
      fileType: fileType ?? this.fileType,
      mimeType: mimeType ?? this.mimeType,
      extension: extension ?? this.extension,
      size: size ?? this.size,
      url: url ?? this.url,
      isImage: isImage ?? this.isImage,
      isPdf: isPdf ?? this.isPdf,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CareerGuidelinePagination {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;

  CareerGuidelinePagination({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
  });

  factory CareerGuidelinePagination.fromJson(Map<String, dynamic> json) {
    return CareerGuidelinePagination(
      currentPage: json['current_page'] is int ? json['current_page'] : null,
      lastPage: json['last_page'] is int ? json['last_page'] : null,
      perPage: json['per_page'] is int ? json['per_page'] : null,
      total: json['total'] is int ? json['total'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'last_page': lastPage,
      'per_page': perPage,
      'total': total,
    };
  }

  bool get isEmpty =>
      (currentPage == null || currentPage! <= 0) &&
          (lastPage == null || lastPage! <= 0) &&
          (perPage == null || perPage! <= 0) &&
          (total == null || total! <= 0);

  bool get isNotEmpty => !isEmpty;

  int get safeCurrentPage => currentPage ?? 1;
  int get safeLastPage => lastPage ?? 1;
  int get safePerPage => perPage ?? 10;
  int get safeTotal => total ?? 0;

  bool get hasNextPage => safeCurrentPage < safeLastPage;
  bool get hasPreviousPage => safeCurrentPage > 1;
  bool get isFirstPage => safeCurrentPage == 1;
  bool get isLastPage => safeCurrentPage >= safeLastPage;

  int? get nextPage => hasNextPage ? safeCurrentPage + 1 : null;
  int? get previousPage => hasPreviousPage ? safeCurrentPage - 1 : null;

  String get paginationText =>
      'Page $safeCurrentPage of $safeLastPage (${safeTotal} items)';

  CareerGuidelinePagination copyWith({
    int? currentPage,
    int? lastPage,
    int? perPage,
    int? total,
  }) {
    return CareerGuidelinePagination(
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      perPage: perPage ?? this.perPage,
      total: total ?? this.total,
    );
  }
}