import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/user_model.dart';
import '../../models/task_model.dart';
import '../../services/backend_service.dart';
import 'package:uuid/uuid.dart';

class TaskCreationTab extends StatefulWidget {
  const TaskCreationTab({Key? key}) : super(key: key);

  @override
  State<TaskCreationTab> createState() => _TaskCreationTabState();
}

class _TaskCreationTabState extends State<TaskCreationTab> {
  final _formKey = GlobalKey<FormState>();
  final _backendService = BackendService();
  final _uuid = const Uuid();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _audioRecorder = AudioRecorder();

  List<UserModel> _employees = [];
  UserModel? _selectedEmployee;
  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 1));
  bool _isLoading = false;
  bool _isRecording = false;
  String? _recordedAudioPath;
  String? _recordedAudioBase64;
  File? _attachedFile;
  String? _attachedFileName;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    _employees = await _backendService.getEmployees();
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

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() {
          _isRecording = true;
          _recordedAudioPath = path;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('دسترسی به میکروفون رد شد')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در شروع ضبط: $e')),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      if (path != null) {
        final file = File(path);
        final bytes = await file.readAsBytes();
        setState(() {
          _isRecording = false;
          _recordedAudioPath = path;
          _recordedAudioBase64 = base64Encode(bytes);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('صدا ضبط شد')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در توقف ضبط: $e')),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _attachedFile = File(result.files.single.path!);
          _attachedFileName = result.files.single.name;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فایل ${result.files.single.name} انتخاب شد')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در انتخاب فایل: $e')),
        );
      }
    }
  }

  void _removeVoice() {
    setState(() {
      _recordedAudioPath = null;
      _recordedAudioBase64 = null;
    });
  }

  void _removeFile() {
    setState(() {
      _attachedFile = null;
      _attachedFileName = null;
    });
  }

  Future<void> _createTask() async {
    if (_formKey.currentState!.validate() && _selectedEmployee != null) {
      setState(() => _isLoading = true);

      String? attachmentData;
      if (_attachedFile != null) {
        final bytes = await _attachedFile!.readAsBytes();
        attachmentData = base64Encode(bytes);
      }

      final task = TaskModel(
        taskId: _uuid.v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        assignedTo: _selectedEmployee!.uid,
        status: 'pending',
        createdAt: DateTime.now(),
        deadline: _selectedDeadline,
        voiceNote: _recordedAudioBase64,
        attachmentName: _attachedFileName,
        attachmentData: attachmentData,
      );

      final success = await _backendService.createTask(task);

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('وظیفه برای ${_selectedEmployee!.name} ارسال شد'),
          ),
        );
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedEmployee = null;
          _selectedDeadline = DateTime.now().add(const Duration(days: 1));
          _recordedAudioPath = null;
          _recordedAudioBase64 = null;
          _attachedFile = null;
          _attachedFileName = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطا در ایجاد وظیفه')),
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
              'ایجاد وظیفه جدید',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'عنوان وظیفه',
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
            const Divider(),
            const Text(
              'پیوست‌ها (اختیاری)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),
            // Voice Recording
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_recordedAudioPath != null)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: _removeVoice,
                          ),
                        const Expanded(
                          child: Text(
                            'توضیحات صوتی',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const Icon(Icons.mic, color: Colors.blue),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_recordedAudioPath != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text('صدا ضبط شده است'),
                          ],
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: _isRecording ? _stopRecording : _startRecording,
                        icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                        label: Text(_isRecording ? 'توقف ضبط' : 'شروع ضبط صدا'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isRecording ? Colors.red : Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // File Attachment
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_attachedFileName != null)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: _removeFile,
                          ),
                        const Expanded(
                          child: Text(
                            'فایل پیوست',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const Icon(Icons.attach_file, color: Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_attachedFileName != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.insert_drive_file, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _attachedFileName!,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('انتخاب فایل'),
                      ),
                  ],
                ),
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
                      'ایجاد وظیفه',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
