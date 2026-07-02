import 'package:flutter/material.dart';
import 'dart:async';

class CountdownTimer extends StatefulWidget {
  final DateTime deadline;

  const CountdownTimer({Key? key, required this.deadline}) : super(key: key);

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      _timeRemaining = widget.deadline.difference(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = _timeRemaining.isNegative;
    final absTime = _timeRemaining.abs();
    
    final days = absTime.inDays;
    final hours = absTime.inHours % 24;
    final minutes = absTime.inMinutes % 60;
    final seconds = absTime.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOverdue ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isOverdue)
            Text(
              'منقضی شده',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            )
          else ...[
            _buildTimeUnit('$seconds', 'ثانیه'),
            const Text(' : ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            _buildTimeUnit('$minutes', 'دقیقه'),
            const Text(' : ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            _buildTimeUnit('$hours', 'ساعت'),
            const Text(' : ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            _buildTimeUnit('$days', 'روز'),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Text(
          value.padLeft(2, '0'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
