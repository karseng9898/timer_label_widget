import 'package:flutter/material.dart';
import 'package:timer_label_widget/timer_label_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Countdown Timer Example',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      debugShowCheckedModeBanner: false,
      home: const TimerExamplePage(),
    );
  }
}

class TimerExamplePage extends StatefulWidget {
  const TimerExamplePage({super.key});

  @override
  State<TimerExamplePage> createState() => _TimerExamplePageState();
}

class _TimerExamplePageState extends State<TimerExamplePage> {
  late TimerLabelController _timerController;

  @override
  void initState() {
    super.initState();
    _timerController = TimerLabelController(
      duration: const Duration(seconds: 60),
      alwaysShowHours: false,
      onTimerEnd: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Time is up!'),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  double get _progress {
    return 1 -
        (_timerController.secondsRemaining /
            _timerController.duration.inSeconds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Countdown Timer'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.indigo],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: AnimatedBuilder(
                        animation: _timerController,
                        builder: (context, child) {
                          return CircularProgressIndicator(
                            value: _progress,
                            strokeWidth: 12,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          );
                        },
                      ),
                    ),
                    TimerLabelWidget(
                      controller: _timerController,
                      textStyle: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                  onPressed: () {
                    _timerController.startTimer();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause'),
                  onPressed: () {
                    _timerController.pauseTimer();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_circle_fill),
                  label: const Text('Resume'),
                  onPressed: () {
                    _timerController.resumeTimer();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.restore),
                  label: const Text('Reset'),
                  onPressed: () {
                    _timerController.resetTimer();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
