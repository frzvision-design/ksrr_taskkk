class ChecklistItemModel {
  final String id;
  final String employeeUid;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  ChecklistItemModel({
    required this.id,
    required this.employeeUid,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  factory ChecklistItemModel.fromJson(Map<String, dynamic> json) {
    return ChecklistItemModel(
      id: json['id'] ?? '',
      employeeUid: json['employee_uid'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isCompleted: json['is_completed']?.toString().toLowerCase() == 'true',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      completedAt: json['completed_at'] != null && json['completed_at'].toString().isNotEmpty
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_uid': employeeUid,
      'title': title,
      'description': description,
      'is_completed': isCompleted.toString(),
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String() ?? '',
    };
  }

  ChecklistItemModel copyWith({
    String? id,
    String? employeeUid,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return ChecklistItemModel(
      id: id ?? this.id,
      employeeUid: employeeUid ?? this.employeeUid,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
