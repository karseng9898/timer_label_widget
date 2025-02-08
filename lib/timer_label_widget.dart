// timer_label_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';

/// A controller for managing a countdown timer.
///
/// The [TimerLabelController] handles the logic of counting down from a
/// given [duration] and notifies its listeners every second. It supports pausing,
/// resuming, resetting, and restarting the timer. An optional [onTimerEnd] callback
/// is invoked when the timer reaches zero.
///
/// The timer supports displaying hours. By default, it will automatically
/// include hours in the display if the remaining time is 1 hour or more.
/// You can force hours to always appear by setting [alwaysShowHours] to true.
class TimerLabelController extends ChangeNotifier {
  /// Creates a [TimerLabelController] with the specified [duration].
  ///
  /// To start the countdown, call [startTimer]. Optionally, provide an [onTimerEnd]
  /// callback and set [alwaysShowHours] to true to always show the hours in the formatted time.
  TimerLabelController({
    required this.duration,
    this.onTimerEnd,
    this.alwaysShowHours = false,
  }) {
    _secondsRemaining = duration.inSeconds;
  }

  /// The initial duration for the countdown.
  final Duration duration;

  /// An optional callback invoked when the timer completes.
  final VoidCallback? onTimerEnd;

  /// Whether to always display the hours field (even when less than one hour).
  final bool alwaysShowHours;

  Timer? _timer;
  int _secondsRemaining = 0;

  /// Returns the formatted remaining time as a string.
  ///
  /// The format is `HH:mm:ss` if [alwaysShowHours] is true or if the remaining
  /// time is 1 hour or more; otherwise, it is `mm:ss`.
  String get timeRemaining => _formattedTime(_secondsRemaining);

  /// Returns the remaining time in seconds.
  int get secondsRemaining => _secondsRemaining;

  /// Whether the timer has finished counting down.
  bool get isCompleted => _secondsRemaining <= 0;

  /// Whether the timer is currently running.
  bool get isRunning => _timer?.isActive ?? false;

  /// Starts the countdown timer.
  ///
  /// If a [startTime] is provided, the timer will start from that duration;
  /// otherwise, it starts from the current remaining time.
  void startTimer({Duration? startTime}) {
    _timer?.cancel();

    if (startTime != null) {
      _secondsRemaining = startTime.inSeconds;
    }

    // Notify listeners immediately of the starting state.
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // If no time remains, ensure the timer is cancelled.
      if (_secondsRemaining <= 0) {
        timer.cancel();
        return;
      }

      _secondsRemaining--;

      if (_secondsRemaining <= 0) {
        // Ensure we don't go negative.
        _secondsRemaining = 0;
        timer.cancel();
        notifyListeners();
        if (onTimerEnd != null) {
          onTimerEnd!();
        }
      } else {
        notifyListeners();
      }
    });
  }

  /// Pauses the countdown timer.
  ///
  /// You can later resume the timer by calling [resumeTimer].
  void pauseTimer() {
    _timer?.cancel();
    notifyListeners();
  }

  /// Resumes the countdown timer from its current remaining time.
  void resumeTimer() {
    if (_secondsRemaining > 0) {
      startTimer(startTime: Duration(seconds: _secondsRemaining));
    }
  }

  /// Resets the countdown timer to the initial duration.
  void resetTimer() {
    _timer?.cancel();
    _secondsRemaining = duration.inSeconds;
    notifyListeners();
  }

  /// Restarts the countdown timer from the beginning.
  void restartTimer() {
    resetTimer();
    startTimer();
  }

  /// Updates the remaining seconds by subtracting the elapsed time.
  ///
  /// Useful when the app resumes from the background. The [elapsedSeconds]
  /// is subtracted from the remaining time, and the value is clamped to zero.
  void updateSeconds(int elapsedSeconds) {
    _secondsRemaining = (_secondsRemaining - elapsedSeconds).clamp(0, duration.inSeconds);
    notifyListeners();
    if (_secondsRemaining == 0) {
      _timer?.cancel();
      if (onTimerEnd != null) {
        onTimerEnd!();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Formats [totalSeconds] into a string.
  ///
  /// Returns `HH:mm:ss` if [alwaysShowHours] is true or if the total duration
  /// is at least one hour; otherwise, returns `mm:ss`.
  String _formattedTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    final hourStr = hours.toString().padLeft(2, '0');
    final minuteStr = minutes.toString().padLeft(2, '0');
    final secondStr = seconds.toString().padLeft(2, '0');

    if (alwaysShowHours || hours > 0) {
      return '$hourStr:$minuteStr:$secondStr';
    } else {
      return '$minuteStr:$secondStr';
    }
  }
}

/// A widget that displays a countdown timer label.
///
/// The [TimerLabelWidget] listens to a [TimerLabelController] via an
/// [AnimatedBuilder] and displays the formatted remaining time. It also
/// handles app lifecycle changes to pause and resume the timer appropriately.
class TimerLabelWidget extends StatefulWidget {
  /// Creates a [TimerLabelWidget] that displays the timer managed by [controller].
  const TimerLabelWidget({
    super.key,
    required this.controller,
    this.textStyle,
  });

  /// The controller that manages the timer's state.
  final TimerLabelController controller;

  /// The text style used to display the timer label.
  final TextStyle? textStyle;

  @override
  State<TimerLabelWidget> createState() => _TimerLabelWidgetState();
}

class _TimerLabelWidgetState extends State<TimerLabelWidget> with WidgetsBindingObserver {
  DateTime? _pauseTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _pauseTime = DateTime.now();
        widget.controller.pauseTimer();
        break;
      case AppLifecycleState.resumed:
        if (_pauseTime != null) {
          final elapsed = DateTime.now().difference(_pauseTime!);
          widget.controller.updateSeconds(elapsed.inSeconds);
          if (!widget.controller.isCompleted) {
            widget.controller.resumeTimer();
          }
        }
        break;
      case AppLifecycleState.detached:
        widget.controller.resetTimer();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use AnimatedBuilder to rebuild the widget whenever the controller notifies listeners.
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return Text(
          widget.controller.timeRemaining,
          style: widget.textStyle,
        );
      },
    );
  }
}
