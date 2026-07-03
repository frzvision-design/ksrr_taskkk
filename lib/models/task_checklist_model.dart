class TaskChecklistModel {
  final String id;
  final String taskId;
  final String title;
  final String description;
  final int order;
  final String type; // 'start', 'step', 'condition', 'end'
  final String? conditionTrue; // ID of next step if condition is true
  final String? conditionFalse; // ID of next step if condition is false
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  TaskChecklistModel({
    required this.id,
    required this.taskId,
    required this.title,
    required this.description,
    required this.order,
    required this.type,
    this.conditionTrue,
    this.conditionFalse,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  factory TaskChecklistModel.fromJson(Map<String, dynamic> json) {
    return TaskChecklistModel(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      order: json['order'] as int,
      type: json['type'] as String,
      conditionTrue: json['condition_true'] as String?,
      conditionFalse: json['condition_false'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'title': title,
      'description': description,
      'order': order,
      'type': type,
      'condition_true': conditionTrue,
      'condition_false': conditionFalse,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  TaskChecklistModel copyWith({
    String? id,
    String? taskId,
    String? title,
    String? description,
    int? order,
    String? type,
    String? conditionTrue,
    String? conditionFalse,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return TaskChecklistModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      order: order ?? this.order,
      type: type ?? this.type,
      conditionTrue: conditionTrue ?? this.conditionTrue,
      conditionFalse: conditionFalse ?? this.conditionFalse,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
