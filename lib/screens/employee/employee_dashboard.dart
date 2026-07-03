import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/task_model.dart';
import '../../services/auth_service.dart';
import '../../services/backend_service.dart';
import '../login_screen.dart';
import 'task_detail_screen.dart';
import 'personal_checklist_screen.dart';
import 'task_checklist_view_screen.dart';
import '../../widgets/countdown_timer.dart';

class EmployeeDashboard extends StatefulWidget {
  final UserModel user;

  const EmployeeDashboard({Key? key, required this.user}) : super(key: key);

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  final _authService = AuthService();
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

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
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
    return Scaffold(
      appBar: AppBar(
        title: Text('وظایف من - ${widget.user.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PersonalChecklistScreen(user: widget.user),
                ),
              );
            },
            tooltip: 'چک لیست شخصی',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'خروج',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? const Center(
                  child: Text(
                    'هیچ تسکی به شما اختصاص داده نشده است',
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
                                // Status Badge
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
                                // Countdown Timer
                                if (task.status != 'completed')
                                  CountdownTimer(deadline: task.deadline),
                                const SizedBox(height: 8),
                                // Created Date
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
                                const SizedBox(height: 12),
                                // Checklist Button
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => TaskChecklistViewScreen(task: task),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.checklist_rtl, size: 20),
                                    label: const Text(
                                      'مشاهده چک‌لیست کار',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFFD4AF37),
                                      side: BorderSide(color: const Color(0xFFD4AF37)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
