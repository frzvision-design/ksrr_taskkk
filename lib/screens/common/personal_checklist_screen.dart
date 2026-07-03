import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/checklist_category_model.dart';
import '../../services/personal_checklist_service.dart';
import 'checklist_items_screen.dart';

class PersonalChecklistScreen extends StatefulWidget {
  final String userId;

  const PersonalChecklistScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<PersonalChecklistScreen> createState() => _PersonalChecklistScreenState();
}

class _PersonalChecklistScreenState extends State<PersonalChecklistScreen> {
  final _service = PersonalChecklistService();
  final _uuid = const Uuid();
  List<ChecklistCategoryModel> _categories = [];
  bool _isLoading = false;
  Map<String, Map<String, int>> _categoryStats = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    _categories = await _service.getAllCategories(widget.userId);
    
    // Load statistics for each category
    for (var category in _categories) {
      final stats = await _service.getCategoryStatistics(category.id);
      _categoryStats[category.id] = stats;
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _showAddCategoryDialog() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String? selectedIcon = '📋';

    final icons = ['📋', '🎓', '🏢', '✈️', '🏥', '🏦', '🏛️', '📚', '💼', '🏠', '🚗', '🍽️'];

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('دسته‌بندی جدید', textDirection: TextDirection.rtl),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان (مثال: دانشگاه، سفارت)',
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
                const SizedBox(height: 16),
                const Text(
                  'انتخاب آیکون:',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: icons.map((icon) {
                    return InkWell(
                      onTap: () {
                        setDialogState(() => selectedIcon = icon);
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedIcon == icon
                                ? const Color(0xFFD4AF37)
                                : Colors.grey.shade300,
                            width: selectedIcon == icon ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
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
              child: const Text('ایجاد'),
            ),
          ],
        ),
      ),
    );

    if (result == true && titleController.text.isNotEmpty) {
      final newCategory = ChecklistCategoryModel(
        id: _uuid.v4(),
        userId: widget.userId,
        title: titleController.text,
        description: descController.text.isEmpty ? null : descController.text,
        icon: selectedIcon,
        createdAt: DateTime.now(),
      );

      final success = await _service.createCategory(newCategory);
      if (success) {
        await _loadCategories();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('دسته‌بندی ایجاد شد')),
          );
        }
      }
    }
  }

  Future<void> _deleteCategory(ChecklistCategoryModel category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف دسته‌بندی', textDirection: TextDirection.rtl),
        content: Text(
          'آیا مطمئن هستید که می‌خواهید "${category.title}" و تمام موارد آن را حذف کنید؟',
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
      final success = await _service.deleteCategory(category.id);
      if (success) {
        await _loadCategories();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('دسته‌بندی حذف شد')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('چک‌لیست‌های من'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCategories,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? _buildEmptyState()
              : _buildCategoriesList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCategoryDialog,
        icon: const Icon(Icons.add),
        label: const Text('دسته‌بندی جدید'),
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
            Icons.checklist_rtl,
            size: 100,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            'هنوز چک‌لیستی ایجاد نکرده‌اید',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'برای شروع، یک دسته‌بندی مثل "دانشگاه" یا "سفارت" بسازید',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showAddCategoryDialog,
            icon: const Icon(Icons.add),
            label: const Text('ایجاد اولین دسته‌بندی'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final stats = _categoryStats[category.id];
        return _buildCategoryCard(category, stats);
      },
    );
  }

  Widget _buildCategoryCard(ChecklistCategoryModel category, Map<String, int>? stats) {
    final totalTodos = stats?['totalTodos'] ?? 0;
    final completedTodos = stats?['completedTodos'] ?? 0;
    final progress = totalTodos > 0 ? completedTodos / totalTodos : 0.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChecklistItemsScreen(
                category: category,
                userId: widget.userId,
              ),
            ),
          );
          _loadCategories(); // Refresh when returning
        },
        onLongPress: () => _deleteCategory(category),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category.icon ?? '📋',
                    style: const TextStyle(fontSize: 32),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${stats?['totalItems'] ?? 0}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                category.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.rtl,
              ),
              if (category.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  category.description!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                ),
              ],
              const Spacer(),
              if (totalTodos > 0) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress == 1.0 ? Colors.green : const Color(0xFFD4AF37),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedTodos از $totalTodos انجام شده',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ] else
                Text(
                  'خالی',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
