import 'package:flutter/material.dart';

/// Lab 2 "Text field" (default / focused / error). Error text always comes
/// with an icon, never colour alone (C9).
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffix,
    this.maxLength,
    this.obscureText = false,
    this.enabled = true,
    this.autofillHints,
  });

  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final IconData? prefixIcon;
  final Widget? suffix;
  final int? maxLength;
  final bool obscureText;
  final bool enabled;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      autofillHints: autofillHints,
      autocorrect: !obscureText,
      enableSuggestions: !obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        suffixIcon:
            suffix ??
            (errorText != null
                ? Icon(Icons.error_outline, color: scheme.error)
                : null),
        errorText: errorText,
        counterText: '',
      ),
    );
  }
}
