import 'package:flutter/material.dart';
import 'package:flutter/src/services/text_formatter.dart';

class PrimaryTextField extends StatefulWidget {
  final String? hintText;
  final TextEditingController controller;
  final GlobalKey<FormState>? formKey;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Icon? icon;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const PrimaryTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.formKey,
    this.obscureText = false,
    this.validator,
    this.icon,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  State<PrimaryTextField> createState() => _PrimaryTextFieldState();
}

class _PrimaryTextFieldState extends State<PrimaryTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: widget.onChanged,
      cursorColor: Colors.black,
      obscureText: widget.obscureText,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
        prefixIcon: widget.icon,
        hintText: widget.hintText,
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

class SecondaryTextField extends StatefulWidget {
  final String? hintText;
  final TextEditingController controller;
  final GlobalKey<FormState>? formKey;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? icon;
  final void Function(String)? onChanged;
  final String? labelText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final bool? enabled;

  const SecondaryTextField({
    super.key,
    this.hintText,
    required this.controller,
    this.formKey,
    this.obscureText = false,
    this.validator,
    this.icon,
    this.onChanged,
    this.labelText,
    this.keyboardType,
    this.inputFormatters,
    this.suffixIcon,
    this.enabled,
  });

  @override
  State<SecondaryTextField> createState() => _SecondaryTextFieldState();
}

class _SecondaryTextFieldState extends State<SecondaryTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      cursorColor: Colors.black,
      obscureText: widget.obscureText,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
        prefixIcon: widget.icon,
        suffixIcon: widget.suffixIcon,
        hintText: widget.hintText,
        labelText: widget.labelText,
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(width: 25, color: Color(0xF0F0F0FF))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(width: 25, color: Color(0xF0F0F0FF))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(width: 25, color: Color(0xF0F0F0FF))),
        fillColor: const Color(0xF0F0F0FF),
        filled: true,
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(width: 25, color: Color(0xF0F0F0FF))),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(width: 25, color: Color(0xF0F0F0FF))),
      ),
      validator: widget.validator,
    );
  }
}
