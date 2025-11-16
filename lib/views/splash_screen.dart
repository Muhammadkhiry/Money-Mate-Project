import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff4CAF50),
      body: Center(
        child: Column(
          spacing: 13,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              size: 150,
              color: Colors.white,
            ),
            Text(
              "Money Mate",
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Manage Your Money Smartly",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 55),
            Icon(
              Icons.circle_outlined,
              color: Colors.white,
              size: 55,
              weight: 100,
            ),
          ],
        ),
      ),
    );
  }
}
