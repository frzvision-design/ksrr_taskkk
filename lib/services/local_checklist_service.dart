import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_checklist_model.dart';

class LocalChecklistService {
  static const String _checklistKey = 'local_checklists';

  // دریافت همه چک‌لیست‌ها
  Future<List<TaskChecklistModel>> getAllChecklists() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_checklistKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => TaskChecklistModel.fromJson(json)).toList();
    } catch (e) {
      print('Error loading checklists: $e');
      return [];
    }
  }

  // دریافت چک‌لیست برای یک task خاص (یا standalone)
  Future<List<TaskChecklistModel>> getTaskChecklist(String taskId) async {
    final allChecklists = await getAllChecklists();
    return allChecklists.where((item) => item.taskId == taskId).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  // ذخیره یک آیتم جدید
  Future<bool> createChecklistItem(TaskChecklistModel item) async {
    try {
      final allChecklists = await getAllChecklists();
      allChecklists.add(item);
      await _saveAllChecklists(allChecklists);
      return true;
    } catch (e) {
      print('Error creating checklist item: $e');
      return false;
    }
  }

  // بروزرسانی یک آیتم
  Future<bool> updateChecklistItem(TaskChecklistModel item) async {
    try {
      final allChecklists = await getAllChecklists();
      final index = allChecklists.indexWhere((i) => i.id == item.id);
      
      if (index != -1) {
        allChecklists[index] = item;
        await _saveAllChecklists(allChecklists);
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating checklist item: $e');
      return false;
    }
  }

  // حذف یک آیتم
  Future<bool> deleteChecklistItem(String id) async {
    try {
      final allChecklists = await getAllChecklists();
      allChecklists.removeWhere((item) => item.id == id);
      await _saveAllChecklists(allChecklists);
      return true;
    } catch (e) {
      print('Error deleting checklist item: $e');
      return false;
    }
  }

  // تغییر وضعیت تکمیل
  Future<bool> toggleChecklistItem(String id, bool isCompleted) async {
    try {
      final allChecklists = await getAllChecklists();
      final index = allChecklists.indexWhere((item) => item.id == id);
      
      if (index != -1) {
        final item = allChecklists[index];
        allChecklists[index] = TaskChecklistModel(
          id: item.id,
          taskId: item.taskId,
          title: item.title,
          description: item.description,
          order: item.order,
          type: item.type,
          conditionTrue: item.conditionTrue,
          conditionFalse: item.conditionFalse,
          isCompleted: isCompleted,
          createdAt: item.createdAt,
          completedAt: isCompleted ? DateTime.now() : null,
        );
        await _saveAllChecklists(allChecklists);
        return true;
      }
      return false;
    } catch (e) {
      print('Error toggling checklist item: $e');
      return false;
    }
  }

  // حذف همه چک‌لیست‌های یک task
  Future<bool> deleteTaskChecklists(String taskId) async {
    try {
      final allChecklists = await getAllChecklists();
      allChecklists.removeWhere((item) => item.taskId == taskId);
      await _saveAllChecklists(allChecklists);
      return true;
    } catch (e) {
      print('Error deleting task checklists: $e');
      return false;
    }
  }

  // ذخیره همه چک‌لیست‌ها (متد خصوصی)
  Future<void> _saveAllChecklists(List<TaskChecklistModel> checklists) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = checklists.map((item) => item.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_checklistKey, jsonString);
  }

  // پاک کردن همه داده‌ها (برای تست و دیباگ)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_checklistKey);
  }
}
