import 'package:flutter/material.dart';

class LoggingTextField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final bool isSecured;
  final String? Function(String?)? validator;
  final String? Function(String?)? onChanged;
  final TextInputType? keyboardType;
  const LoggingTextField({
    super.key,
    required this.hint,
    required this.controller,
    required this.isSecured,
    required this.validator,
    this.onChanged,
    this.keyboardType,
  });

  @override
  State<LoggingTextField> createState() => _LoggingTextFieldState();
}

class _LoggingTextFieldState extends State<LoggingTextField> {
  late bool? isPasswordShown = widget.isSecured ? false : null;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: widget.keyboardType,
      controller: widget.controller,
      validator: widget.validator,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade500),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xff4CAF50)),
        ),
        hint: Text(widget.hint, style: TextStyle(color: Colors.grey)),
        suffixIcon: isPasswordShown == null
            ? null
            : IconButton(
                onPressed: () {
                  setState(() => isPasswordShown = !isPasswordShown!);
                },
                icon: Icon(
                  isPasswordShown! ? Icons.visibility : Icons.visibility_off,
                ),
              ),
      ),
      obscureText: widget.isSecured ? !isPasswordShown! : false,
    );
  }
}
