import 'dart:async';
import 'package:flutter/material.dart';
import 'coordination_model.dart';
import 'navigator.dart';

class FlowRestartTimer extends StatefulWidget {
  final int timeUntilRestart;
  final CoordinationModel coordinationModel;

  const FlowRestartTimer(
      {super.key,
      required this.timeUntilRestart,
      required this.coordinationModel});

  @override
  _FlowRestartTimerState createState() => _FlowRestartTimerState();
}

class _FlowRestartTimerState extends State<FlowRestartTimer> {
  BuildContext? _context;
  int _remainingTime = 0;
  Timer? _timer;

  void _onTimerTick(Timer timer) {
    if (_remainingTime > 0) {
      setState(() {
        _remainingTime--;
      });
    } else {
      timer.cancel();
      restartFlow(_context as BuildContext, widget.coordinationModel);
    }
  }

  @override
  void initState() {
    super.initState();

    _remainingTime = widget.timeUntilRestart;
    _timer = Timer.periodic(const Duration(seconds: 1), _onTimerTick);
  }

  @override
  void dispose() {
    // Always cancel the timer if it's no longer needed to prevent memory leaks
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [Text('$_remainingTime', style: const TextStyle(fontSize: 24))],
    );
  }
}
