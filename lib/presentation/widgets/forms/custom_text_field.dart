import 'package:flutter/material.dart';

import 'package:gewerber_app/presentation/widgets/forms/field_hint.dart';
import 'package:gewerber_app/presentation/widgets/forms/field_info_icon.dart';

/// Form field styled by the Gewerber theme with an optional icon.
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.suffixIcon,
    this.hint,
    this.onHintMoreRequested,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
    this.onChanged,
    this.validator,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final Widget? suffixIcon;

  /// Extended hint attached to the field: renders an info icon as part of
  /// the decoration's suffix area (merged with [suffixIcon]) and opens the
  /// adaptive explanation sheet on tap.
  final FieldHint? hint;

  /// Called from the hint sheet's "more" action; lets callers deep-link into
  /// the guidance system (navigation stays outside this widget's layer).
  final VoidCallback? onHintMoreRequested;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;

  /// The hint info icon, if [hint] is set.
  Widget? get _infoIcon {
    final hint = this.hint;
    if (hint == null) return null;
    return FieldInfoIcon(
      infoText: hint.shortText,
      longInfoText: hint.longText,
      sheetTitle: label,
      onLongInfoRequested: onHintMoreRequested,
    );
  }

  /// The decoration suffix: the caller's [suffixIcon] merged with the hint
  /// info icon (icon first, caller's widget trailing).
  Widget? get _suffix {
    final infoIcon = _infoIcon;
    if (infoIcon == null) return suffixIcon;
    if (suffixIcon == null) return infoIcon;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [infoIcon, suffixIcon!],
    );
  }

  @override
  Widget build(BuildContext context) {
    final decoration = InputDecoration(
      labelText: label,
      helperText: helperText,
      errorText: errorText,
      prefixIcon: icon != null ? Icon(icon) : null,
      suffixIcon: _suffix,
    );

    if (validator == null) {
      return TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        autofillHints: autofillHints,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        enabled: enabled,
        readOnly: readOnly,
        autofocus: autofocus,
        focusNode: focusNode,
        textCapitalization: textCapitalization,
        decoration: decoration,
      );
    }

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onFieldSubmitted: onSubmitted,
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      focusNode: focusNode,
      textCapitalization: textCapitalization,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: decoration,
    );
  }
}
