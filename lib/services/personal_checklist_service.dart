import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/checklist_category_model.dart';
import '../models/checklist_item_model.dart';
import '../models/checklist_todo_model.dart';

class PersonalChecklistService {
  static const String _categoriesKey = 'personal_checklist_categories';
  static const String _itemsKey = 'personal_checklist_items';
  static const String _todosKey = 'personal_checklist_todos';

  // ==================== Categories ====================
  
  Future<List<ChecklistCategoryModel>> getAllCategories(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_categoriesKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final allCategories = jsonList.map((json) => ChecklistCategoryModel.fromJson(json)).toList();
      return allCategories.where((cat) => cat.userId == userId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print('Error loading categories: $e');
      return [];
    }
  }

  Future<bool> createCategory(ChecklistCategoryModel category) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_categoriesKey) ?? '[]';
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final categories = jsonList.map((json) => ChecklistCategoryModel.fromJson(json)).toList();
      
      categories.add(category);
      
      final updatedJsonString = jsonEncode(categories.map((c) => c.toJson()).toList());
      await prefs.setString(_categoriesKey, updatedJsonString);
      return true;
    } catch (e) {
      print('Error creating category: $e');
      return false;
    }
  }

  Future<bool> updateCategory(ChecklistCategoryModel category) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_categoriesKey) ?? '[]';
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final categories = jsonList.map((json) => ChecklistCategoryModel.fromJson(json)).toList();
      
      final index = categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        categories[index] = category;
        final updatedJsonString = jsonEncode(categories.map((c) => c.toJson()).toList());
        await prefs.setString(_categoriesKey, updatedJsonString);
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating category: $e');
      return false;
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    try {
      // Delete category
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_categoriesKey) ?? '[]';
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final categories = jsonList.map((json) => ChecklistCategoryModel.fromJson(json)).toList();
      
      categories.removeWhere((c) => c.id == categoryId);
      
      final updatedJsonString = jsonEncode(categories.map((c) => c.toJson()).toList());
      await prefs.setString(_categoriesKey, updatedJsonString);
      
      // Delete all items in this category
      await _deleteItemsByCategory(categoryId);
      
      return true;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }

  // ==================== Items ====================
  
  Future<List<ChecklistItemModel>> getItemsByCategory(String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_itemsKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final allItems = jsonList.map((json) => ChecklistItemModel.fromJson(json)).toList();
      return allItems.where((item) => item.categoryId == categoryId).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    } catch (e) {
      print('Error loading items: $e');
      return [];
    }
  }

  Future<bool> createItem(ChecklistItemModel item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_itemsKey) ?? '[]';
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final items = jsonList.map((json) => ChecklistItemModel.fromJson(json)).toList();
      
      items.add(item);
      
      final updatedJsonString = jsonEncode(items.map((i) => i.toJson()).toList());
      await prefs.setString(_itemsKey, updatedJsonString);
      return true;
    } catch (e) {
      print('Error creating item: $e');
      return false;
    }
  }

  Future<bool> updateItem(ChecklistItemModel item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_itemsKey) ?? '[]';
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final items = jsonList.map((json) => ChecklistItemModel.fromJson(json)).toList();
      
      final index = items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        items[index] = item;
        final updatedJsonString = jsonEncode(items.map((i) => i.toJson()).toList());
        await prefs.setString(_itemsKey, updatedJsonString);
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating item: $e');
      return false;
    }
  }

  Future<bool> deleteItem(String itemId) async {
    try {
      // Delete item
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_itemsKey) ?? '[]';
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final items = jsonList.map((json) => ChecklistItemModel.fromJson(json)).toList();
      
      items.removeWhere((i) => i.id == itemId);
      
      final updatedJsonString = jsonEncode(items.map((i) => i.toJson()).toList());
      await prefs.setString(_itemsKey, updatedJsonString);
      
      // Delete all todos for this item
      await _deleteTodosByItem(itemId);
      
      return true;
    } catch (e) {
      print('Error deleting item: $e');
      return false;
    }
  }

  Future<void> _deleteItemsByCategory(String categoryId) async {
    try {
      final items = await getItemsByCategory(categoryId);
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_itemsKey) ?? '[]';
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final allItems = jsonList.map((json) => ChecklistItemModel.fromJson(json)).toList();
      
      allItems.removeWhere((i) => i.categoryId == categoryId);
      
      final updatedJsonString = jsonEncode(allItems.map((i) => i.toJson()).toList());
      await prefs.setString(_itemsKey, updatedJsonString);
      
      // Delete all todos for these items
      for (var item in items) {
        await _deleteTodosByItem(item.id);
      }
    } catch (e) {
      print('Error deleting items by category: $e');
    }
  }

  // ==================== Todos ====================
  
  Future<List<ChecklistTodoModel>> getTodosByItem(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_todosKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final allTodos = jsonList.map((json) => ChecklistTodoModel.fromJson(json)).toList();
      return allTodos.where((todo) => todo.itemId == itemId).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    } catch (e) {
      print('Error loading todos: $e');
      return [];
    }
  }

  Future<bool> createTodo(ChecklistTodoModel todo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_todosKey) ?? '[]';
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final todos = jsonList.map((json) => ChecklistTodoModel.fromJson(json)).toList();
      
      todos.add(todo);
      
      final updatedJsonString = jsonEncode(todos.map((t) => t.toJson()).toList());
      await prefs.setString(_todosKey, updatedJsonString);
      return true;
    } catch (e) {
      print('Error creating todo: $e');
      return false;
    }
  }

  Future<bool> updateTodo(ChecklistTodoModel todo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_todosKey) ?? '[]';
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final todos = jsonList.map((json) => ChecklistTodoModel.fromJson(json)).toList();
      
      final index = todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        todos[index] = todo;
        final updatedJsonString = jsonEncode(todos.map((t) => t.toJson()).toList());
        await prefs.setString(_todosKey, updatedJsonString);
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating todo: $e');
      return false;
    }
  }

  Future<bool> toggleTodo(String todoId, bool isCompleted) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_todosKey) ?? '[]';
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final todos = jsonList.map((json) => ChecklistTodoModel.fromJson(json)).toList();
      
      final index = todos.indexWhere((t) => t.id == todoId);
      if (index != -1) {
        todos[index] = todos[index].copyWith(
          isCompleted: isCompleted,
          completedAt: isCompleted ? DateTime.now() : null,
        );
        final updatedJsonString = jsonEncode(todos.map((t) => t.toJson()).toList());
        await prefs.setString(_todosKey, updatedJsonString);
        return true;
      }
      return false;
    } catch (e) {
      print('Error toggling todo: $e');
      return false;
    }
  }

  Future<bool> deleteTodo(String todoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_todosKey) ?? '[]';
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final todos = jsonList.map((json) => ChecklistTodoModel.fromJson(json)).toList();
      
      todos.removeWhere((t) => t.id == todoId);
      
      final updatedJsonString = jsonEncode(todos.map((t) => t.toJson()).toList());
      await prefs.setString(_todosKey, updatedJsonString);
      return true;
    } catch (e) {
      print('Error deleting todo: $e');
      return false;
    }
  }

  Future<void> _deleteTodosByItem(String itemId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_todosKey) ?? '[]';
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final todos = jsonList.map((json) => ChecklistTodoModel.fromJson(json)).toList();
      
      todos.removeWhere((t) => t.itemId == itemId);
      
      final updatedJsonString = jsonEncode(todos.map((t) => t.toJson()).toList());
      await prefs.setString(_todosKey, updatedJsonString);
    } catch (e) {
      print('Error deleting todos by item: $e');
    }
  }

  // ==================== Statistics ====================
  
  Future<Map<String, int>> getItemStatistics(String itemId) async {
    final todos = await getTodosByItem(itemId);
    final completed = todos.where((t) => t.isCompleted).length;
    final total = todos.length;
    
    return {
      'total': total,
      'completed': completed,
      'pending': total - completed,
    };
  }

  Future<Map<String, int>> getCategoryStatistics(String categoryId) async {
    final items = await getItemsByCategory(categoryId);
    int totalTodos = 0;
    int completedTodos = 0;
    
    for (var item in items) {
      final todos = await getTodosByItem(item.id);
      totalTodos += todos.length;
      completedTodos += todos.where((t) => t.isCompleted).length;
    }
    
    return {
      'totalItems': items.length,
      'totalTodos': totalTodos,
      'completedTodos': completedTodos,
      'pendingTodos': totalTodos - completedTodos,
    };
  }

  // ==================== Clear All (for testing) ====================
  
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_categoriesKey);
    await prefs.remove(_itemsKey);
    await prefs.remove(_todosKey);
  }
}
