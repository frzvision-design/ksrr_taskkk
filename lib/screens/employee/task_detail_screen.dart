import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/task_model.dart';
import '../../services/backend_service.dart';
import '../../widgets/countdown_timer.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailScreen({Key? key, required this.task}) : super(key: key);

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _backendService = BackendService();
  final FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  late String _currentStatus;
  bool _isUpdating = false;
  bool _isPlayingAudio = false;
  bool _playerInitialized = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.task.status;
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    await _audioPlayer.openPlayer();
    setState(() {
      _playerInitialized = true;
    });
  }

  @override
  void dispose() {
    _audioPlayer.closePlayer();
    super.dispose();
  }

  Color _getStatusColor() {
    if (widget.task.isOverdue && _currentStatus != 'completed') return Colors.red;
    if (_currentStatus == 'completed') return Colors.green;
    if (_currentStatus == 'in_progress') return Colors.blue;
    return Colors.orange;
  }

  String _getStatusText() {
    if (widget.task.isOverdue && _currentStatus != 'completed') return 'منقضی شده';
    if (_currentStatus == 'completed') return 'تکمیل شده';
    if (_currentStatus == 'in_progress') return 'در حال انجام';
    return 'در انتظار';
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);

    final success = await _backendService.updateTaskStatus(
      widget.task.taskId,
      newStatus,
    );

    setState(() => _isUpdating = false);

    if (success) {
      setState(() => _currentStatus = newStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('وضعیت وظیفه به‌روزرسانی شد')),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطا در به‌روزرسانی وضعیت')),
      );
    }
  }

  Future<void> _playAudio() async {
    if (widget.task.voiceNote == null) return;
    
    try {
      if (!_playerInitialized) {
        await _initPlayer();
      }

      if (_isPlayingAudio) {
        await _audioPlayer.stopPlayer();
        setState(() => _isPlayingAudio = false);
        return;
      }

      final bytes = base64Decode(widget.task.voiceNote!);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/temp_audio.aac');
      await file.writeAsBytes(bytes);

      await _audioPlayer.startPlayer(
        fromURI: file.path,
        codec: Codec.aacADTS,
        whenFinished: () {
          setState(() => _isPlayingAudio = false);
        },
      );
      
      setState(() => _isPlayingAudio = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در پخش صدا: $e')),
        );
      }
    }
  }

  Future<void> _downloadFile() async {
    if (widget.task.attachmentData == null) return;

    try {
      final bytes = base64Decode(widget.task.attachmentData!);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${widget.task.attachmentName}');
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فایل در ${file.path} ذخیره شد')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در دانلود فایل: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جزئیات وظیفه'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Title
            Text(
              widget.task.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 16),
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getStatusText(),
                style: TextStyle(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Countdown Timer
            if (_currentStatus != 'completed')
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'زمان باقی‌مانده',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CountdownTimer(deadline: widget.task.deadline),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Description
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'توضیحات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.task.description,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Voice Note (if exists)
            if (widget.task.voiceNote != null)
              Card(
                color: Colors.blue.shade50,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(
                      _isPlayingAudio ? Icons.stop : Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
                  title: const Text(
                    'پیام صوتی',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textDirection: TextDirection.rtl,
                  ),
                  subtitle: Text(
                    _isPlayingAudio ? 'در حال پخش...' : 'ضربه بزنید برای پخش',
                    textDirection: TextDirection.rtl,
                  ),
                  trailing: const Icon(Icons.mic),
                  onTap: _playAudio,
                ),
              ),
            if (widget.task.voiceNote != null) const SizedBox(height: 16),
            // Attachment (if exists)
            if (widget.task.attachmentName != null)
              Card(
                color: Colors.orange.shade50,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.attach_file, color: Colors.white),
                  ),
                  title: Text(
                    widget.task.attachmentName!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textDirection: TextDirection.rtl,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: const Text(
                    'ضربه بزنید برای دانلود',
                    textDirection: TextDirection.rtl,
                  ),
                  trailing: const Icon(Icons.download),
                  onTap: _downloadFile,
                ),
              ),
            if (widget.task.attachmentName != null) const SizedBox(height: 16),
            // Dates Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${widget.task.createdAt.year}/${widget.task.createdAt.month}/${widget.task.createdAt.day} - ${widget.task.createdAt.hour}:${widget.task.createdAt.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.event, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'تاریخ ایجاد:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${widget.task.deadline.year}/${widget.task.deadline.month}/${widget.task.deadline.day} - ${widget.task.deadline.hour}:${widget.task.deadline.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 16,
                            color: widget.task.isOverdue ? Colors.red : null,
                            fontWeight: widget.task.isOverdue ? FontWeight.bold : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.alarm,
                          size: 20,
                          color: widget.task.isOverdue ? Colors.red : null,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'مهلت تحویل:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Action Buttons
            if (_currentStatus != 'completed')
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_currentStatus == 'pending')
                    ElevatedButton(
                      onPressed: _isUpdating
                          ? null
                          : () => _updateStatus('in_progress'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isUpdating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'شروع انجام وظیفه',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  if (_currentStatus == 'in_progress') ...[
                    ElevatedButton(
                      onPressed: _isUpdating
                          ? null
                          : () => _updateStatus('completed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isUpdating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'تکمیل وظیفه',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _isUpdating
                          ? null
                          : () => _updateStatus('pending'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'بازگشت به حالت در انتظار',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
