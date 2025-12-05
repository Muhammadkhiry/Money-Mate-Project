import 'package:flutter/material.dart';
import 'package:money_mate/components/logging_button.dart';
import 'package:money_mate/controllers/controllers.dart';
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

  final List<Widget> screens = [
    const HomeScreen(),
    const StatisticsScreen(),
    BillsScreen(userType: LoginScreen.userModel!.userType, token: LoginScreen.userModel!.token),
  ];

  final List<String> titles = ["Home", "Statistics", "Bills"];
  Future<void> _logout() async {
    Controllers.emailController.clear();
    Controllers.passwordController.clear();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Center(
          child: LoggingButton(
            width: 70,
            height: 35,
            onPressed: _logout,
            child: Text(
              "Logout",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
        ),
      ),
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
