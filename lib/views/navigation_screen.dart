import 'package:flutter/material.dart';
import 'package:money_mate/models/user_model.dart';
import 'package:money_mate/views/bills_screen.dart';
import 'package:money_mate/views/home_screen.dart';
import 'package:money_mate/views/login_screen.dart';
import 'package:money_mate/views/statistics_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {

    if (UserModel.currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screens = [
      HomeScreen(user: UserModel.currentUser),
      const StatisticsScreen(),
      BillsScreen(
        userType: UserModel.currentUser!.userType,
        token: UserModel.currentUser!.token,
      ),
    ];

    final titles = ["Home", "Statistics", "Bills"];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff4CAF50),
        centerTitle: true,
        title: Text(
          titles[currentIndex],
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
      ),
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xff4CAF50),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.align_horizontal_left_rounded),
            label: 'Bills',
          ),
        ],
      ),
    );
  }
}
