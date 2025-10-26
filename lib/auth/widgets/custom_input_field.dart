import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final bool obscure;
  final TextEditingController controller;
  final IconData? suffixIcon;

  const CustomInputField({
    super.key,
    required this.label,
    required this.controller,
    this.obscure = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
