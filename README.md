# Timer Label Widget

A simple countdown timer widget for Flutter.

## Installation

Add to `pubspec.yaml`:

```yaml
dependencies:
  timer_label_widget: ^1.0.0
```

Run:

```bash
flutter pub get
```

## Usage

```dart
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
      home: TimerExamplePage(),
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
      onTimerEnd: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Timer Completed!')),
      ),
    );
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timer Example')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TimerLabelWidget(
            controller: _timerController,
            textStyle: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: _timerController.startTimer, child: const Text('Start')),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: _timerController.pauseTimer, child: const Text('Pause')),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: _timerController.resumeTimer, child: const Text('Resume')),
            ],
          ),
        ],
      ),
    );
  }
}
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
