import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/backend_service.dart';
import 'package:uuid/uuid.dart';

class EmployeeManagementTab extends StatefulWidget {
  const EmployeeManagementTab({Key? key}) : super(key: key);

  @override
  State<EmployeeManagementTab> createState() => _EmployeeManagementTabState();
}

class _EmployeeManagementTabState extends State<EmployeeManagementTab> {
  final _backendService = BackendService();
  final _uuid = const Uuid();
  List<UserModel> _employees = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);
    _employees = await _backendService.getEmployees();
    setState(() => _isLoading = false);
  }

  Future<void> _showCreateEmployeeDialog() async {
    final nameController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ایجاد کارمند جدید'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'نام و نام خانوادگی',
                    prefixIcon: Icon(Icons.person),
                  ),
                  textDirection: TextDirection.rtl,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'نام را وارد کنید' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'نام کاربری',
                    prefixIcon: Icon(Icons.account_circle),
                  ),
                  textDirection: TextDirection.rtl,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'نام کاربری را وارد کنید' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'رمز عبور',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  textDirection: TextDirection.rtl,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'رمز عبور را وارد کنید' : null,
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
                final user = UserModel(
                  uid: _uuid.v4(),
                  name: nameController.text.trim(),
                  username: usernameController.text.trim(),
                  password: passwordController.text.trim(),
                  role: 'employee',
                  pushToken: '',
                );

                final success = await _backendService.createUser(user);
                if (!context.mounted) return;

                Navigator.pop(context);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('کارمند با موفقیت ایجاد شد')),
                  );
                  _loadEmployees();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('خطا در ایجاد کارمند')),
                  );
                }
              }
            },
            child: const Text('ایجاد'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _employees.isEmpty
              ? const Center(
                  child: Text(
                    'هیچ کارمندی یافت نشد',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _employees.length,
                  itemBuilder: (context, index) {
                    final employee = _employees[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(employee.name[0]),
                        ),
                        title: Text(
                          employee.name,
                          textDirection: TextDirection.rtl,
                        ),
                        subtitle: Text(
                          'نام کاربری: ${employee.username}',
                          textDirection: TextDirection.rtl,
                        ),
                        trailing: const Icon(Icons.arrow_back_ios),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateEmployeeDialog,
        icon: const Icon(Icons.add),
        label: const Text('کارمند جدید'),
      ),
    );
  }
}
