import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../services/sheets_service.dart';
import '../../widgets/countdown_timer.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailScreen({Key? key, required this.task}) : super(key: key);

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _sheetsService = SheetsService();
  late String _currentStatus;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.task.status;
  }

  Color _getStatusColor() {
    if (widget.task.isOverdue && _currentStatus != 'completed') return Colors.red;
    if (_currentStatus == 'completed') return Colors.green;
    if (_currentStatus == 'in_progress') return Colors.blue;
    return Colors.orange;
  }

  String _getStatusText() {
    if (widget.task.isOverdue && _currentStatus != 'completed') return 'منقضی شده';
    if (_currentStatus == 'completed') return 'تکمیل شده';
    if (_currentStatus == 'in_progress') return 'در حال انجام';
    return 'در انتظار';
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);

    final success = await _sheetsService.updateTaskStatus(
      widget.task.taskId,
      newStatus,
    );

    setState(() => _isUpdating = false);

    if (success) {
      setState(() => _currentStatus = newStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('وضعیت تسک به‌روزرسانی شد')),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطا در به‌روزرسانی وضعیت')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جزئیات تسک'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Title
            Text(
              widget.task.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 16),
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getStatusText(),
                style: TextStyle(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Countdown Timer
            if (_currentStatus != 'completed')
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'زمان باقی‌مانده',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CountdownTimer(deadline: widget.task.deadline),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Description
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'توضیحات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.task.description,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Dates Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${widget.task.createdAt.year}/${widget.task.createdAt.month}/${widget.task.createdAt.day} - ${widget.task.createdAt.hour}:${widget.task.createdAt.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.event, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'تاریخ ایجاد:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${widget.task.deadline.year}/${widget.task.deadline.month}/${widget.task.deadline.day} - ${widget.task.deadline.hour}:${widget.task.deadline.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 16,
                            color: widget.task.isOverdue ? Colors.red : null,
                            fontWeight: widget.task.isOverdue ? FontWeight.bold : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.alarm,
                          size: 20,
                          color: widget.task.isOverdue ? Colors.red : null,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'مهلت تحویل:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Action Buttons
            if (_currentStatus != 'completed')
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_currentStatus == 'pending')
                    ElevatedButton(
                      onPressed: _isUpdating
                          ? null
                          : () => _updateStatus('in_progress'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isUpdating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'شروع انجام تسک',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  if (_currentStatus == 'in_progress') ...[
                    ElevatedButton(
                      onPressed: _isUpdating
                          ? null
                          : () => _updateStatus('completed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isUpdating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'تکمیل تسک',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _isUpdating
                          ? null
                          : () => _updateStatus('pending'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'بازگشت به حالت در انتظار',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
