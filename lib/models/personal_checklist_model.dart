import 'dart:convert';

class PersonalChecklistCategory {
  final String id;
  final String title;
  final String userUid;
  final DateTime createdAt;
  final List<PersonalChecklistStep> steps;

  PersonalChecklistCategory({
    required this.id,
    required this.title,
    required this.userUid,
    required this.createdAt,
    this.steps = const [],
  });

  PersonalChecklistCategory copyWith({
    String? id,
    String? title,
    String? userUid,
    DateTime? createdAt,
    List<PersonalChecklistStep>? steps,
  }) {
    return PersonalChecklistCategory(
      id: id ?? this.id,
      title: title ?? this.title,
      userUid: userUid ?? this.userUid,
      createdAt: createdAt ?? this.createdAt,
      steps: steps ?? this.steps,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'userUid': userUid,
        'createdAt': createdAt.toIso8601String(),
        'steps': steps.map((s) => s.toJson()).toList(),
      };

  factory PersonalChecklistCategory.fromJson(Map<String, dynamic> json) {
    return PersonalChecklistCategory(
      id: json['id'],
      title: json['title'],
      userUid: json['userUid'],
      createdAt: DateTime.parse(json['createdAt']),
      steps: (json['steps'] as List<dynamic>? ?? [])
          .map((s) => PersonalChecklistStep.fromJson(s))
          .toList(),
    );
  }

  int get completedCount => steps.where((s) => s.isCompleted).length;
  int get totalCount => steps.length;
  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;
}

class PersonalChecklistStep {
  final String id;
  final String categoryId;
  final String title;
  final String description;
  final int order;
  final bool isCompleted;
  final DateTime? completedAt;

  PersonalChecklistStep({
    required this.id,
    required this.categoryId,
    required this.title,
    this.description = '',
    required this.order,
    this.isCompleted = false,
    this.completedAt,
  });

  PersonalChecklistStep copyWith({
    String? id,
    String? categoryId,
    String? title,
    String? description,
    int? order,
    bool? isCompleted,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return PersonalChecklistStep(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      order: order ?? this.order,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt:
          clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'title': title,
        'description': description,
        'order': order,
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory PersonalChecklistStep.fromJson(Map<String, dynamic> json) {
    return PersonalChecklistStep(
      id: json['id'],
      categoryId: json['categoryId'],
      title: json['title'],
      description: json['description'] ?? '',
      order: json['order'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'])
          : null,
    );
  }
}
