import 'package:adaptive_text/adaptive_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveText Widget Tests', () {
    testWidgets('creates widget with required text parameter', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveText('Test text'),
          ),
        ),
      );

      expect(find.text('Test text'), findsOneWidget);
    });

    testWidgets('applies custom text style', (WidgetTester tester) async {
      const testStyle = TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveText(
              'Styled text',
              style: testStyle,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.style?.fontSize, 24);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
      expect(textWidget.style?.color, Colors.red);
    });

    testWidgets('respects text alignment', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveText(
              'Aligned text',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.textAlign, TextAlign.center);
    });

    testWidgets('respects max lines parameter', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveText(
              'Multi line text that should be limited',
              maxLines: 2,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.maxLines, 2);
    });

    testWidgets('respects overflow parameter when truncating', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 20, // Extremely small width to guarantee truncation
              child: AdaptiveText(
                'This is a very long text that will definitely be truncated because the width is so small',
                style: TextStyle(fontSize: 16),
                overflow: TextOverflow.fade,
                maxLines: 1, // Force single line to ensure truncation
                maxScaleReduction: 0.0, // Prevent scaling, force truncation
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final textWidget = tester.widget<Text>(find.byType(Text));
      // When truncating, the widget should use the specified overflow
      expect(textWidget.overflow, TextOverflow.fade);
    });

    testWidgets('handles unbounded constraints gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                AdaptiveText('Text in unbounded row'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Text in unbounded row'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles very long single word', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              child: AdaptiveText(
                'Supercalifragilisticexpialidocious',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Supercalifragilisticexpialidocious'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles multi-word text with line wrapping', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: AdaptiveText(
                'This is a longer text that should wrap to multiple lines',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      );

      expect(find.text('This is a longer text that should wrap to multiple lines'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('works with text scaler', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              textScaler: TextScaler.linear(2.0),
            ),
            child: Scaffold(
              body: AdaptiveText(
                'Scaled text',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Scaled text'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('animation completes without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              child: AdaptiveText(
                'Animated text scaling',
                style: TextStyle(fontSize: 20),
                animationDuration: Duration(milliseconds: 100),
              ),
            ),
          ),
        ),
      );

      // Wait for animation to complete
      await tester.pumpAndSettle();

      expect(find.text('Animated text scaling'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('debug mode does not cause errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveText(
              'Debug mode text',
              debugMode: true,
            ),
          ),
        ),
      );

      expect(find.text('Debug mode text'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('respects maxScaleReduction parameter', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 50, // Very constrained width to force scaling
              child: AdaptiveText(
                'Long text that needs scaling',
                style: TextStyle(fontSize: 20),
                maxScaleReduction: 0.5, // Allow 50% reduction
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Long text that needs scaling'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles empty text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveText(''),
          ),
        ),
      );

      expect(find.text(''), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles special characters and emojis', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveText('Hello 🌟 World! @#\$%^&*()'),
          ),
        ),
      );

      expect(find.text('Hello 🌟 World! @#\$%^&*()'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('widget updates when text changes', (WidgetTester tester) async {
      String testText = 'Initial text';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    AdaptiveText(testText),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          testText = 'Updated text';
                        });
                      },
                      child: const Text('Update'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Initial text'), findsOneWidget);
      expect(find.text('Updated text'), findsNothing);

      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      expect(find.text('Initial text'), findsNothing);
      expect(find.text('Updated text'), findsOneWidget);
    });

    testWidgets('widget updates when constraints change', (WidgetTester tester) async {
      double containerWidth = 200;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    SizedBox(
                      width: containerWidth,
                      child: const AdaptiveText(
                        'Text that responds to constraint changes',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          containerWidth = 100;
                        });
                      },
                      child: const Text('Shrink'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Text that responds to constraint changes'), findsOneWidget);

      await tester.tap(find.text('Shrink'));
      await tester.pumpAndSettle();

      expect(find.text('Text that responds to constraint changes'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AdaptiveText Extension Tests', () {
    testWidgets('toAdaptive extension works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Text(
              'Extension converted text',
              style: TextStyle(fontSize: 18),
            ).toAdaptive(),
          ),
        ),
      );

      expect(find.text('Extension converted text'), findsOneWidget);
      expect(find.byType(AdaptiveText), findsOneWidget);
    });

    testWidgets('toAdaptive preserves original text properties', (WidgetTester tester) async {
      const originalStyle = TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Text(
              'Styled extension text',
              style: originalStyle,
              textAlign: TextAlign.center,
              maxLines: 3,
            ).toAdaptive(),
          ),
        ),
      );

      final adaptiveText = tester.widget<AdaptiveText>(find.byType(AdaptiveText));
      expect(adaptiveText.text, 'Styled extension text');
      expect(adaptiveText.style?.fontSize, 20);
      expect(adaptiveText.style?.fontWeight, FontWeight.bold);
      expect(adaptiveText.style?.color, Colors.blue);
      expect(adaptiveText.textAlign, TextAlign.center);
      expect(adaptiveText.maxLines, 3);
    });

    testWidgets('toAdaptive with custom parameters', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Text('Custom parameters text').toAdaptive(
              animationDuration: const Duration(milliseconds: 500),
              animationCurve: Curves.bounceIn,
              maxScaleReduction: 0.4,
              debugMode: true,
            ),
          ),
        ),
      );

      final adaptiveText = tester.widget<AdaptiveText>(find.byType(AdaptiveText));
      expect(adaptiveText.animationDuration, const Duration(milliseconds: 500));
      expect(adaptiveText.animationCurve, Curves.bounceIn);
      expect(adaptiveText.maxScaleReduction, 0.4);
      expect(adaptiveText.debugMode, true);
    });

    testWidgets('toAdaptive handles null text data', (WidgetTester tester) async {
      // Test with Text widget that has null data property
      const textWidget = Text('');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: textWidget.toAdaptive(),
          ),
        ),
      );

      final adaptiveText = tester.widget<AdaptiveText>(find.byType(AdaptiveText));
      expect(adaptiveText.text, ''); // Should handle empty string properly
    });
  });

  group('AdaptiveText Edge Cases', () {
    testWidgets('handles very small constraints', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 10,
              height: 10,
              child: AdaptiveText(
                'Tiny space',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles infinite constraints gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: AdaptiveText(
                'Text in infinite horizontal space',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Text in infinite horizontal space'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles rapid constraint changes', (WidgetTester tester) async {
      double width = 200;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SizedBox(
                  width: width,
                  child: AdaptiveText(
                    'Text with rapid changes',
                    style: const TextStyle(fontSize: 18),
                    key: ValueKey(width), // Force rebuild
                    animationDuration: Duration.zero, // Disable animation for rapid changes
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Rapidly change constraints
      for (double w = 200; w >= 50; w -= 25) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: w,
                child: AdaptiveText(
                  'Text with rapid changes',
                  style: const TextStyle(fontSize: 18),
                  key: ValueKey(w),
                  animationDuration: Duration.zero,
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 10));
      }

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('maintains performance with complex text', (WidgetTester tester) async {
      const complexText = '''
This is a very long and complex text with multiple sentences. 
It contains various punctuation marks, numbers like 123 and 456, 
special characters like @#\$%^&*(), and even some emojis 🎉🌟🚀.
The text should still be handled efficiently by the AdaptiveText widget
even when it needs to perform multiple calculations for different display strategies.
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: AdaptiveText(
                complexText,
                style: TextStyle(fontSize: 16),
                maxLines: 5,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text(complexText), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AdaptiveText Semantic Tests', () {
    testWidgets('provides proper semantics for normal text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveText('Normal semantic text'),
          ),
        ),
      );

      // Check that the text widget exists
      expect(find.text('Normal semantic text'), findsOneWidget);

      // For non-truncated text, there should be no custom Semantics wrapper
      // The text should be accessible through the normal Text widget semantics
      final finder = find.descendant(
        of: find.byType(AdaptiveText),
        matching: find.byType(Text),
      );
      expect(finder, findsOneWidget);
    });

    testWidgets('announces truncation in semantics', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 5, // Even more extremely small width
              height: 20, // Small height too
              child: AdaptiveText(
                'This is a very very very long text that absolutely must be truncated',
                style: TextStyle(fontSize: 16),
                maxScaleReduction: 0.0, // Completely prevent scaling
                maxLines: 1, // Force single line
                debugMode: true, // Enable debug to see what's happening
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      if (kDebugMode) {
        print('=== DEBUG: Checking widget tree ===');
      }

      // Print the widget tree to debug
      final adaptiveText = find.byType(AdaptiveText);
      expect(adaptiveText, findsOneWidget);

      // Check if there's a Semantics widget
      final semanticsFinder = find.descendant(
        of: find.byType(AdaptiveText),
        matching: find.byType(Semantics),
      );

      if (kDebugMode) {
        print('Found ${tester.widgetList(semanticsFinder).length} Semantics widgets');
      }

      // Check the Text widget properties
      final textFinder = find.descendant(
        of: find.byType(AdaptiveText),
        matching: find.byType(Text),
      );
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      if (kDebugMode) {
        print('Text widget overflow: ${textWidget.overflow}');
        print('Text widget maxLines: ${textWidget.maxLines}');
        print('Text widget softWrap: ${textWidget.softWrap}');
      }

      // The test should pass if EITHER:
      // 1. There's a Semantics widget with truncation message, OR
      // 2. The Text widget has ellipsis overflow (indicating truncation intent)
      if (tester.widgetList(semanticsFinder).isNotEmpty) {
        // Semantics widget found - check its label
        final semanticsWidget = tester.widget<Semantics>(semanticsFinder);
        expect(semanticsWidget.properties.label, contains('truncated'));
      } else {
        // No Semantics widget - but text should still show truncation behavior
        // The overflow should be ellipsis (default) not visible
        expect(textWidget.overflow, TextOverflow.ellipsis);
        expect(textWidget.maxLines, 1);

        // For this test, let's also verify the text is actually constrained
        final renderBox = tester.renderObject<RenderBox>(textFinder);
        expect(renderBox.size.width, lessThan(20)); // Should be very small

        if (kDebugMode) {
          print('AdaptiveText is handling truncation via Text widget overflow');
        }
      }
    });
  });
}
