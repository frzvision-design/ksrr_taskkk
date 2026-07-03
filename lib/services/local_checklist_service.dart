import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/personal_checklist_model.dart';

class LocalChecklistService {
  static const String _keyPrefix = 'personal_checklist_';

  String _key(String userUid) => '$_keyPrefix$userUid';

  Future<List<PersonalChecklistCategory>> getCategories(String userUid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key(userUid));
      if (raw == null) return [];
      final List<dynamic> list = jsonDecode(raw);
      return list.map((e) => PersonalChecklistCategory.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveCategories(
      String userUid, List<PersonalChecklistCategory> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(categories.map((c) => c.toJson()).toList());
    await prefs.setString(_key(userUid), encoded);
  }

  Future<bool> addCategory(
      String userUid, PersonalChecklistCategory category) async {
    try {
      final categories = await getCategories(userUid);
      categories.add(category);
      await _saveCategories(userUid, categories);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateCategory(
      String userUid, PersonalChecklistCategory updated) async {
    try {
      final categories = await getCategories(userUid);
      final index = categories.indexWhere((c) => c.id == updated.id);
      if (index == -1) return false;
      categories[index] = updated;
      await _saveCategories(userUid, categories);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteCategory(String userUid, String categoryId) async {
    try {
      final categories = await getCategories(userUid);
      categories.removeWhere((c) => c.id == categoryId);
      await _saveCategories(userUid, categories);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addStep(
      String userUid, String categoryId, PersonalChecklistStep step) async {
    try {
      final categories = await getCategories(userUid);
      final index = categories.indexWhere((c) => c.id == categoryId);
      if (index == -1) return false;
      final updatedSteps = List<PersonalChecklistStep>.from(categories[index].steps)
        ..add(step);
      categories[index] = categories[index].copyWith(steps: updatedSteps);
      await _saveCategories(userUid, categories);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleStep(
      String userUid, String categoryId, String stepId) async {
    try {
      final categories = await getCategories(userUid);
      final catIndex = categories.indexWhere((c) => c.id == categoryId);
      if (catIndex == -1) return false;

      final steps = List<PersonalChecklistStep>.from(categories[catIndex].steps);
      final stepIndex = steps.indexWhere((s) => s.id == stepId);
      if (stepIndex == -1) return false;

      final step = steps[stepIndex];
      steps[stepIndex] = step.copyWith(
        isCompleted: !step.isCompleted,
        completedAt: !step.isCompleted ? DateTime.now() : null,
        clearCompletedAt: step.isCompleted,
      );

      categories[catIndex] = categories[catIndex].copyWith(steps: steps);
      await _saveCategories(userUid, categories);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteStep(
      String userUid, String categoryId, String stepId) async {
    try {
      final categories = await getCategories(userUid);
      final catIndex = categories.indexWhere((c) => c.id == categoryId);
      if (catIndex == -1) return false;

      final steps = List<PersonalChecklistStep>.from(categories[catIndex].steps)
        ..removeWhere((s) => s.id == stepId);
      categories[catIndex] = categories[catIndex].copyWith(steps: steps);
      await _saveCategories(userUid, categories);
      return true;
    } catch (e) {
      return false;
    }
  }
}
