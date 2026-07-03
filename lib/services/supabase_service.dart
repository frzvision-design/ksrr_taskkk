import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/task_model.dart';
import '../models/checklist_item_model.dart';
import '../models/task_checklist_model.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://gywuopnmxnvjdskmmnmi.supabase.co';
  static const String supabaseKey = 'sb_publishable_pNOFiK5NT4JG6wWyk_OCrA_hAz2NwjF';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit,
      ),
    );
  }

  final _client = Supabase.instance.client;

  // ==================== USERS ====================

  Future<UserModel?> login(String username, String password) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('username', username)
          .eq('password', password)
          .maybeSingle();

      if (response != null) {
        return UserModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<bool> createUser(UserModel user) async {
    try {
      await _client.from('users').insert(user.toJson());
      return true;
    } catch (e) {
      print('Create user error: $e');
      return false;
    }
  }

  Future<List<UserModel>> getEmployees() async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('role', 'employee');

      return (response as List)
          .map((e) => UserModel.fromJson(e))
          .toList();
    } catch (e) {
      print('Get employees error: $e');
      return [];
    }
  }

  // ==================== TASKS ====================

  Future<bool> createTask(TaskModel task) async {
    try {
      await _client.from('tasks').insert(task.toJson());
      return true;
    } catch (e) {
      print('Create task error: $e');
      return false;
    }
  }

  Future<List<TaskModel>> getAllTasks() async {
    try {
      final response = await _client
          .from('tasks')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => TaskModel.fromJson(e))
          .toList();
    } catch (e) {
      print('Get all tasks error: $e');
      return [];
    }
  }

  Future<List<TaskModel>> getTasksByEmployee(String uid) async {
    try {
      final response = await _client
          .from('tasks')
          .select()
          .eq('assigned_to', uid)
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => TaskModel.fromJson(e))
          .toList();
    } catch (e) {
      print('Get tasks by employee error: $e');
      return [];
    }
  }

  Future<bool> updateTaskStatus(String taskId, String status) async {
    try {
      await _client
          .from('tasks')
          .update({'status': status})
          .eq('task_id', taskId);
      return true;
    } catch (e) {
      print('Update task status error: $e');
      return false;
    }
  }

  // ==================== CHECKLIST ====================

  Future<List<ChecklistItemModel>> getChecklistByEmployee(String uid) async {
    try {
      final response = await _client
          .from('checklist')
          .select()
          .eq('employee_uid', uid)
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => ChecklistItemModel.fromJson(e))
          .toList();
    } catch (e) {
      print('Get checklist error: $e');
      return [];
    }
  }

  Future<bool> createChecklistItem(ChecklistItemModel item) async {
    try {
      await _client.from('checklist').insert(item.toJson());
      return true;
    } catch (e) {
      print('Create checklist item error: $e');
      return false;
    }
  }

  Future<bool> updateChecklistItem(ChecklistItemModel item) async {
    try {
      await _client
          .from('checklist')
          .update(item.toJson())
          .eq('id', item.id);
      return true;
    } catch (e) {
      print('Update checklist item error: $e');
      return false;
    }
  }

  Future<bool> deleteChecklistItem(String id) async {
    try {
      await _client
          .from('checklist')
          .delete()
          .eq('id', id);
      return true;
    } catch (e) {
      print('Delete checklist item error: $e');
      return false;
    }
  }

  // ==================== TASK CHECKLIST ====================

  Future<List<TaskChecklistModel>> getTaskChecklist(String taskId) async {
    try {
      final response = await _client
          .from('task_checklist')
          .select()
          .eq('task_id', taskId)
          .order('order', ascending: true);

      return (response as List)
          .map((e) => TaskChecklistModel.fromJson(e))
          .toList();
    } catch (e) {
      print('Get task checklist error: $e');
      return [];
    }
  }

  Future<bool> createTaskChecklistItem(TaskChecklistModel item) async {
    try {
      await _client.from('task_checklist').insert(item.toJson());
      return true;
    } catch (e) {
      print('Create task checklist item error: $e');
      return false;
    }
  }

  Future<bool> updateTaskChecklistItem(TaskChecklistModel item) async {
    try {
      await _client
          .from('task_checklist')
          .update(item.toJson())
          .eq('id', item.id);
      return true;
    } catch (e) {
      print('Update task checklist item error: $e');
      return false;
    }
  }

  Future<bool> deleteTaskChecklistItem(String id) async {
    try {
      await _client.from('task_checklist').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Delete task checklist item error: $e');
      return false;
    }
  }

  Future<bool> toggleTaskChecklistItem(String id, bool isCompleted) async {
    try {
      await _client.from('task_checklist').update({
        'is_completed': isCompleted,
        'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
      }).eq('id', id);
      return true;
    } catch (e) {
      print('Toggle task checklist item error: $e');
      return false;
    }
  }
}
