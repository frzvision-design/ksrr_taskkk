import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/checklist_item_model.dart';
import '../../services/checklist_service.dart';
import 'package:uuid/uuid.dart';

class PersonalChecklistScreen extends StatefulWidget {
  final UserModel user;

  const PersonalChecklistScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<PersonalChecklistScreen> createState() => _PersonalChecklistScreenState();
}

class _PersonalChecklistScreenState extends State<PersonalChecklistScreen> {
  final _checklistService = ChecklistService();
  final _uuid = const Uuid();
  List<ChecklistItemModel> _items = [];
  bool _isLoading = false;
  bool _showCompleted = true;

  @override
  void initState() {
    super.initState();
    _loadChecklist();
  }

  Future<void> _loadChecklist() async {
    setState(() => _isLoading = true);
    _items = await _checklistService.getChecklistByEmployee(widget.user.uid);
    setState(() => _isLoading = false);
  }

  Future<void> _showAddItemDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('آیتم جدید'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان',
                    prefixIcon: Icon(Icons.title),
                  ),
                  textDirection: TextDirection.rtl,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'عنوان را وارد کنید' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'توضیحات (اختیاری)',
                    prefixIcon: Icon(Icons.description),
                  ),
                  textDirection: TextDirection.rtl,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final item = ChecklistItemModel(
                  id: _uuid.v4(),
                  employeeUid: widget.user.uid,
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  isCompleted: false,
                  createdAt: DateTime.now(),
                );

                final success = await _checklistService.createChecklistItem(item);
                if (!context.mounted) return;

                Navigator.pop(context);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('آیتم با موفقیت اضافه شد')),
                  );
                  _loadChecklist();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('خطا در افزودن آیتم')),
                  );
                }
              }
            },
            child: const Text('افزودن'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleItemCompletion(ChecklistItemModel item) async {
    final updatedItem = item.copyWith(
      isCompleted: !item.isCompleted,
      completedAt: !item.isCompleted ? DateTime.now() : null,
    );

    final success = await _checklistService.updateChecklistItem(updatedItem);
    
    if (success) {
      _loadChecklist();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطا در بروزرسانی آیتم')),
      );
    }
  }

  Future<void> _deleteItem(ChecklistItemModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف آیتم'),
        content: Text(
          'آیا مطمئن هستید که می‌خواهید "${item.title}" را حذف کنید؟',
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('انصراف'),
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
      final success = await _checklistService.deleteChecklistItem(item.id);
      
      if (!mounted) return;
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('آیتم با موفقیت حذف شد')),
        );
        _loadChecklist();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطا در حذف آیتم')),
        );
      }
    }
  }

  List<ChecklistItemModel> get _filteredItems {
    if (_showCompleted) {
      return _items;
    }
    return _items.where((item) => !item.isCompleted).toList();
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _items.where((item) => item.isCompleted).length;
    final totalCount = _items.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('چک لیست شخصی من'),
        actions: [
          IconButton(
            icon: Icon(_showCompleted ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() => _showCompleted = !_showCompleted);
            },
            tooltip: _showCompleted ? 'مخفی کردن تکمیل شده‌ها' : 'نمایش تکمیل شده‌ها',
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Card
          if (totalCount > 0)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'پیشرفت',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$completedCount / $totalCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: totalCount > 0 ? completedCount / totalCount : 0,
                      minHeight: 8,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          
          // Checklist Items
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _showCompleted ? Icons.check_circle_outline : Icons.done_all,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _showCompleted
                                  ? 'هیچ آیتمی وجود ندارد'
                                  : 'همه آیتم‌ها تکمیل شده‌اند!',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadChecklist,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: item.isCompleted ? 1 : 2,
                              child: ListTile(
                                leading: Checkbox(
                                  value: item.isCompleted,
                                  onChanged: (_) => _toggleItemCompletion(item),
                                ),
                                title: Text(
                                  item.title,
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    decoration: item.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: item.isCompleted
                                        ? Colors.grey
                                        : null,
                                  ),
                                ),
                                subtitle: item.description.isNotEmpty
                                    ? Text(
                                        item.description,
                                        textDirection: TextDirection.rtl,
                                        style: TextStyle(
                                          color: item.isCompleted
                                              ? Colors.grey
                                              : null,
                                        ),
                                      )
                                    : null,
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteItem(item),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemDialog,
        icon: const Icon(Icons.add),
        label: const Text('آیتم جدید'),
      ),
    );
  }
}
