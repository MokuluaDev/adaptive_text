# Adaptive Text

[![Coverage Status](https://coveralls.io/repos/github/MokuluaDev/adaptive_text/badge.svg?branch=main)](https://coveralls.io/github/MokuluaDev/adaptive_text?branch=main)
[![pub package](https://img.shields.io/pub/v/adaptive_text.svg)](https://pub.dev/packages/adaptive_text)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Flutter widget that intelligently adapts text display based on available space with a three-tier fallback strategy:

1. **Reflow to multiple lines** (for multi-word text only)
2. **Scale down font size** (maximum 25% reduction by default)
3. **Truncate with ellipsis** (as last resort)

Perfect for responsive UIs, dynamic content, and accessibility-friendly applications that need to handle varying text lengths and screen sizes gracefully.

## Features

- 🎯 **Smart text fitting** with three-tier fallback strategy
- 🔄 **Smooth animations** between different display modes
- ♿ **Accessibility support** with semantic announcements
- 📱 **Text scaler aware** - works with system font scaling
- 🎨 **Highly customizable** - control animation, scaling limits, and overflow behavior
- 🚀 **Performance optimized** with intelligent caching
- 🐛 **Debug mode** for development and troubleshooting

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  adaptive_text: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:adaptive_text/adaptive_text.dart';

// Basic usage
AdaptiveText(
  'This text will adapt to available space',
  style: TextStyle(fontSize: 24),
)

// Convert existing Text widget
Text(
  'Your existing text',
  style: TextStyle(fontSize: 18),
).toAdaptive()
```

## Usage Examples

### Basic Adaptive Text

```dart
AdaptiveText(
  'This text will automatically adapt to fit the available space',
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
  maxLines: 2,
)
```

### Customized Behavior

```dart
AdaptiveText(
  'Custom adaptive text with specific parameters',
  style: TextStyle(fontSize: 18),
  maxLines: 3,
  maxScaleReduction: 0.3, // Allow up to 30% font size reduction
  animationDuration: Duration(milliseconds: 300),
  animationCurve: Curves.easeInOut,
  overflow: TextOverflow.fade, // Use fade instead of ellipsis
)
```

### Debug Mode

```dart
AdaptiveText(
  'Debug this text adaptation',
  style: TextStyle(fontSize: 16),
  debugMode: true, // Enables console debugging output
)
```

### Using the Extension

```dart
// Convert any existing Text widget
Text(
  'Your existing text',
  style: TextStyle(fontSize: 24),
  textAlign: TextAlign.center,
).toAdaptive(
  animationDuration: Duration(milliseconds: 200),
  maxScaleReduction: 0.2,
)
```

## How It Works

### Three-Tier Adaptation Strategy

1. **Line Wrapping** (Multi-word text only)
    - Text flows to multiple lines within the available space
    - Respects `maxLines` parameter
    - Only applies to text with multiple words

2. **Font Scaling**
    - Gradually reduces font size while maintaining readability
    - Default maximum reduction: 25% of original size
    - Smooth animated transitions between scales
    - Preserves text style properties

3. **Truncation**
    - Last resort when text cannot fit even when scaled
    - Uses ellipsis (or custom overflow) to indicate truncated content
    - Announces truncation to screen readers for accessibility

### Text Scaler Support

AdaptiveText automatically works with Flutter's text scaling features:

```dart
MediaQuery(
  data: MediaQuery.of(context).copyWith(
    textScaler: TextScaler.linear(1.5), // 150% text scaling
  ),
  child: AdaptiveText(
    'This text respects system text scaling preferences',
    style: TextStyle(fontSize: 16),
  ),
)
```

## API Reference

### AdaptiveText Properties

| Property            | Type           | Default                       | Description                                |
|---------------------|----------------|-------------------------------|--------------------------------------------|
| `text`              | `String`       | required                      | The text to display                        |
| `style`             | `TextStyle?`   | null                          | Text style (fontSize, fontFamily, etc.)    |
| `textAlign`         | `TextAlign?`   | null                          | Text alignment                             |
| `maxLines`          | `int?`         | null                          | Maximum number of lines (null = unlimited) |
| `overflow`          | `TextOverflow` | `TextOverflow.ellipsis`       | How to handle text overflow                |
| `animationDuration` | `Duration`     | `Duration(milliseconds: 200)` | Animation duration for scaling             |
| `animationCurve`    | `Curve`        | `Curves.easeInOut`            | Animation curve for scaling                |
| `maxScaleReduction` | `double`       | `0.25`                        | Maximum font size reduction (0.0-1.0)      |
| `debugMode`         | `bool`         | `false`                       | Enable debug logging                       |

### Extension Method

```dart
extension AdaptiveTextExtension on Text {
  AdaptiveText toAdaptive({
    Duration animationDuration = const Duration(milliseconds: 200),
    Curve animationCurve = Curves.easeInOut,
    double maxScaleReduction = 0.25,
    bool debugMode = false,
  })
}
```

## Accessibility Features

- **Semantic announcements**: Automatically announces when text is truncated
- **Screen reader support**: Provides appropriate labels for truncated content
- **Text scaler compatibility**: Respects system font scaling preferences
- **Keyboard navigation**: Works seamlessly with keyboard navigation

## Performance Considerations

- **Intelligent caching**: Avoids recalculation when constraints haven't changed
- **Optimized text measurement**: Minimizes TextPainter operations
- **Efficient animations**: Uses Flutter's built-in animation framework
- **Memory efficient**: Disposes resources properly

## Troubleshooting

### Text appears truncated even with plenty of space

This usually happens when the widget receives unbounded constraints (e.g., inside a `Row` without `Expanded`).

**Solution**: Wrap with `Expanded` or `Flexible`:

```dart
Row(
  children: [
    Expanded(
      child: AdaptiveText('Your text here'),
    ),
  ],
)
```

### Animation not working

Enable debug mode to see what's happening:

```dart
AdaptiveText(
  'Your text',
  debugMode: true, // Check console for debug info
)
```

### Text scaler issues

Ensure your app properly supports text scaling:

```dart
MaterialApp(
  builder: (context, child) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: MediaQuery.textScalerOf(context),
      ),
      child: child!,
    );
  },
  // ... rest of your app
)
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Setup

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests if applicable
5. Ensure the code passes all tests (`flutter test`)
6. Commit your changes (`git commit -m 'Add some amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you find this package helpful, please consider:

- ⭐ Starring the repository on GitHub
- 👍 Liking the package on pub.dev
- 🐛 Reporting issues or bugs
- 💡 Suggesting new features

For questions or support, please open an issue on [GitHub](https://github.com/MokuluaDev/adaptive_text/issues).