import 'package:flutter/material.dart';

class LoggingButton extends StatelessWidget {
  final void Function()? onPressed;
  final Widget child;

  const LoggingButton({
    super.key,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xff4CAF50),
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 70),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(12),
        ),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
