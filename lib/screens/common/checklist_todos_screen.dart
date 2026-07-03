import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/checklist_item_model.dart';
import '../../models/checklist_todo_model.dart';
import '../../services/personal_checklist_service.dart';

class ChecklistTodosScreen extends StatefulWidget {
  final ChecklistItemModel item;
  final String categoryTitle;

  const ChecklistTodosScreen({
    Key? key,
    required this.item,
    required this.categoryTitle,
  }) : super(key: key);

  @override
  State<ChecklistTodosScreen> createState() => _ChecklistTodosScreenState();
}

class _ChecklistTodosScreenState extends State<ChecklistTodosScreen> {
  final _service = PersonalChecklistService();
  final _uuid = const Uuid();
  List<ChecklistTodoModel> _todos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    setState(() => _isLoading = true);
    _todos = await _service.getTodosByItem(widget.item.id);
    setState(() => _isLoading = false);
  }

  Future<void> _addTodo() async {
    final titleController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('چک باکس جدید', textDirection: TextDirection.rtl),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'عنوان',
            hintText: 'مثال: مدارک را آماده کنم',
            border: OutlineInputBorder(),
          ),
          textDirection: TextDirection.rtl,
          autofocus: true,
          onSubmitted: (value) => Navigator.pop(context, true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لغو'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('افزودن'),
          ),
        ],
      ),
    );

    if (result == true && titleController.text.isNotEmpty) {
      final newTodo = ChecklistTodoModel(
        id: _uuid.v4(),
        itemId: widget.item.id,
        title: titleController.text,
        order: _todos.length,
        createdAt: DateTime.now(),
      );

      final success = await _service.createTodo(newTodo);
      if (success) {
        await _loadTodos();
      }
    }
  }

  Future<void> _toggleTodo(ChecklistTodoModel todo) async {
    final success = await _service.toggleTodo(todo.id, !todo.isCompleted);
    if (success) {
      await _loadTodos();
    }
  }

  Future<void> _deleteTodo(ChecklistTodoModel todo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف چک باکس', textDirection: TextDirection.rtl),
        content: Text(
          'آیا مطمئن هستید که می‌خواهید "${todo.title}" را حذف کنید؟',
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لغو'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _service.deleteTodo(todo.id);
      if (success) {
        await _loadTodos();
      }
    }
  }

  Future<void> _editTodo(ChecklistTodoModel todo) async {
    final titleController = TextEditingController(text: todo.title);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ویرایش چک باکس', textDirection: TextDirection.rtl),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'عنوان',
            border: OutlineInputBorder(),
          ),
          textDirection: TextDirection.rtl,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لغو'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );

    if (result == true && titleController.text.isNotEmpty) {
      final updatedTodo = todo.copyWith(title: titleController.text);
      final success = await _service.updateTodo(updatedTodo);
      if (success) {
        await _loadTodos();
      }
    }
  }

  int get _completedCount => _todos.where((t) => t.isCompleted).length;
  double get _progress => _todos.isEmpty ? 0 : _completedCount / _todos.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.item.title,
          style: const TextStyle(fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Progress Card
                if (_todos.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFD4AF37).withOpacity(0.2),
                          const Color(0xFFD4AF37).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _progress == 1.0
                                    ? Colors.green
                                    : const Color(0xFFD4AF37),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${(_progress * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              '$_completedCount از ${_todos.length}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _progress,
                            minHeight: 10,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _progress == 1.0
                                  ? Colors.green
                                  : const Color(0xFFD4AF37),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Todos List
                Expanded(
                  child: _todos.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _todos.length,
                          itemBuilder: (context, index) {
                            final todo = _todos[index];
                            return _buildTodoItem(todo, index);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTodo,
        icon: const Icon(Icons.add),
        label: const Text('چک باکس جدید'),
        backgroundColor: const Color(0xFFD4AF37),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_box_outline_blank,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'هنوز چک باکسی اضافه نشده',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'چک باکس‌هایی که باید انجام دهید را اضافه کنید',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoItem(ChecklistTodoModel todo, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: todo.isCompleted ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: todo.isCompleted
              ? Colors.green.withOpacity(0.5)
              : Colors.grey.shade300,
          width: todo.isCompleted ? 2 : 1,
        ),
      ),
      color: todo.isCompleted ? Colors.green.shade50 : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: todo.isCompleted,
            onChanged: (value) => _toggleTodo(todo),
            activeColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        title: Text(
          todo.title,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: 16,
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: todo.isCompleted && todo.completedAt != null
            ? Text(
                'انجام شد',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade700,
                ),
                textDirection: TextDirection.rtl,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              color: Colors.blue,
              onPressed: () => _editTodo(todo),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              color: Colors.red,
              onPressed: () => _deleteTodo(todo),
            ),
          ],
        ),
      ),
    );
  }
}
