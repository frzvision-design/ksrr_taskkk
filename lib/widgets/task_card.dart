import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../services/backend_service.dart';
import 'countdown_timer.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onRefresh;

  const TaskCard({
    Key? key,
    required this.task,
    this.onRefresh,
  }) : super(key: key);

  Color _getStatusColor() {
    if (task.isOverdue && task.status != 'completed') return Colors.red;
    if (task.status == 'completed') return Colors.green;
    if (task.status == 'in_progress') return Colors.blue;
    return Colors.orange;
  }

  String _getStatusText() {
    if (task.isOverdue && task.status != 'completed') return 'منقضی شده';
    if (task.status == 'completed') return 'تکمیل شده';
    if (task.status == 'in_progress') return 'در حال انجام';
    return 'در انتظار';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Title
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            // Description (truncated)
            Text(
              task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.rtl,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(),
                style: TextStyle(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Countdown Timer
            if (task.status != 'completed')
              CountdownTimer(deadline: task.deadline),
            const SizedBox(height: 8),
            // Dates
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'مهلت: ${task.deadline.year}/${task.deadline.month}/${task.deadline.day}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  'ایجاد: ${task.createdAt.year}/${task.createdAt.month}/${task.createdAt.day}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
