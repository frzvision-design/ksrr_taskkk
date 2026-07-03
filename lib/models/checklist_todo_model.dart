class ChecklistTodoModel {
  final String id;
  final String itemId;
  final String title;
  final bool isCompleted;
  final int order;
  final DateTime createdAt;
  final DateTime? completedAt;

  ChecklistTodoModel({
    required this.id,
    required this.itemId,
    required this.title,
    this.isCompleted = false,
    required this.order,
    required this.createdAt,
    this.completedAt,
  });

  factory ChecklistTodoModel.fromJson(Map<String, dynamic> json) {
    return ChecklistTodoModel(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      title: json['title'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
      order: json['order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'title': title,
      'is_completed': isCompleted,
      'order': order,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  ChecklistTodoModel copyWith({
    String? id,
    String? itemId,
    String? title,
    bool? isCompleted,
    int? order,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return ChecklistTodoModel(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
