import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:gewerber_app/core/theme/app_theme.dart';

/// Multi-box one-time code input with auto-advance, backspace navigation,
/// paste support and auto-submit once the code is complete.
///
/// Exposed to assistive technology as a single field labelled by
/// [semanticsLabel].
class VerificationCodeInput extends StatefulWidget {
  const VerificationCodeInput({
    super.key,
    this.length = 8,
    required this.onCompleted,
    this.initialValue = '',
    this.enabled = true,
    this.hasError = false,
    this.semanticsLabel,
  });

  /// Number of digits in the code.
  final int length;

  /// Called once when all boxes are filled.
  final ValueChanged<String> onCompleted;

  /// Seed value, e.g. to clear the input after an invalid code.
  final String initialValue;

  /// Disables the boxes, e.g. while the code is being verified.
  final bool enabled;

  /// Tints the borders red, e.g. after an invalid code.
  final bool hasError;

  /// Accessibility label for the whole input.
  final String? semanticsLabel;

  @override
  State<VerificationCodeInput> createState() => _VerificationCodeInputState();
}

class _VerificationCodeInputState extends State<VerificationCodeInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late List<String> _last;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(
        text: widget.initialValue.characters.elementAtOrNull(index) ?? '',
      ),
    );
    _last = List.generate(widget.length, (index) => _controllers[index].text);
    _focusNodes = List.generate(widget.length, (_) {
      final node = FocusNode();
      node.addListener(_onFocusChanged);
      return node;
    });
    if (widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNodes.first.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(VerificationCodeInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _applyValue(widget.initialValue);
      if (widget.initialValue.isEmpty && widget.enabled) {
        _focusNodes.first.requestFocus();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {});
  }

  void _applyValue(String value) {
    for (var i = 0; i < widget.length; i++) {
      final char = i < value.characters.length
          ? value.characters.elementAt(i)
          : '';
      if (_controllers[i].text != char) {
        _controllers[i].text = char;
      }
      _last[i] = char;
    }
  }

  String get _value => _controllers.map((c) => c.text).join();

  void _handleChange(int index, String text) {
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    final wasEmpty = _last[index].isEmpty;

    if (digits.isEmpty) {
      // Backspace on an empty box jumps to the previous one.
      if (wasEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
      _last[index] = '';
      return;
    }

    // Typing or pasting fills forward from the current box.
    var target = index;
    for (final char in digits.characters) {
      if (target >= widget.length) break;
      _controllers[target].text = char;
      _last[target] = char;
      target++;
    }
    if (target < widget.length) {
      _focusNodes[target].requestFocus();
    }
    if (_value.length == widget.length) {
      _focusNodes.last.unfocus();
      widget.onCompleted(_value);
    }
  }

  InputBorder _borderFor(int index, ColorScheme colors) {
    final focused = _focusNodes[index].hasFocus;
    final color = widget.hasError
        ? colors.error
        : focused
        ? colors.primary
        : colors.outline;
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(GewerberTokens.radiusField),
      borderSide: BorderSide(
        color: color,
        width: focused || widget.hasError ? 2 : 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Spacing between the code boxes; boxes shrink to fit narrow screens
    // instead of overflowing (fixed-size boxes can exceed the ~272px
    // available on small phones).
    const spacing = 8.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = math.min(
          48.0,
          (constraints.maxWidth - spacing * (widget.length - 1)) /
              widget.length,
        );

        return Semantics(
          label: widget.semanticsLabel,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.length, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index == widget.length - 1 ? 0 : spacing,
                ),
                child: SizedBox(
                  width: boxWidth,
                  height: 56,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    enabled: widget.enabled,
                    obscureText: false,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: textTheme.titleLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    onChanged: (text) => _handleChange(index, text),
                    decoration: InputDecoration(
                      isDense: true,
                      counterText: '',
                      border: _borderFor(index, colors),
                      enabledBorder: _borderFor(index, colors),
                      focusedBorder: _borderFor(index, colors),
                      errorBorder: _borderFor(index, colors),
                      focusedErrorBorder: _borderFor(index, colors),
                      semanticCounterText: index == 0
                          ? widget.semanticsLabel
                          : null,
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
