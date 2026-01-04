import 'package:flutter/material.dart';

class AuthInputField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  final Color? textColor;
  final Color? hintColor;
  final Color? iconColor;
  final Color? fillColor;
  final Color? borderColor;

  const AuthInputField({
    super.key,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.controller,
    this.focusNode,
    this.textColor,
    this.hintColor,
    this.iconColor,
    this.fillColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      style: TextStyle(color: textColor ?? Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: iconColor ?? Colors.white54, size: 20),
        hintText: hint,
        hintStyle: TextStyle(color: hintColor ?? Colors.white38),
        filled: true,
        fillColor: fillColor ?? Colors.black.withValues(alpha: 0.2),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor ?? Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF38BDF8)),
        ),
      ),
    );
  }
}