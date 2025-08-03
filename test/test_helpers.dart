import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper functions for testing AdaptiveText widgets

/// Creates a basic test app wrapper for AdaptiveText widgets
Widget createTestApp({required Widget child}) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

/// Creates a test app with custom MediaQuery settings
Widget createTestAppWithMediaQuery({
  required Widget child,
  double textScaler = 1.0,
  Size size = const Size(800, 600),
}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(
        size: size,
        textScaler: TextScaler.linear(textScaler),
      ),
      child: Scaffold(
        body: child,
      ),
    ),
  );
}

/// Creates a constrained container for testing specific widths
Widget createConstrainedTestApp({
  required Widget child,
  double? width,
  double? height,
}) {
  return createTestApp(
    child: SizedBox(
      width: width,
      height: height,
      child: child,
    ),
  );
}

/// Helper to find AdaptiveText widgets by their text content
Finder findAdaptiveTextByText(String text) {
  return find.descendant(
    of: find.byType(MaterialApp),
    matching: find.text(text),
  );
}

/// Extension to make text widget assertions easier
extension WidgetTesterExtensions on WidgetTester {
  /// Pumps and settles, then checks for exceptions
  Future<void> pumpAndSettleWithoutExceptions() async {
    await pumpAndSettle();
    expect(takeException(), isNull);
  }

  /// Gets the Text widget from an AdaptiveText
  Text getTextFromAdaptiveText() {
    return widget<Text>(find.byType(Text));
  }
}
