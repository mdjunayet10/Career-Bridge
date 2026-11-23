import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    super.key,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.autofillHints,
    this.readOnly = false,
    this.enabled,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;
  final bool readOnly;
  final bool? enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      autofillHints: autofillHints,
      readOnly: readOnly,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }
}

class AuthPasswordField extends StatefulWidget {
  const AuthPasswordField({
    required this.controller,
    super.key,
    this.label = 'Password',
    this.hint = 'Enter your password',
    this.validator,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          tooltip: _obscure ? 'Show password' : 'Hide password',
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(_obscure
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined),
        ),
      ),
    );
  }
}

String? requiredValidator(String? value, [String label = 'This field']) {
  if (value == null || value.trim().isEmpty) return '$label is required.';
  return null;
}

String? emailValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email address is required.';
  }
  final email = value.trim();
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return 'Enter a valid email address.';
  }
  return null;
}

String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) return 'Password is required.';
  if (value.length < 8) return 'Use at least 8 characters.';
  if (!RegExp(r'[A-Z]').hasMatch(value) || !RegExp(r'[0-9]').hasMatch(value)) {
    return 'Include at least one uppercase letter and one number.';
  }
  return null;
}
