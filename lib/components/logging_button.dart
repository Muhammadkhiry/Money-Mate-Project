import 'package:flutter/material.dart';

class LoggingButton extends StatelessWidget {
  final void Function()? onPressed;
  final Widget child;
  final double? width, height;

  const LoggingButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xff4CAF50),
        foregroundColor: Colors.white,
        minimumSize: Size(width ?? double.infinity, height ?? 70),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(12),
        ),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
