import 'dart:async';
import 'package:flutter/material.dart';
import 'colors.dart';

class CallDuration extends StatefulWidget {
  const CallDuration({super.key, required this.timeWhenCallStart});

  final DateTime timeWhenCallStart;

  @override
  State<CallDuration>  createState() => _CallDurationState();
}

class _CallDurationState extends State<CallDuration> {
  bool isTimerRunning = false;
  int secondsElapsed = 0;
  late Timer _timer;

  void startTimer() {
    DateTime now = DateTime.now();
    int initialSeconds = now.difference(widget.timeWhenCallStart).inSeconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        secondsElapsed = initialSeconds + timer.tick;
      });
    });
  }

  void stopTimer() {
    _timer.cancel();
  }

  void resetTimer() {
    setState(() {
      secondsElapsed = 0;
    });
  }

  String _formatTime(int seconds) {
    Duration duration = Duration(seconds: seconds);
    String formattedTime =
        '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    return formattedTime;
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatTime(secondsElapsed),
            style: const TextStyle(fontSize: 20,color: white),
          ), 
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
