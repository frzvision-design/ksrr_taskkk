import '../models/user_model.dart';
import '../models/task_model.dart';
import 'supabase_service.dart';

class SheetsService {
  final _supabase = SupabaseService();

  Future<UserModel?> login(String username, String password) async {
    return await _supabase.login(username, password);
  }

  Future<bool> createUser(UserModel user) async {
    return await _supabase.createUser(user);
  }

  Future<List<UserModel>> getEmployees() async {
    return await _supabase.getEmployees();
  }

  Future<bool> createTask(TaskModel task) async {
    return await _supabase.createTask(task);
  }

  Future<List<TaskModel>> getAllTasks() async {
    return await _supabase.getAllTasks();
  }

  Future<List<TaskModel>> getTasksByEmployee(String uid) async {
    return await _supabase.getTasksByEmployee(uid);
  }

  Future<bool> updateTaskStatus(String taskId, String status) async {
    return await _supabase.updateTaskStatus(taskId, status);
  }
}
