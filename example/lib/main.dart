import 'package:adaptive_text/adaptive_text.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AdaptiveText Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AdaptiveTextDemo(),
    );
  }
}

class AdaptiveTextDemo extends StatefulWidget {
  const AdaptiveTextDemo({super.key});

  @override
  State<AdaptiveTextDemo> createState() => _AdaptiveTextDemoState();
}

class _AdaptiveTextDemoState extends State<AdaptiveTextDemo> {
  double _containerWidth = 300.0;
  double _textScaler = 1.0;
  String _selectedText = 'Adaptive Text Demo';

  final List<String> _textOptions = [
    'Short',
    'Medium length text',
    'This is a longer text that will demonstrate the adaptive behavior',
    'Supercalifragilisticexpialidocious',
    'The quick brown fox jumps over the lazy dog multiple times to create a very long sentence',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AdaptiveText Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(_textScaler)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Controls
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Controls', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),

                      // Container Width Slider
                      Text('Container Width: ${_containerWidth.round()}px'),
                      Slider(
                        value: _containerWidth,
                        min: 100,
                        max: 500,
                        divisions: 40,
                        onChanged: (value) {
                          setState(() {
                            _containerWidth = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Text Scaler Slider
                      Text('Text Scaler: ${_textScaler.toStringAsFixed(1)}x'),
                      Slider(
                        value: _textScaler,
                        min: 0.8,
                        max: 2.0,
                        divisions: 12,
                        onChanged: (value) {
                          setState(() {
                            _textScaler = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Text Selection
                      const Text('Sample Text:'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _textOptions.map((text) {
                          return ChoiceChip(
                            label: Text(text.length > 20 ? '${text.substring(0, 20)}...' : text),
                            selected: _selectedText == text,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedText = text;
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Demo Container
              const Text('AdaptiveText Demo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              Center(
                child: Container(
                  width: _containerWidth,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.blue.shade50,
                  ),
                  child: AdaptiveText(
                    _selectedText,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                    debugMode: true,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Comparison with regular Text
              const Text('Regular Text (for comparison)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              Center(
                child: Container(
                  width: _containerWidth,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.red.shade50,
                  ),
                  child: Text(
                    _selectedText,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Extension Method Demo
              const Text('Extension Method Demo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              Center(
                child: Container(
                  width: _containerWidth,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.green.shade50,
                  ),
                  child: Text(
                    _selectedText,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ).toAdaptive(animationDuration: const Duration(milliseconds: 300), maxScaleReduction: 0.3),
                ),
              ),

              const SizedBox(height: 32),

              // Features Demo
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Features Demonstrated', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 12),
                      Text('• Three-tier adaptation: line wrapping → scaling → truncation'),
                      Text('• Smooth animations between states'),
                      Text('• Text scaler support (try changing the scaler above)'),
                      Text('• Debug mode (check console for logs)'),
                      Text('• Extension method for easy conversion'),
                      SizedBox(height: 12),
                      Text(
                        'Try adjusting the container width and text scaler to see how AdaptiveText responds!',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
