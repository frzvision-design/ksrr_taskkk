import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/task_model.dart';
import '../../services/sheets_service.dart';
import 'package:uuid/uuid.dart';

class TaskCreationTab extends StatefulWidget {
  const TaskCreationTab({Key? key}) : super(key: key);

  @override
  State<TaskCreationTab> createState() => _TaskCreationTabState();
}

class _TaskCreationTabState extends State<TaskCreationTab> {
  final _formKey = GlobalKey<FormState>();
  final _sheetsService = SheetsService();
  final _uuid = const Uuid();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<UserModel> _employees = [];
  UserModel? _selectedEmployee;
  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 1));
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    _employees = await _sheetsService.getEmployees();
    setState(() {});
  }

  Future<void> _selectDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDeadline),
      );

      if (time != null) {
        setState(() {
          _selectedDeadline = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _createTask() async {
    if (_formKey.currentState!.validate() && _selectedEmployee != null) {
      setState(() => _isLoading = true);

      final task = TaskModel(
        taskId: _uuid.v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        assignedTo: _selectedEmployee!.uid,
        status: 'pending',
        createdAt: DateTime.now(),
        deadline: _selectedDeadline,
      );

      final success = await _sheetsService.createTask(task);

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تسک برای ${_selectedEmployee!.name} ارسال شد'),
          ),
        );
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedEmployee = null;
          _selectedDeadline = DateTime.now().add(const Duration(days: 1));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطا در ایجاد تسک')),
        );
      }
    } else if (_selectedEmployee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفا یک کارمند را انتخاب کنید')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'ایجاد تسک جدید',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'عنوان تسک',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              textDirection: TextDirection.rtl,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'عنوان را وارد کنید' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'توضیحات',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              textDirection: TextDirection.rtl,
              maxLines: 5,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'توضیحات را وارد کنید' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<UserModel>(
              value: _selectedEmployee,
              decoration: const InputDecoration(
                labelText: 'انتخاب کارمند',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              items: _employees.map((employee) {
                return DropdownMenuItem(
                  value: employee,
                  child: Text(
                    employee.name,
                    textDirection: TextDirection.rtl,
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedEmployee = value),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('تاریخ و زمان مهلت'),
                subtitle: Text(
                  '${_selectedDeadline.year}/${_selectedDeadline.month}/${_selectedDeadline.day} - ${_selectedDeadline.hour}:${_selectedDeadline.minute.toString().padLeft(2, '0')}',
                  textDirection: TextDirection.rtl,
                ),
                trailing: const Icon(Icons.arrow_back_ios),
                onTap: _selectDeadline,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _createTask,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'ایجاد تسک',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
