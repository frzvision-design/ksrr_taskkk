import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/backend_service.dart';

class TaskProvider extends ChangeNotifier {
  final _backendService = BackendService();
  
  List<TaskModel> _allTasks = [];
  List<TaskModel> _userTasks = [];
  bool _isLoading = false;
  String? _error;

  List<TaskModel> get allTasks => _allTasks;
  List<TaskModel> get userTasks => _userTasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get all tasks (admin)
  Future<void> loadAllTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allTasks = await _backendService.getAllTasks();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get tasks by employee
  Future<void> loadUserTasks(String uid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userTasks = await _backendService.getTasksByEmployee(uid);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create task
  Future<bool> createTask(TaskModel task) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _backendService.createTask(task);
      if (success) {
        await loadAllTasks();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update task status
  Future<bool> updateTaskStatus(String taskId, String status) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _backendService.updateTaskStatus(taskId, status);
      if (success) {
        // Refresh tasks
        _allTasks = _allTasks.map((t) {
          if (t.taskId == taskId) {
            return TaskModel(
              taskId: t.taskId,
              title: t.title,
              description: t.description,
              assignedTo: t.assignedTo,
              status: status,
              createdAt: t.createdAt,
              deadline: t.deadline,
            );
          }
          return t;
        }).toList();
        
        _userTasks = _userTasks.map((t) {
          if (t.taskId == taskId) {
            return TaskModel(
              taskId: t.taskId,
              title: t.title,
              description: t.description,
              assignedTo: t.assignedTo,
              status: status,
              createdAt: t.createdAt,
              deadline: t.deadline,
            );
          }
          return t;
        }).toList();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
