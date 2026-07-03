import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';
import '../settings_screen.dart';
import 'my_tasks_tab.dart';
import '../common/personal_checklist_screen.dart';

class EmployeeDashboard extends StatefulWidget {
  final UserModel user;
  final Function(ThemeMode) onThemeChanged;

  const EmployeeDashboard({
    Key? key,
    required this.user,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  final _authService = AuthService();
  int _currentIndex = 0;

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      MyTasksTab(user: widget.user),
      PersonalChecklistScreen(userId: widget.user.uid), // چک‌لیست شخصی
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
        title: Text('${widget.user.name}'),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: 'وظایف من',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'چک‌لیست',
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
