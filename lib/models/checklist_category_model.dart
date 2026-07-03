class ChecklistCategoryModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? icon;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ChecklistCategoryModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.icon,
    required this.createdAt,
    this.updatedAt,
  });

  factory ChecklistCategoryModel.fromJson(Map<String, dynamic> json) {
    return ChecklistCategoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'icon': icon,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ChecklistCategoryModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChecklistCategoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
