import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:timer_label_widget/timer_label_widget.dart';

void main() {
  group('TimerLabelController', () {
    test('initializes with correct time', () {
      final controller = TimerLabelController(duration: const Duration(seconds: 10));
      expect(controller.secondsRemaining, equals(10));
      expect(controller.timeRemaining, equals('00:10'));
    });

    test('counts down correctly and calls onTimerEnd', () {
      fakeAsync((async) {
        bool timerEndedCalled = false;
        final controller = TimerLabelController(
          duration: const Duration(seconds: 5),
          onTimerEnd: () {
            timerEndedCalled = true;
          },
        );

        controller.startTimer();
        // Immediately after starting, it should be 5 seconds.
        expect(controller.secondsRemaining, equals(5));

        // Advance 2 seconds.
        async.elapse(const Duration(seconds: 2));
        expect(controller.secondsRemaining, equals(3));

        // Advance the remaining 3 seconds.
        async.elapse(const Duration(seconds: 3));
        // Now we expect the timer to have reached 0 and onTimerEnd to be called.
        expect(controller.secondsRemaining, equals(0));
        expect(controller.timeRemaining, equals('00:00'));
        expect(timerEndedCalled, isTrue);
      });
    });

    test('resetTimer resets to initial value', () {
      fakeAsync((async) {
        final controller = TimerLabelController(duration: const Duration(seconds: 10));
        controller.startTimer();
        async.elapse(const Duration(seconds: 4));
        expect(controller.secondsRemaining, equals(6));

        controller.resetTimer();
        expect(controller.secondsRemaining, equals(10));
      });
    });

    test('pauseTimer stops countdown and resumeTimer continues it', () {
      fakeAsync((async) {
        final controller = TimerLabelController(duration: const Duration(seconds: 10));
        controller.startTimer();
        async.elapse(const Duration(seconds: 3));
        expect(controller.secondsRemaining, equals(7));

        controller.pauseTimer();
        final pausedTime = controller.secondsRemaining;

        // Advance time while paused (should have no effect).
        async.elapse(const Duration(seconds: 5));
        expect(controller.secondsRemaining, equals(pausedTime));

        // Resume timer and let it count down 2 more seconds.
        controller.resumeTimer();
        async.elapse(const Duration(seconds: 2));
        expect(controller.secondsRemaining, equals(pausedTime - 2));
      });
    });

    test('updateSeconds subtracts elapsed time correctly', () {
      final controller = TimerLabelController(duration: const Duration(seconds: 10));
      controller.updateSeconds(3);
      expect(controller.secondsRemaining, equals(7));

      // Updating with an elapsed time greater than the remaining seconds should clamp to 0.
      controller.updateSeconds(10);
      expect(controller.secondsRemaining, equals(0));
    });
  });

  group('TimerLabelWidget', () {
    testWidgets('displays initial time correctly', (WidgetTester tester) async {
      final controller = TimerLabelController(duration: const Duration(seconds: 10));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimerLabelWidget(
              controller: controller,
              textStyle: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      );

      // The widget should initially display "00:10".
      expect(find.text('00:10'), findsOneWidget);
    });

    testWidgets('updates time display as countdown progresses', (WidgetTester tester) async {
      final controller = TimerLabelController(duration: const Duration(seconds: 5));
      controller.startTimer();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimerLabelWidget(
              controller: controller,
              textStyle: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      );

      // Initially, it should show "00:05".
      expect(find.text('00:05'), findsOneWidget);

      // Simulate 2 seconds passing.
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('00:03'), findsOneWidget);

      // Simulate the rest of the countdown.
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('00:00'), findsOneWidget);
    });

    testWidgets('supports hours when alwaysShowHours is true', (WidgetTester tester) async {
      final controller = TimerLabelController(
        duration: const Duration(minutes: 90), // 1 hour 30 minutes.
        alwaysShowHours: true,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimerLabelWidget(
              controller: controller,
              textStyle: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      );

      // Expect the timer to display hours, e.g., "01:30:00".
      expect(find.text('01:30:00'), findsOneWidget);
    });
  });
}
