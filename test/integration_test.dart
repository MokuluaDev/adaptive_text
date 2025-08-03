import 'package:adaptive_text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

// Helper method for metric cards
Widget buildMetricCard(String title, String value, String subtitle) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade200,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdaptiveText(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        AdaptiveText(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        AdaptiveText(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          maxLines: 2,
        ),
      ],
    ),
  );
}

// Helper method for table rows
Widget buildTableRow(String col1, String col2, String col3, {bool isHeader = false}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: isHeader ? Colors.grey.shade100 : Colors.white,
      border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
    ),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: AdaptiveText(
            col1,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              fontSize: isHeader ? 14 : 13,
            ),
          ),
        ),
        Expanded(
          child: AdaptiveText(
            col2,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              fontSize: isHeader ? 14 : 13,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: AdaptiveText(
            col3,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              fontSize: isHeader ? 14 : 13,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    ),
  );
}

void main() {
  group('AdaptiveText Integration Tests', () {
    testWidgets('complete responsive behavior workflow', (WidgetTester tester) async {
      // Start with a medium-sized container
      double containerWidth = 300;
      const testText = 'This is a comprehensive integration test for AdaptiveText behavior';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    // Top section with the adaptive text
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: SizedBox(
                          width: containerWidth,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const AdaptiveText(
                              testText,
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                              animationDuration: Duration.zero, // Disable animation for testing
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Bottom section with buttons
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => setState(() => containerWidth = 500),
                            child: const Text('Large'),
                          ),
                          ElevatedButton(
                            onPressed: () => setState(() => containerWidth = 300),
                            child: const Text('Medium'),
                          ),
                          ElevatedButton(
                            onPressed: () => setState(() => containerWidth = 150),
                            child: const Text('Small'),
                          ),
                          ElevatedButton(
                            onPressed: () => setState(() => containerWidth = 80),
                            child: const Text('Tiny'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Test initial state
      expect(find.text(testText), findsOneWidget);
      await tester.pumpAndSettle();

      // Test large container - should display at full size
      await tester.tap(find.text('Large'));
      await tester.pumpAndSettle();
      expect(find.text(testText), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Test medium container - might use line wrapping
      await tester.tap(find.text('Medium'));
      await tester.pumpAndSettle();
      expect(find.text(testText), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Test small container - should use scaling
      await tester.tap(find.text('Small'));
      await tester.pumpAndSettle();
      expect(find.text(testText), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Test tiny container - should use truncation
      await tester.tap(find.text('Tiny'));
      await tester.pumpAndSettle();
      expect(find.text(testText), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Return to large - should animate back
      await tester.tap(find.text('Large'));
      await tester.pumpAndSettle();
      expect(find.text(testText), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('text scaler integration with responsive behavior', (WidgetTester tester) async {
      double textScaler = 1.0;
      double containerWidth = 200;
      const testText = 'Accessibility text scaling integration test';

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (context, setState) {
              return MediaQuery(
                data: MediaQueryData(
                  textScaler: TextScaler.linear(textScaler),
                ),
                child: SingleChildScrollView(
                  // Added to prevent overflow
                  child: Column(
                    children: [
                      SizedBox(
                        width: containerWidth,
                        child: const AdaptiveText(
                          testText,
                          style: TextStyle(fontSize: 16),
                          animationDuration: Duration.zero, // Disable animation for testing
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Text Scaler: ${textScaler.toStringAsFixed(1)}x'),
                      Slider(
                        value: textScaler,
                        min: 0.8,
                        max: 2.5,
                        divisions: 17,
                        onChanged: (value) => setState(() => textScaler = value),
                      ),
                      Text('Container Width: ${containerWidth.round()}px'),
                      Slider(
                        value: containerWidth,
                        min: 100,
                        max: 400,
                        divisions: 30,
                        onChanged: (value) => setState(() => containerWidth = value),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Test various combinations of text scaling and container width
      final testCombinations = [
        (1.0, 300.0), // Normal scale, normal width
        (1.5, 300.0), // Larger scale, normal width
        (2.0, 200.0), // Large scale, small width
        (0.8, 150.0), // Small scale, small width
        (2.5, 400.0), // Very large scale, large width
      ];

      for (final (scale, width) in testCombinations) {
        // Update text scaler
        await tester.drag(
          find.byType(Slider).first,
          Offset((scale - 0.8) / (2.5 - 0.8) * 200 - 100, 0),
        );
        await tester.pump();

        // Update container width
        await tester.drag(
          find.byType(Slider).last,
          Offset((width - 100) / (400 - 100) * 200 - 100, 0),
        );
        await tester.pumpAndSettle();

        expect(find.text(testText), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('extension method integration in complex layouts', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: SingleChildScrollView(
            // Added to prevent overflow
            child: Column(
              children: [
                // Card with extension method usage
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Card Title Using Extension',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ).toAdaptive(animationDuration: Duration.zero),
                        const SizedBox(height: 8),
                        const Text(
                          'This is a longer description text that demonstrates the extension method in a real-world card layout scenario.',
                          style: TextStyle(fontSize: 14),
                        ).toAdaptive(maxScaleReduction: 0.3, animationDuration: Duration.zero),
                      ],
                    ),
                  ),
                ),

                // List tile with extension method
                ListTile(
                  leading: const Icon(Icons.text_fields),
                  title: const Text('Adaptive List Item Title').toAdaptive(animationDuration: Duration.zero),
                  subtitle: const Text(
                    'Subtitle that can adapt to available space in list tiles',
                  ).toAdaptive(maxScaleReduction: 0.2, animationDuration: Duration.zero),
                  trailing: const Icon(Icons.arrow_forward),
                ),

                // App bar simulation
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.blue,
                  child: Row(
                    children: [
                      const Icon(Icons.menu, color: Colors.white),
                      const SizedBox(width: 16),
                      Expanded(
                        child: const Text(
                          'Adaptive App Bar Title That Might Be Long',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ).toAdaptive(animationDuration: Duration.zero),
                      ),
                      const Icon(Icons.search, color: Colors.white),
                    ],
                  ),
                ),

                // Button with adaptive text
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Adaptive Button Text').toAdaptive(animationDuration: Duration.zero),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check that all extension-converted texts are present
      expect(find.text('Card Title Using Extension'), findsOneWidget);
      expect(
          find.text(
              'This is a longer description text that demonstrates the extension method in a real-world card layout scenario.'),
          findsOneWidget);
      expect(find.text('Adaptive List Item Title'), findsOneWidget);
      expect(find.text('Subtitle that can adapt to available space in list tiles'), findsOneWidget);
      expect(find.text('Adaptive App Bar Title That Might Be Long'), findsOneWidget);
      expect(find.text('Adaptive Button Text'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('real-world dashboard layout integration', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dashboard header
                  const Row(
                    children: [
                      Expanded(
                        child: AdaptiveText(
                          'Dashboard Overview Analytics',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          animationDuration: Duration.zero,
                        ),
                      ),
                      Icon(Icons.settings),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Metrics cards
                  Row(
                    children: [
                      Expanded(
                        child: buildMetricCard(
                          'Total Revenue',
                          '\$1,234,567.89',
                          'Up 12.5% from last month',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: buildMetricCard(
                          'Active Users',
                          '98,765',
                          'Down 2.1% from last week',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Data table simulation
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        buildTableRow(
                          'Product Name',
                          'Sales',
                          'Status',
                          isHeader: true,
                        ),
                        buildTableRow(
                          'Premium Subscription Service',
                          '\$45,678',
                          'Active',
                        ),
                        buildTableRow(
                          'Basic Plan Monthly',
                          '\$12,345',
                          'Active',
                        ),
                        buildTableRow(
                          'Enterprise Solution Package',
                          '\$89,012',
                          'Under Review',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Verify all elements are rendered
      expect(find.text('Dashboard Overview Analytics'), findsOneWidget);
      expect(find.text('Total Revenue'), findsOneWidget);
      expect(find.text('Active Users'), findsOneWidget);
      expect(find.text('Premium Subscription Service'), findsOneWidget);
    });

    testWidgets('navigation and state persistence integration', (WidgetTester tester) async {
      int currentPage = 0;
      final pageTexts = [
        'Welcome to the Home Page with adaptive text',
        'Profile Settings and Configuration Options',
        'Detailed Analytics Dashboard Information',
        'Help and Support Documentation Center',
      ];

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  // Tab navigation
                  Row(
                    children: List.generate(4, (index) {
                      final titles = ['Home', 'Profile', 'Analytics', 'Help'];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => currentPage = index),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: currentPage == index ? Colors.blue : Colors.grey.shade200,
                              border: Border.all(color: Colors.grey),
                            ),
                            child: AdaptiveText(
                              titles[index],
                              style: TextStyle(
                                color: currentPage == index ? Colors.white : Colors.black,
                                fontWeight: currentPage == index ? FontWeight.bold : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                              animationDuration: Duration.zero,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 20),

                  // Page content
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      child: AdaptiveText(
                        pageTexts[currentPage],
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                        animationDuration: Duration.zero,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );

      // Test navigation between pages
      for (int i = 0; i < 4; i++) {
        if (i > 0) {
          await tester.tap(find.text(['Home', 'Profile', 'Analytics', 'Help'][i]));
          await tester.pumpAndSettle();
        }

        expect(find.text(pageTexts[i]), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });
}
