import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../models/task_checklist_model.dart';
import '../../services/backend_service.dart';
import 'package:uuid/uuid.dart';

class TaskChecklistBuilderScreen extends StatefulWidget {
  final TaskModel task;

  const TaskChecklistBuilderScreen({Key? key, required this.task}) : super(key: key);

  @override
  State<TaskChecklistBuilderScreen> createState() => _TaskChecklistBuilderScreenState();
}

class _TaskChecklistBuilderScreenState extends State<TaskChecklistBuilderScreen> {
  final _backendService = BackendService();
  final _uuid = const Uuid();
  List<TaskChecklistModel> _checklistItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChecklist();
  }

  Future<void> _loadChecklist() async {
    setState(() => _isLoading = true);
    _checklistItems = await _backendService.getTaskChecklist(widget.task.taskId);
    setState(() => _isLoading = false);
  }

  Future<void> _addChecklistItem(String type) async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String? conditionTrue;
    String? conditionFalse;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            type == 'start' ? 'نقطه شروع' :
            type == 'step' ? 'مرحله جدید' :
            type == 'condition' ? 'شرط' : 'نقطه پایان',
            textDirection: TextDirection.rtl,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان',
                    border: OutlineInputBorder(),
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'توضیحات',
                    border: OutlineInputBorder(),
                  ),
                  textDirection: TextDirection.rtl,
                  maxLines: 3,
                ),
                if (type == 'condition') ...[
                  const SizedBox(height: 16),
                  const Text(
                    'در صورت درست بودن شرط، به کدام مرحله برود؟',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontSize: 12),
                  ),
                  DropdownButton<String>(
                    value: conditionTrue,
                    isExpanded: true,
                    hint: const Text('انتخاب مرحله (اختیاری)', textDirection: TextDirection.rtl),
                    items: _checklistItems
                        .map((item) => DropdownMenuItem(
                              value: item.id,
                              child: Text(item.title, textDirection: TextDirection.rtl),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() => conditionTrue = value);
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'در صورت نادرست بودن شرط، به کدام مرحله برود؟',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontSize: 12),
                  ),
                  DropdownButton<String>(
                    value: conditionFalse,
                    isExpanded: true,
                    hint: const Text('انتخاب مرحله (اختیاری)', textDirection: TextDirection.rtl),
                    items: _checklistItems
                        .map((item) => DropdownMenuItem(
                              value: item.id,
                              child: Text(item.title, textDirection: TextDirection.rtl),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() => conditionFalse = value);
                    },
                  ),
                ],
              ],
            ),
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
      ),
    );

    if (result == true && titleController.text.isNotEmpty) {
      final newItem = TaskChecklistModel(
        id: _uuid.v4(),
        taskId: widget.task.taskId,
        title: titleController.text,
        description: descController.text,
        order: _checklistItems.length,
        type: type,
        conditionTrue: conditionTrue,
        conditionFalse: conditionFalse,
        createdAt: DateTime.now(),
      );

      final success = await _backendService.createTaskChecklistItem(newItem);
      if (success) {
        await _loadChecklist();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('آیتم با موفقیت اضافه شد')),
          );
        }
      }
    }
  }

  Future<void> _deleteItem(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف آیتم', textDirection: TextDirection.rtl),
        content: const Text(
          'آیا مطمئن هستید که می‌خواهید این آیتم را حذف کنید؟',
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
      final success = await _backendService.deleteTaskChecklistItem(id);
      if (success) {
        await _loadChecklist();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('آیتم حذف شد')),
          );
        }
      }
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'start':
        return Colors.green;
      case 'step':
        return Colors.blue;
      case 'condition':
        return Colors.orange;
      case 'end':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'start':
        return Icons.play_circle_outline;
      case 'step':
        return Icons.radio_button_checked;
      case 'condition':
        return Icons.help_outline;
      case 'end':
        return Icons.flag;
      default:
        return Icons.circle;
    }
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'start':
        return 'شروع';
      case 'step':
        return 'مرحله';
      case 'condition':
        return 'شرط';
      case 'end':
        return 'پایان';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'چک‌لیست: ${widget.task.title}',
          style: const TextStyle(fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Instructions Card
                Card(
                  margin: const EdgeInsets.all(16),
                  color: const Color(0xFFD4AF37).withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: const Color(0xFFD4AF37)),
                            const SizedBox(width: 8),
                            const Text(
                              'راهنما',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '• شروع: نقطه آغاز کار\n'
                          '• مرحله: یک گام در فرآیند\n'
                          '• شرط: تصمیم‌گیری (اگر/آنگاه)\n'
                          '• پایان: اتمام کار',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),

                // Checklist Items
                Expanded(
                  child: _checklistItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.checklist_rtl,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'هنوز چک‌لیستی ایجاد نشده',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'از دکمه‌های پایین صفحه استفاده کنید',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ReorderableListView(
                          padding: const EdgeInsets.all(16),
                          onReorder: (oldIndex, newIndex) {
                            // TODO: Implement reordering
                          },
                          children: _checklistItems.map((item) {
                            return Card(
                              key: ValueKey(item.id),
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getTypeColor(item.type),
                                  child: Icon(
                                    _getTypeIcon(item.type),
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  item.title,
                                  textDirection: TextDirection.rtl,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (item.description.isNotEmpty)
                                      Text(
                                        item.description,
                                        textDirection: TextDirection.rtl,
                                      ),
                                    Text(
                                      'نوع: ${_getTypeName(item.type)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _getTypeColor(item.type),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteItem(item.id),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),

                // Action Buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _addChecklistItem('start'),
                              icon: const Icon(Icons.play_circle_outline),
                              label: const Text('شروع'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _addChecklistItem('step'),
                              icon: const Icon(Icons.radio_button_checked),
                              label: const Text('مرحله'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _addChecklistItem('condition'),
                              icon: const Icon(Icons.help_outline),
                              label: const Text('شرط'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _addChecklistItem('end'),
                              icon: const Icon(Icons.flag),
                              label: const Text('پایان'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
