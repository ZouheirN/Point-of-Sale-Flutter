import 'package:flutter/material.dart';

class PrimaryTextField extends StatefulWidget {
  final String text;
  final TextEditingController controller;
  final GlobalKey<FormState>? formKey;
  final bool obscureText;
  final String? Function(String?)? validator;

  const PrimaryTextField({
    super.key,
    required this.text,
    required this.controller,
    this.formKey,
    this.obscureText = false,
    this.validator,
  });

  @override
  State<PrimaryTextField> createState() => _PrimaryTextFieldState();
}

class _PrimaryTextFieldState extends State<PrimaryTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Colors.black,
      obscureText: widget.obscureText,
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: widget.text,
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(width: 0, color: Color(0xF0F0F0FF))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(width: 0, color: Color(0xF0F0F0FF))),
        fillColor: const Color(0xF0F0F0FF),
        filled: true,
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(width: 0, color: Color(0xF0F0F0FF))),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(width: 0, color: Color(0xF0F0F0FF))),
      ),
      validator: widget.validator,
    );
  }
}
