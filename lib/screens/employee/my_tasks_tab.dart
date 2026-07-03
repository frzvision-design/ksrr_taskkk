import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/task_model.dart';
import '../../services/backend_service.dart';
import 'task_detail_screen.dart';
import '../../widgets/countdown_timer.dart';

class MyTasksTab extends StatefulWidget {
  final UserModel user;

  const MyTasksTab({Key? key, required this.user}) : super(key: key);

  @override
  State<MyTasksTab> createState() => _MyTasksTabState();
}

class _MyTasksTabState extends State<MyTasksTab> {
  final _backendService = BackendService();
  List<TaskModel> _tasks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    _tasks = await _backendService.getTasksByEmployee(widget.user.uid);
    setState(() => _isLoading = false);
  }

  Color _getStatusColor(TaskModel task) {
    if (task.isOverdue) return Colors.red;
    if (task.status == 'completed') return Colors.green;
    if (task.status == 'in_progress') return Colors.blue;
    return Colors.orange;
  }

  String _getStatusText(TaskModel task) {
    if (task.isOverdue && task.status != 'completed') return 'منقضی شده';
    if (task.status == 'completed') return 'تکمیل شده';
    if (task.status == 'in_progress') return 'در حال انجام';
    return 'در انتظار';
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _tasks.isEmpty
            ? const Center(
                child: Text(
                  'هیچ وظیفه‌ای به شما اختصاص داده نشده است',
                  style: TextStyle(fontSize: 18),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadTasks,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TaskDetailScreen(task: task),
                            ),
                          );
                          _loadTasks();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                task.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(task).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getStatusText(task),
                                  style: TextStyle(
                                    color: _getStatusColor(task),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (task.status != 'completed')
                                CountdownTimer(deadline: task.deadline),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'ایجاد شده: ${task.createdAt.year}/${task.createdAt.month}/${task.createdAt.day}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.calendar_today,
                                    size: 12,
                                    color: Colors.grey[600],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
  }
}
