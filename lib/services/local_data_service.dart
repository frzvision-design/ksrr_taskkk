import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/task_model.dart';
import '../models/checklist_item_model.dart';

/// سرویس لوکال برای تست آفلاین
/// تمام داده‌ها در shared_preferences ذخیره می‌شوند
class LocalDataService {
  static const String _usersKey = 'local_users';
  static const String _tasksKey = 'local_tasks';
  static const String _checklistKey = 'local_checklist';

  // ==================== INIT ====================

  /// مقداردهی اولیه داده‌های پیش‌فرض
  Future<void> initDefaultData() async {
    final prefs = await SharedPreferences.getInstance();

    // اگر قبلاً داده وجود دارد، مقداردهی نکن
    if (prefs.containsKey(_usersKey)) return;

    // کاربران پیش‌فرض
    final defaultUsers = [
      UserModel(
        uid: 'admin-001',
        name: 'مدیر سیستم',
        username: 'admin',
        password: 'admin123',
        role: 'admin',
      ),
      UserModel(
        uid: 'emp-001',
        name: 'علی احمدی',
        username: 'ali',
        password: '1234',
        role: 'employee',
      ),
      UserModel(
        uid: 'emp-002',
        name: 'سارا محمدی',
        username: 'sara',
        password: '1234',
        role: 'employee',
      ),
    ];

    // تسک‌های پیش‌فرض
    final defaultTasks = [
      TaskModel(
        taskId: 'task-001',
        title: 'تهیه گزارش ماهانه',
        description: 'گزارش کامل عملکرد ماه جاری را آماده کنید',
        assignedTo: 'emp-001',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        deadline: DateTime.now().add(const Duration(days: 5)),
      ),
      TaskModel(
        taskId: 'task-002',
        title: 'برگزاری جلسه تیم',
        description: 'جلسه هفتگی با اعضای تیم برگزار شود',
        assignedTo: 'emp-001',
        status: 'in_progress',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        deadline: DateTime.now().add(const Duration(days: 2)),
      ),
      TaskModel(
        taskId: 'task-003',
        title: 'بروزرسانی سیستم',
        description: 'نرم‌افزارهای سیستم را به‌روز کنید',
        assignedTo: 'emp-002',
        status: 'completed',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        deadline: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    // ذخیره در local storage
    await prefs.setString(
      _usersKey,
      jsonEncode(defaultUsers.map((u) => u.toJson()).toList()),
    );
    await prefs.setString(
      _tasksKey,
      jsonEncode(defaultTasks.map((t) => t.toJson()).toList()),
    );
    await prefs.setString(_checklistKey, jsonEncode([]));
  }

  // ==================== USERS ====================

  Future<UserModel?> login(String username, String password) async {
    final users = await _getUsers();
    try {
      return users.firstWhere(
        (u) => u.username == username && u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<UserModel>> getEmployees() async {
    final users = await _getUsers();
    return users.where((u) => u.role == 'employee').toList();
  }

  Future<bool> createUser(UserModel user) async {
    final users = await _getUsers();
    users.add(user);
    return await _saveUsers(users);
  }

  Future<List<UserModel>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_usersKey);
    if (json == null) return [];
    final List list = jsonDecode(json);
    return list.map((e) => UserModel.fromJson(e)).toList();
  }

  Future<bool> _saveUsers(List<UserModel> users) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(
      _usersKey,
      jsonEncode(users.map((u) => u.toJson()).toList()),
    );
  }

  // ==================== TASKS ====================

  Future<bool> createTask(TaskModel task) async {
    final tasks = await _getTasks();
    tasks.add(task);
    return await _saveTasks(tasks);
  }

  Future<List<TaskModel>> getAllTasks() async {
    return await _getTasks();
  }

  Future<List<TaskModel>> getTasksByEmployee(String uid) async {
    final tasks = await _getTasks();
    return tasks.where((t) => t.assignedTo == uid).toList();
  }

  Future<bool> updateTaskStatus(String taskId, String status) async {
    final tasks = await _getTasks();
    final index = tasks.indexWhere((t) => t.taskId == taskId);
    if (index == -1) return false;

    // TaskModel غیرقابل تغییر است، پس یک نمونه جدید می‌سازیم
    final old = tasks[index];
    tasks[index] = TaskModel(
      taskId: old.taskId,
      title: old.title,
      description: old.description,
      assignedTo: old.assignedTo,
      status: status,
      createdAt: old.createdAt,
      deadline: old.deadline,
    );
    return await _saveTasks(tasks);
  }

  Future<List<TaskModel>> _getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_tasksKey);
    if (json == null) return [];
    final List list = jsonDecode(json);
    return list.map((e) => TaskModel.fromJson(e)).toList();
  }

  Future<bool> _saveTasks(List<TaskModel> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(
      _tasksKey,
      jsonEncode(tasks.map((t) => t.toJson()).toList()),
    );
  }

  // ==================== CHECKLIST ====================

  Future<List<ChecklistItemModel>> getChecklistByEmployee(String uid) async {
    final items = await _getChecklist();
    return items.where((i) => i.employeeUid == uid).toList();
  }

  Future<bool> createChecklistItem(ChecklistItemModel item) async {
    final items = await _getChecklist();
    items.add(item);
    return await _saveChecklist(items);
  }

  Future<bool> updateChecklistItem(ChecklistItemModel updated) async {
    final items = await _getChecklist();
    final index = items.indexWhere((i) => i.id == updated.id);
    if (index == -1) return false;
    items[index] = updated;
    return await _saveChecklist(items);
  }

  Future<bool> deleteChecklistItem(String id) async {
    final items = await _getChecklist();
    items.removeWhere((i) => i.id == id);
    return await _saveChecklist(items);
  }

  Future<List<ChecklistItemModel>> _getChecklist() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_checklistKey);
    if (json == null) return [];
    final List list = jsonDecode(json);
    return list.map((e) => ChecklistItemModel.fromJson(e)).toList();
  }

  Future<bool> _saveChecklist(List<ChecklistItemModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(
      _checklistKey,
      jsonEncode(items.map((i) => i.toJson()).toList()),
    );
  }
}
