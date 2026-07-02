import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../services/sheets_service.dart';
import '../../widgets/task_card.dart';

class OverviewDashboardTab extends StatefulWidget {
  const OverviewDashboardTab({Key? key}) : super(key: key);

  @override
  State<OverviewDashboardTab> createState() => _OverviewDashboardTabState();
}

class _OverviewDashboardTabState extends State<OverviewDashboardTab> {
  final _sheetsService = SheetsService();
  List<TaskModel> _allTasks = [];
  String _selectedFilter = 'all'; // 'all', 'pending', 'in_progress', 'completed', 'overdue'
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    _allTasks = await _sheetsService.getAllTasks();
    setState(() => _isLoading = false);
  }

  List<TaskModel> get _filteredTasks {
    switch (_selectedFilter) {
      case 'pending':
        return _allTasks.where((t) => t.status == 'pending').toList();
      case 'in_progress':
        return _allTasks.where((t) => t.status == 'in_progress').toList();
      case 'completed':
        return _allTasks.where((t) => t.status == 'completed').toList();
      case 'overdue':
        return _allTasks.where((t) => t.isOverdue).toList();
      default:
        return _allTasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _allTasks.where((t) => t.status == 'pending').length;
    final inProgressCount = _allTasks.where((t) => t.status == 'in_progress').length;
    final completedCount = _allTasks.where((t) => t.status == 'completed').length;
    final overdueCount = _allTasks.where((t) => t.isOverdue).length;

    return Column(
      children: [
        // Statistics Cards
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard('در انتظار', pendingCount, Colors.orange),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('در حال انجام', inProgressCount, Colors.blue),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('تکمیل شده', completedCount, Colors.green),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('منقضی', overdueCount, Colors.red),
              ),
            ],
          ),
        ),
        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildFilterChip('همه', 'all'),
              _buildFilterChip('در انتظار', 'pending'),
              _buildFilterChip('در حال انجام', 'in_progress'),
              _buildFilterChip('تکمیل شده', 'completed'),
              _buildFilterChip('منقضی', 'overdue'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Tasks List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredTasks.isEmpty
                  ? const Center(
                      child: Text(
                        'هیچ تسکی یافت نشد',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadTasks,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredTasks.length,
                        itemBuilder: (context, index) {
                          return TaskCard(
                            task: _filteredTasks[index],
                            onRefresh: _loadTasks,
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() => _selectedFilter = value);
        },
      ),
    );
  }
}
