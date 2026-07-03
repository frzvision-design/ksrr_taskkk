import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();

  List<UserModel> _employees = [];
  UserModel? _selectedEmployee;
  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 1));
  bool _isLoading = false;
  bool _isRecording = false;
  bool _recorderInitialized = false;
  String? _recordedAudioPath;
  String? _recordedAudioBase64;
  File? _attachedFile;
  String? _attachedFileName;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await _audioRecorder.openRecorder();
    setState(() {
      _recorderInitialized = true;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _audioRecorder.closeRecorder();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);
    try {
      final users = await _backendService.getUsers();
      setState(() {
        _employees = users.where((u) => u.role == 'employee').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در بارگذاری کارمندان: $e')),
        );
      }
    }
  }

  Future<void> _startRecording() async {
    try {
      if (!_recorderInitialized) {
        await _initRecorder();
      }

      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('دسترسی به میکروفون رد شد')),
          );
        }
        return;
      }

      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _audioRecorder.startRecorder(
        toFile: path,
        codec: Codec.aacADTS,
      );

      setState(() {
        _isRecording = true;
        _recordedAudioPath = path;
      });
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
      await _audioRecorder.stopRecorder();

      if (_recordedAudioPath != null) {
        final file = File(_recordedAudioPath!);
        final bytes = await file.readAsBytes();
        _recordedAudioBase64 = base64Encode(bytes);
      }

      setState(() => _isRecording = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('صدا با موفقیت ضبط شد')),
        );
      }
    } catch (e) {
      setState(() => _isRecording = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در توقف ضبط: $e')),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);

        setState(() {
          _attachedFile = file;
          _attachedFileName = result.files.single.name;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فایل انتخاب شد: ${result.files.single.name}')),
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

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate() || _selectedEmployee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً تمام فیلدها را تکمیل کنید')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
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

      await _backendService.addTask(task);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('وظیفه با موفقیت ایجاد شد')),
        );

        // Clear form
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در ایجاد وظیفه: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading && _employees.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'ایجاد وظیفه جدید',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Title Field
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'عنوان وظیفه',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (val) =>
                          val?.isEmpty ?? true ? 'عنوان را وارد کنید' : null,
                    ),
                    const SizedBox(height: 16),

                    // Description Field
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'توضیحات',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 4,
                      validator: (val) =>
                          val?.isEmpty ?? true ? 'توضیحات را وارد کنید' : null,
                    ),
                    const SizedBox(height: 16),

                    // Employee Dropdown
                    DropdownButtonFormField<UserModel>(
                      value: _selectedEmployee,
                      decoration: const InputDecoration(
                        labelText: 'انتخاب کارمند',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: _employees.map((emp) {
                        return DropdownMenuItem(
                          value: emp,
                          child: Text(emp.name),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedEmployee = val),
                      validator: (val) =>
                          val == null ? 'کارمند را انتخاب کنید' : null,
                    ),
                    const SizedBox(height: 16),

                    // Deadline Picker
                    ListTile(
                      title: const Text('مهلت انجام'),
                      subtitle: Text(
                        '${_selectedDeadline.year}/${_selectedDeadline.month}/${_selectedDeadline.day}',
                      ),
                      leading: const Icon(Icons.calendar_today),
                      tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDeadline,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() => _selectedDeadline = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // Voice Recording Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.mic, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                'توضیحات صوتی (اختیاری)',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isRecording ? _stopRecording : _startRecording,
                                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                                  label: Text(_isRecording ? 'توقف ضبط' : 'شروع ضبط'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isRecording
                                        ? Colors.red
                                        : Theme.of(context).colorScheme.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              if (_recordedAudioBase64 != null) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _recordedAudioPath = null;
                                      _recordedAudioBase64 = null;
                                    });
                                  },
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'حذف صدا',
                                ),
                              ],
                            ],
                          ),
                          if (_recordedAudioBase64 != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Colors.green, size: 20),
                                  const SizedBox(width: 8),
                                  const Text('صدا ضبط شد'),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // File Attachment Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.attach_file,
                                  color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                'پیوست فایل (اختیاری)',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _pickFile,
                                  icon: const Icon(Icons.upload_file),
                                  label: const Text('انتخاب فایل'),
                                ),
                              ),
                              if (_attachedFile != null) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _attachedFile = null;
                                      _attachedFileName = null;
                                    });
                                  },
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'حذف فایل',
                                ),
                              ],
                            ],
                          ),
                          if (_attachedFile != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Colors.green, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _attachedFileName ?? '',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Create Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _createTask,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'ایجاد وظیفه',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
