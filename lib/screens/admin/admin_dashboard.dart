import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';
import '../settings_screen.dart';
import 'employee_management_tab.dart';
import 'task_creation_tab.dart';
import 'overview_dashboard_tab.dart';
import '../common/personal_checklist_screen.dart';

class AdminDashboard extends StatefulWidget {
  final UserModel user;
  final Function(ThemeMode) onThemeChanged;

  const AdminDashboard({
    Key? key,
    required this.user,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;
  final _authService = AuthService();

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      const EmployeeManagementTab(),
      const TaskCreationTab(),
      PersonalChecklistScreen(userId: widget.user.id), // چک‌لیست شخصی
      const OverviewDashboardTab(),
      SettingsScreen(onThemeChanged: widget.onThemeChanged),
    ];
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('پنل مدیریت'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'خروج',
          ),
        ],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'کارمندان',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_task),
            label: 'ایجاد وظیفه',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'چک‌لیست',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'داشبورد',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'تنظیمات',
          ),
        ],
      ),
    );
  }
}
