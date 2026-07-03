class TaskModel {
  final String taskId;
  final String title;
  final String description;
  final String assignedTo;
  final String status; // 'pending', 'in_progress', 'completed'
  final DateTime createdAt;
  final DateTime deadline;
  final String? voiceNote; // base64 audio
  final String? attachmentName; // نام فایل
  final String? attachmentData; // base64 file data

  TaskModel({
    required this.taskId,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.status,
    required this.createdAt,
    required this.deadline,
    this.voiceNote,
    this.attachmentName,
    this.attachmentData,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      taskId: json['task_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      assignedTo: json['assigned_to'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      deadline: DateTime.parse(json['deadline'] ?? DateTime.now().toIso8601String()),
      voiceNote: json['voice_note'],
      attachmentName: json['attachment_name'],
      attachmentData: json['attachment_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'title': title,
      'description': description,
      'assigned_to': assignedTo,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'deadline': deadline.toIso8601String(),
      'voice_note': voiceNote,
      'attachment_name': attachmentName,
      'attachment_data': attachmentData,
    };
  }

  bool get isOverdue => DateTime.now().isAfter(deadline) && status != 'completed';

  Duration get timeRemaining => deadline.difference(DateTime.now());
}
