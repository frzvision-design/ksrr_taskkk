import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/checklist_category_model.dart';
import '../../models/checklist_item_model.dart';
import '../../services/personal_checklist_service.dart';
import 'checklist_todos_screen.dart';

class ChecklistItemsScreen extends StatefulWidget {
  final ChecklistCategoryModel category;
  final String userId;

  const ChecklistItemsScreen({
    Key? key,
    required this.category,
    required this.userId,
  }) : super(key: key);

  @override
  State<ChecklistItemsScreen> createState() => _ChecklistItemsScreenState();
}

class _ChecklistItemsScreenState extends State<ChecklistItemsScreen> {
  final _service = PersonalChecklistService();
  final _uuid = const Uuid();
  List<ChecklistItemModel> _items = [];
  bool _isLoading = false;
  Map<String, Map<String, int>> _itemStats = {};

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    _items = await _service.getItemsByCategory(widget.category.id);
    
    // Load statistics for each item
    for (var item in _items) {
      final stats = await _service.getItemStatistics(item.id);
      _itemStats[item.id] = stats;
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _showAddItemDialog() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('آیتم جدید', textDirection: TextDirection.rtl),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'عنوان آیتم',
                hintText: 'مثال: پرداخت شهریه، تکمیل فرم',
                border: OutlineInputBorder(),
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'توضیحات (اختیاری)',
                border: OutlineInputBorder(),
              ),
              textDirection: TextDirection.rtl,
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لغو'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ایجاد'),
          ),
        ],
      ),
    );

    if (result == true && titleController.text.isNotEmpty) {
      final newItem = ChecklistItemModel(
        id: _uuid.v4(),
        categoryId: widget.category.id,
        title: titleController.text,
        description: descController.text.isEmpty ? null : descController.text,
        order: _items.length,
        createdAt: DateTime.now(),
      );

      final success = await _service.createItem(newItem);
      if (success) {
        await _loadItems();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('آیتم ایجاد شد')),
          );
        }
      }
    }
  }

  Future<void> _deleteItem(ChecklistItemModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف آیتم', textDirection: TextDirection.rtl),
        content: Text(
          'آیا مطمئن هستید که می‌خواهید "${item.title}" و تمام چک باکس‌های آن را حذف کنید؟',
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
      final success = await _service.deleteItem(item.id);
      if (success) {
        await _loadItems();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('آیتم حذف شد')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.category.icon ?? ''} ${widget.category.title}',
          style: const TextStyle(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? _buildEmptyState()
              : _buildItemsList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemDialog,
        icon: const Icon(Icons.add),
        label: const Text('آیتم جدید'),
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
            Icons.list_alt,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'هنوز آیتمی ایجاد نشده',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'آیتم‌هایی مثل "پرداخت شهریه" یا "تکمیل فرم" بسازید',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final stats = _itemStats[item.id];
        return _buildItemCard(item, stats);
      },
    );
  }

  Widget _buildItemCard(ChecklistItemModel item, Map<String, int>? stats) {
    final total = stats?['total'] ?? 0;
    final completed = stats?['completed'] ?? 0;
    final progress = total > 0 ? completed / total : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChecklistTodosScreen(
                item: item,
                categoryTitle: widget.category.title,
              ),
            ),
          );
          _loadItems(); // Refresh when returning
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteItem(item),
                  ),
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              if (item.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  item.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
              const SizedBox(height: 12),
              if (total > 0) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress == 1.0 ? Colors.green : const Color(0xFFD4AF37),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      progress == 1.0 ? Icons.check_circle : Icons.pending,
                      size: 16,
                      color: progress == 1.0 ? Colors.green : Colors.grey.shade600,
                    ),
                    Text(
                      '$completed از $total انجام شده',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ] else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'هنوز چک باکسی اضافه نشده',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
