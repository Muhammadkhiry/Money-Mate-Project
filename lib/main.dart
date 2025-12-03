import 'package:flutter/material.dart';
import 'package:money_mate/views/login_screen.dart';

void main() {
  runApp(const Home());
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff4CAF50),
          centerTitle: true,
          title: Text(
            "Money Mate",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
        ),
        drawer: Drawer(child: Icon(Icons.abc)),
        body: LoginScreen(),
      ),
    );
  }
}
