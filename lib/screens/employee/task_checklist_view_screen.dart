import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../models/task_checklist_model.dart';
import '../../services/local_checklist_service.dart';

class TaskChecklistViewScreen extends StatefulWidget {
  final TaskModel task;

  const TaskChecklistViewScreen({Key? key, required this.task}) : super(key: key);

  @override
  State<TaskChecklistViewScreen> createState() => _TaskChecklistViewScreenState();
}

class _TaskChecklistViewScreenState extends State<TaskChecklistViewScreen> {
  final _localChecklistService = LocalChecklistService();
  List<TaskChecklistModel> _checklistItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChecklist();
  }

  Future<void> _loadChecklist() async {
    setState(() => _isLoading = true);
    _checklistItems = await _localChecklistService.getTaskChecklist(widget.task.taskId);
    setState(() => _isLoading = false);
  }

  Future<void> _toggleItem(TaskChecklistModel item) async {
    final success = await _localChecklistService.toggleChecklistItem(
      item.id,
      !item.isCompleted,
    );

    if (success) {
      await _loadChecklist();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              item.isCompleted ? 'علامت برداشته شد' : 'انجام شد ✓',
              textDirection: TextDirection.rtl,
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'start':
        return Colors.green;
      case 'step':
        return Colors.blue;
      case 'condition':
        return Colors.orange;
      case 'end':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'start':
        return Icons.play_circle_outline;
      case 'step':
        return Icons.radio_button_checked;
      case 'condition':
        return Icons.help_outline;
      case 'end':
        return Icons.flag;
      default:
        return Icons.circle;
    }
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'start':
        return 'شروع';
      case 'step':
        return 'مرحله';
      case 'condition':
        return 'شرط / تصمیم';
      case 'end':
        return 'پایان';
      default:
        return type;
    }
  }

  int _getCompletedCount() {
    return _checklistItems.where((item) => item.isCompleted).length;
  }

  double _getProgress() {
    if (_checklistItems.isEmpty) return 0;
    return _getCompletedCount() / _checklistItems.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'چک‌لیست: ${widget.task.title}',
          style: const TextStyle(fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Progress Card
                if (_checklistItems.isNotEmpty)
                  Card(
                    margin: const EdgeInsets.all(16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'پیشرفت کار',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFD4AF37),
                                ),
                              ),
                              Text(
                                '${_getCompletedCount()} از ${_checklistItems.length}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _getProgress(),
                              minHeight: 12,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getProgress() == 1.0
                                    ? Colors.green
                                    : const Color(0xFFD4AF37),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(_getProgress() * 100).toStringAsFixed(0)}% تکمیل شده',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Checklist Items
                Expanded(
                  child: _checklistItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.checklist_rtl,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'چک‌لیستی برای این وظیفه تعریف نشده',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _checklistItems.length,
                          itemBuilder: (context, index) {
                            final item = _checklistItems[index];
                            return _buildChecklistItem(item, index);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildChecklistItem(TaskChecklistModel item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: item.isCompleted ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: item.isCompleted
              ? Colors.green.withOpacity(0.3)
              : _getTypeColor(item.type).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _toggleItem(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: item.isCompleted ? Colors.green : _getTypeColor(item.type),
                    width: 2,
                  ),
                  color: item.isCompleted ? Colors.green : Colors.transparent,
                ),
                child: item.isCompleted
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 18,
                      )
                    : null,
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Step Number and Type
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(item.type).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getTypeIcon(item.type),
                                size: 14,
                                color: _getTypeColor(item.type),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getTypeName(item.type),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getTypeColor(item.type),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'مرحله ${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Title
                    Text(
                      item.title,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: item.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: item.isCompleted
                            ? Colors.grey.shade600
                            : Colors.black,
                      ),
                    ),

                    // Description
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        item.description,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 14,
                          color: item.isCompleted
                              ? Colors.grey.shade500
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],

                    // Completion Time
                    if (item.isCompleted && item.completedAt != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'انجام شد',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
