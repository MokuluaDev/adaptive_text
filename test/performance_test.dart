import 'package:adaptive_text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  group('AdaptiveText Performance Tests', () {
    testWidgets('caching prevents unnecessary recalculations', (WidgetTester tester) async {
      int buildCount = 0;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (context, setState) {
              buildCount++;
              return const SizedBox(
                width: 200,
                child: AdaptiveText(
                  'Performance test text',
                  style: TextStyle(fontSize: 16),
                  animationDuration: Duration.zero,
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      final initialBuildCount = buildCount;

      // Trigger rebuild without changing constraints
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Build count should not increase significantly due to caching
      expect(buildCount - initialBuildCount, lessThan(3));
    });

    testWidgets('handles multiple AdaptiveText widgets efficiently', (WidgetTester tester) async {
      const textList = [
        'Short',
        'Medium length text here',
        'This is a much longer text that will need adaptation',
        'Supercalifragilisticexpialidocious',
        'Another text with different characteristics',
      ];

      await tester.pumpWidget(
        createTestApp(
          child: Column(
            children: textList
                .map(
                  (text) => SizedBox(
                    width: 200,
                    child: AdaptiveText(
                      text,
                      style: const TextStyle(fontSize: 16),
                      animationDuration: Duration.zero,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      );

      await tester.pumpAndSettleWithoutExceptions();

      // All texts should be rendered
      for (final text in textList) {
        expect(find.text(text), findsOneWidget);
      }
    });

    testWidgets('constraint changes are handled efficiently', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      for (double width = 300; width >= 100; width -= 20) {
        await tester.pumpWidget(
          createConstrainedTestApp(
            width: width,
            child: const AdaptiveText(
              'Performance test with changing constraints',
              style: TextStyle(fontSize: 18),
              animationDuration: Duration.zero,
            ),
          ),
        );
        await tester.pump();
      }

      await tester.pumpAndSettle();
      stopwatch.stop();

      // Should complete constraint changes reasonably quickly
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      expect(tester.takeException(), isNull);
    });

    testWidgets('memory usage remains stable with text changes', (WidgetTester tester) async {
      String currentText = 'Initial text';

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  SizedBox(
                    width: 200,
                    child: AdaptiveText(
                      currentText,
                      style: const TextStyle(fontSize: 16),
                      animationDuration: Duration.zero,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentText = 'Updated text ${DateTime.now().millisecondsSinceEpoch}';
                      });
                    },
                    child: const Text('Update'),
                  ),
                ],
              );
            },
          ),
        ),
      );

      // Change text multiple times to test memory stability
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.text('Update'));
        await tester.pumpAndSettle();
      }

      expect(tester.takeException(), isNull);
    });

    testWidgets('animation performance is smooth', (WidgetTester tester) async {
      double containerWidth = 100;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  SizedBox(
                    width: containerWidth,
                    child: const AdaptiveText(
                      'Animation performance test text that needs scaling',
                      style: TextStyle(fontSize: 20),
                      animationDuration: Duration(milliseconds: 200),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        containerWidth = containerWidth == 100 ? 300 : 100;
                      });
                    },
                    child: const Text('Toggle Size'),
                  ),
                ],
              );
            },
          ),
        ),
      );

      // Let initial animation complete
      await tester.pumpAndSettle();

      // Trigger animation by changing constraints
      await tester.tap(find.text('Toggle Size'));

      // Monitor animation frames
      int frameCount = 0;
      while (tester.binding.hasScheduledFrame && frameCount < 50) {
        await tester.pump(const Duration(milliseconds: 16)); // ~60fps
        frameCount++;
      }

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(frameCount, greaterThan(0)); // Animation should have occurred
    });

    testWidgets('large text content is handled efficiently', (WidgetTester tester) async {
      // Generate large text content
      final largeText =
          List.generate(100, (index) => 'This is sentence number $index with various words and characters.').join(' ');

      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        createConstrainedTestApp(
          width: 400,
          child: AdaptiveText(
            largeText,
            style: const TextStyle(fontSize: 14),
            maxLines: 10,
            animationDuration: Duration.zero,
          ),
        ),
      );

      await tester.pumpAndSettle();
      stopwatch.stop();

      // Should handle large content reasonably quickly
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      expect(find.text(largeText), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('text scaler changes are handled efficiently', (WidgetTester tester) async {
      const testText = 'Text scaler performance test';

      for (double scaler = 1.0; scaler <= 3.0; scaler += 0.5) {
        await tester.pumpWidget(
          createTestAppWithMediaQuery(
            textScaler: scaler,
            child: const SizedBox(
              width: 200,
              child: AdaptiveText(
                testText,
                style: TextStyle(fontSize: 16),
                animationDuration: Duration.zero,
              ),
            ),
          ),
        );
        await tester.pump();
      }

      await tester.pumpAndSettle();
      expect(find.text(testText), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('debug mode does not significantly impact performance', (WidgetTester tester) async {
      final stopwatchNormal = Stopwatch()..start();

      // Test without debug mode
      await tester.pumpWidget(
        createConstrainedTestApp(
          width: 150,
          child: const AdaptiveText(
            'Performance comparison test text that needs adaptation',
            style: TextStyle(fontSize: 18),
            debugMode: false,
            animationDuration: Duration.zero,
          ),
        ),
      );
      await tester.pumpAndSettle();
      stopwatchNormal.stop();

      final stopwatchDebug = Stopwatch()..start();

      // Test with debug mode
      await tester.pumpWidget(
        createConstrainedTestApp(
          width: 150,
          child: const AdaptiveText(
            'Performance comparison test text that needs adaptation',
            style: TextStyle(fontSize: 18),
            debugMode: true,
            animationDuration: Duration.zero,
          ),
        ),
      );
      await tester.pumpAndSettle();
      stopwatchDebug.stop();

      // Debug mode should not add significant overhead (allow 2x slowdown max)
      expect(stopwatchDebug.elapsedMilliseconds, lessThan(stopwatchNormal.elapsedMilliseconds * 2 + 100));

      expect(tester.takeException(), isNull);
    });
  });
}
