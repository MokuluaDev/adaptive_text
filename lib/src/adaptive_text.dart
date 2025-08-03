// adaptive_text.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// A widget that adapts text display based on available space with a three-tier fallback:
/// 1. Reflow to multiple lines (for multi-word text only)
/// 2. Scale down font size (max 25% reduction)
/// 3. Truncate with ellipsis
class AdaptiveText extends StatefulWidget {
  const AdaptiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.maxScaleReduction = 0.25,
    this.debugMode = false,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow overflow;
  final Duration animationDuration;
  final Curve animationCurve;
  final double maxScaleReduction;
  final bool debugMode;

  @override
  State<AdaptiveText> createState() => _AdaptiveTextState();
}

class _AdaptiveTextState extends State<AdaptiveText> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  double _currentScale = 1.0;
  bool _isTruncated = false;
  _TextDisplayInfo? _cachedDisplayInfo;
  Size _lastConstraints = Size.zero;
  double? _cachedIntrinsicWidth;
  String? _lastTextForIntrinsic;
  TextStyle? _lastStyleForIntrinsic;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: widget.animationDuration, vsync: this);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: widget.animationCurve));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AdaptiveText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.style != widget.style ||
        oldWidget.maxScaleReduction != widget.maxScaleReduction ||
        oldWidget.maxLines != widget.maxLines ||
        oldWidget.animationDuration != widget.animationDuration) {
      _cachedDisplayInfo = null;
      _cachedIntrinsicWidth = null;
      _lastTextForIntrinsic = null;
      _lastStyleForIntrinsic = null;

      // Update animation controller duration
      _animationController.duration = widget.animationDuration;
    }
  }

  TextPainter _createTextPainter(TextStyle effectiveStyle) {
    return TextPainter(
      text: TextSpan(text: widget.text, style: effectiveStyle),
      textAlign: widget.textAlign ?? TextAlign.start,
      textDirection: Directionality.of(context),
    );
  }

  /// Gets the intrinsic width for a specific style with caching
  double _getIntrinsicWidthForStyle(TextStyle style) {
    if (_cachedIntrinsicWidth != null && _lastStyleForIntrinsic == style && _lastTextForIntrinsic == widget.text) {
      return _cachedIntrinsicWidth!;
    }

    final painter = _createTextPainter(style);
    painter.layout();
    _cachedIntrinsicWidth = painter.width;
    _lastStyleForIntrinsic = style;
    _lastTextForIntrinsic = widget.text;
    painter.dispose();
    return _cachedIntrinsicWidth!;
  }

  /// Determines the optimal text display strategy
  _TextDisplayInfo _calculateDisplayInfo(BoxConstraints constraints) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final textScaler = mediaQuery.textScaler;

    final defaultStyle = theme.textTheme.bodyMedium ?? const TextStyle();
    final effectiveStyle = defaultStyle.merge(widget.style);

    // Get the base font size before text scaling is applied
    final baseFontSize = effectiveStyle.fontSize ?? 14.0;
    final scaledFontSize = textScaler.scale(baseFontSize);

    // Get intrinsic width using the actually rendered (scaled) font size
    final scaledStyle = effectiveStyle.copyWith(fontSize: scaledFontSize);
    final intrinsicWidth = _getIntrinsicWidthForStyle(scaledStyle);

    // Determine available width
    double availableWidth;
    if (constraints.hasBoundedWidth && constraints.maxWidth != double.infinity) {
      availableWidth = constraints.maxWidth;
    } else {
      // For unbounded constraints, use a reasonable default
      final screenWidth = mediaQuery.size.width;
      availableWidth = screenWidth * 0.8;
    }

    final availableHeight = constraints.hasBoundedHeight ? constraints.maxHeight : double.infinity;

    // Check if this is a single word (no whitespace)
    final words = widget.text.trim().split(RegExp(r'\s+'));
    final isSingleWord = words.length == 1;

    if (kDebugMode) {
      if (widget.debugMode) {
        print(
          'AdaptiveText Debug: CONSTRAINTS - hasBoundedWidth=${constraints.hasBoundedWidth}, maxWidth=${constraints.maxWidth}, minWidth=${constraints.minWidth}',
        );
        print(
          'AdaptiveText Debug: TEXT SCALING - baseFontSize=$baseFontSize, scaledFontSize=$scaledFontSize, textScaler=${textScaler.toString()}',
        );
        print('AdaptiveText Debug: CALCULATED - availableWidth=$availableWidth, intrinsicWidth=$intrinsicWidth');
        print('AdaptiveText Debug: TEXT - isSingleWord=$isSingleWord, text="${widget.text}"');
        print('AdaptiveText Debug: STYLE - fontFamily=${effectiveStyle.fontFamily}');
      }
    }

    // Strategy 1: Try original size first
    if (intrinsicWidth <= availableWidth) {
      if (!isSingleWord) {
        // For multi-word text, check if it fits with line wrapping
        var painter = _createTextPainter(scaledStyle);
        painter.layout(maxWidth: availableWidth);

        final requestedMaxLines = widget.maxLines ?? 999;
        final fitsInHeight = !constraints.hasBoundedHeight || painter.height <= availableHeight;
        final lineCount = painter.computeLineMetrics().length;

        painter.dispose();

        if (fitsInHeight && lineCount <= requestedMaxLines) {
          if (kDebugMode) {
            if (widget.debugMode) {
              print('AdaptiveText Debug: Using original size with wrapping');
            }
          }
          return _TextDisplayInfo(
            scale: 1.0,
            maxLines: requestedMaxLines,
            isTruncated: false,
            style: effectiveStyle, // Use original style, let MediaQuery handle scaling
            overflow: TextOverflow.visible, // Not truncated, so use visible
          );
        }
      } else {
        // Single word - double check with actual layout
        var painter = _createTextPainter(scaledStyle);
        painter.layout();
        final actualWidth = painter.width;
        painter.dispose();

        if (kDebugMode) {
          if (widget.debugMode) {
            print('AdaptiveText Debug: Single word check - actualWidth=$actualWidth vs availableWidth=$availableWidth');
          }
        }

        if (actualWidth <= availableWidth) {
          if (kDebugMode) {
            if (widget.debugMode) {
              print('AdaptiveText Debug: Single word fits at original size');
            }
          }
          return _TextDisplayInfo(
            scale: 1.0,
            maxLines: 1,
            isTruncated: false,
            style: effectiveStyle, // Use original style, let MediaQuery handle scaling
            overflow: TextOverflow.visible, // Not truncated, so use visible
          );
        }
      }
    }

    // Strategy 2: Try scaling down (only if scaling is allowed)
    if (widget.maxScaleReduction > 0.0) {
      const scaleSteps = [0.95, 0.9, 0.85, 0.8, 0.75];
      for (double scale in scaleSteps) {
        if (scale < (1.0 - widget.maxScaleReduction)) break;

        // Scale the base font size, then apply text scaler
        final scaledBaseFontSize = baseFontSize * scale;
        final finalScaledFontSize = textScaler.scale(scaledBaseFontSize);
        final testStyle = effectiveStyle.copyWith(fontSize: finalScaledFontSize);

        final scaledPainter = _createTextPainter(testStyle);

        bool fits = false;
        int maxLines = 1;

        if (isSingleWord) {
          // For single words, just check if scaled width fits
          scaledPainter.layout();
          fits = scaledPainter.width <= availableWidth;
          maxLines = 1;
        } else {
          // For multi-word text, check if scaled version fits with wrapping
          scaledPainter.layout(maxWidth: availableWidth);
          final requestedMaxLines = widget.maxLines ?? 999;
          final fitsInHeight = !constraints.hasBoundedHeight || scaledPainter.height <= availableHeight;
          final lineCount = scaledPainter.computeLineMetrics().length;

          fits = fitsInHeight && lineCount <= requestedMaxLines;
          maxLines = requestedMaxLines;
        }

        scaledPainter.dispose();

        if (fits) {
          if (kDebugMode) {
            if (widget.debugMode) {
              print(
                'AdaptiveText Debug: Using scaled size: $scale (base: $scaledBaseFontSize, final: $finalScaledFontSize)',
              );
            }
          }
          return _TextDisplayInfo(
            scale: scale,
            maxLines: maxLines,
            isTruncated: false,
            style: effectiveStyle.copyWith(fontSize: scaledBaseFontSize), // Store unscaled version
            overflow: TextOverflow.visible, // Not truncated, so use visible
          );
        }
      }
    } else {
      if (kDebugMode) {
        if (widget.debugMode) {
          print('AdaptiveText Debug: Scaling disabled (maxScaleReduction: ${widget.maxScaleReduction})');
        }
      }
    }

    // Strategy 3: Truncate
    if (kDebugMode) {
      if (widget.debugMode) {
        print('AdaptiveText Debug: Using truncation');
      }
    }

    final requestedMaxLines = widget.maxLines ?? 1;
    final maxLinesForTruncation = constraints.hasBoundedHeight
        ? (availableHeight / (effectiveStyle.fontSize ?? 14.0 * 1.4)).floor().clamp(1, requestedMaxLines)
        : requestedMaxLines;

    return _TextDisplayInfo(
      scale: 1.0,
      maxLines: maxLinesForTruncation,
      isTruncated: true,
      style: effectiveStyle, // Use original style, let MediaQuery handle scaling
      overflow: widget.overflow, // Use the widget's overflow parameter when truncating
    );
  }

  void _updateAnimation(double targetScale) {
    if ((_currentScale - targetScale).abs() > 0.01) {
      _scaleAnimation = Tween<double>(
        begin: _currentScale,
        end: targetScale,
      ).animate(CurvedAnimation(parent: _animationController, curve: widget.animationCurve));

      _currentScale = targetScale;

      // Only animate if duration > 0 to avoid unnecessary animations in tests
      if (widget.animationDuration.inMilliseconds > 0) {
        // Defer animation start until after build is complete
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _animationController.reset();
            _animationController.forward();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Check if we need to recalculate
        final sizeDifference = (constraints.biggest.width - _lastConstraints.width).abs() +
            (constraints.biggest.height - _lastConstraints.height).abs();

        if (sizeDifference < 1.0 && _cachedDisplayInfo != null) {
          return _buildAnimatedText(_cachedDisplayInfo!);
        }

        _lastConstraints = constraints.biggest;

        // For unbounded constraints, try to get a more realistic size estimate
        // by creating a temporary text widget and seeing how much space it actually needs
        if (!constraints.hasBoundedWidth || constraints.maxWidth == double.infinity) {
          if (kDebugMode) {
            if (widget.debugMode) {
              print('AdaptiveText Debug: UNBOUNDED CONSTRAINTS - attempting auto-detection');
            }
          }

          // Try to render the text at original size to see actual space needed
          return _buildWithAutoDetectedConstraints(constraints);
        }

        final displayInfo = _calculateDisplayInfo(constraints);
        _cachedDisplayInfo = displayInfo;

        // Update animation if scale changed
        _updateAnimation(displayInfo.scale);

        // Update truncation state for accessibility
        final wasTruncated = _isTruncated;
        _isTruncated = displayInfo.isTruncated;

        if (kDebugMode) {
          if (widget.debugMode) {
            print(
                'AdaptiveText Debug: Final decision - isTruncated: $_isTruncated, scale: ${displayInfo.scale}, overflow: ${displayInfo.overflow}');
          }
        }

        if (_isTruncated && !wasTruncated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              SemanticsService.announce('Text truncated', TextDirection.ltr);
            }
          });
        }

        return _buildAnimatedText(displayInfo);
      },
    );
  }

  Widget _buildWithAutoDetectedConstraints(BoxConstraints originalConstraints) {
    // For unbounded constraints, first try to see if text fits at natural size
    final theme = Theme.of(context);
    final defaultStyle = theme.textTheme.bodyMedium ?? const TextStyle();
    final effectiveStyle = defaultStyle.merge(widget.style);
    final mediaQuery = MediaQuery.of(context);
    final textScaler = mediaQuery.textScaler;
    final baseFontSize = effectiveStyle.fontSize ?? 14.0;
    final scaledFontSize = textScaler.scale(baseFontSize);
    final scaledStyle = effectiveStyle.copyWith(fontSize: scaledFontSize);

    final intrinsicWidth = _getIntrinsicWidthForStyle(scaledStyle);
    final screenWidth = mediaQuery.size.width;

    // If text fits comfortably in a reasonable portion of screen, don't constrain it
    final reasonableWidth = screenWidth * 0.7;

    BoxConstraints adjustedConstraints;
    if (intrinsicWidth <= reasonableWidth) {
      // Text fits naturally - use generous constraint
      adjustedConstraints = originalConstraints.copyWith(
        maxWidth: intrinsicWidth + 32.0, // Generous buffer
      );
      if (kDebugMode) {
        if (widget.debugMode) {
          print('AdaptiveText Debug: AUTO-CONSTRAINT - text fits naturally, using generous: ${intrinsicWidth + 32.0}');
        }
      }
    } else {
      // Text is too large - force reasonable constraint
      adjustedConstraints = originalConstraints.copyWith(maxWidth: reasonableWidth);
      if (kDebugMode) {
        if (widget.debugMode) {
          print('AdaptiveText Debug: AUTO-CONSTRAINT - text too large, forcing constraint: $reasonableWidth');
        }
      }
    }

    final displayInfo = _calculateDisplayInfo(adjustedConstraints);
    _cachedDisplayInfo = displayInfo;
    _updateAnimation(displayInfo.scale);

    final wasTruncated = _isTruncated;
    _isTruncated = displayInfo.isTruncated;

    if (kDebugMode) {
      if (widget.debugMode) {
        print(
            'AdaptiveText Debug: Auto-constraint final decision - isTruncated: $_isTruncated, scale: ${displayInfo.scale}, overflow: ${displayInfo.overflow}');
      }
    }

    if (_isTruncated && !wasTruncated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          SemanticsService.announce('Text truncated', TextDirection.ltr);
        }
      });
    }

    return _buildAnimatedText(displayInfo);
  }

  Widget _buildAnimatedText(_TextDisplayInfo displayInfo) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        // Apply the current animated scale
        final animatedScale = _scaleAnimation.value;
        final finalStyle = displayInfo.style.copyWith(fontSize: (displayInfo.style.fontSize ?? 14.0) * animatedScale);

        // For truncated text with unbounded constraints, apply appropriate constraint
        Widget textWidget = Text(
          widget.text,
          style: finalStyle,
          textAlign: widget.textAlign,
          maxLines: displayInfo.maxLines,
          overflow: displayInfo.overflow, // Use the overflow from display info
          softWrap: !displayInfo.isTruncated || displayInfo.maxLines > 1,
        );

        // Only apply constraint box if we're truncating AND have unbounded constraints
        if (displayInfo.isTruncated) {
          final context = this.context;
          final renderBox = context.findRenderObject() as RenderBox?;
          final constraints = renderBox?.constraints;

          if (constraints != null && (!constraints.hasBoundedWidth || constraints.maxWidth == double.infinity)) {
            final mediaQuery = MediaQuery.of(context);
            final screenWidth = mediaQuery.size.width;
            final maxWidth = screenWidth * 0.7; // Use same logic as above

            textWidget = ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: textWidget,
            );
          }
        }

        // Only add Semantics if we have a custom label (for truncated text)
        if (_isTruncated) {
          return Semantics(
            label: '${widget.text}, truncated',
            child: textWidget,
          );
        } else {
          return textWidget;
        }
      },
    );
  }
}

/// Internal class to hold text display calculation results
class _TextDisplayInfo {
  const _TextDisplayInfo({
    required this.scale,
    required this.maxLines,
    required this.isTruncated,
    required this.style,
    required this.overflow,
  });

  final double scale;
  final int maxLines;
  final bool isTruncated;
  final TextStyle style;
  final TextOverflow overflow;
}

/// Extension to provide easy access to AdaptiveText
extension AdaptiveTextExtension on Text {
  /// Converts a regular Text widget to an AdaptiveText widget
  AdaptiveText toAdaptive({
    Duration animationDuration = const Duration(milliseconds: 200),
    Curve animationCurve = Curves.easeInOut,
    double maxScaleReduction = 0.25,
    bool debugMode = false,
  }) {
    return AdaptiveText(
      data ?? '',
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      maxScaleReduction: maxScaleReduction,
      debugMode: debugMode,
    );
  }
}
