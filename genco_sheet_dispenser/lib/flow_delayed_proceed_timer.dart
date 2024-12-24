import 'dart:async';
import 'package:flutter/material.dart';
import 'coordination_model.dart';
import 'navigator.dart';

class FlowDelayedProceedTimer extends StatefulWidget {
  final int timeUntilProceed;
  final CoordinationModel coordinationModel;

  const FlowDelayedProceedTimer(
      {super.key,
      required this.timeUntilProceed,
      required this.coordinationModel});

  @override
  _FlowDelayedProceedTimerState createState() =>
      _FlowDelayedProceedTimerState();
}

class _FlowDelayedProceedTimerState extends State<FlowDelayedProceedTimer> {
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
      navigateToNextCoordinatedPage(
          _context as BuildContext, widget.coordinationModel);
    }
  }

  @override
  void initState() {
    super.initState();

    _remainingTime = widget.timeUntilProceed;
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
