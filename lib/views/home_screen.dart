import 'package:flutter/material.dart';
import 'package:money_mate/views/add_new_expense.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => AddNewExpense()));
        },
        backgroundColor: const Color(0xff4CAF50),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      backgroundColor: const Color(0xff4CAF50),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xffF5F5F5),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top card
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Total Spent Today",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff52595C),
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "120 EGP",
                                  style: TextStyle(
                                    fontSize: 36,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Divider(
                                  indent: 30,
                                  endIndent: 30,
                                  color: Colors.grey,
                                ),
                                Text(
                                  "This Month: 1500 EGP",
                                  style: TextStyle(
                                    color: Color(0xff52595C),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        const Text(
                          "Recent Expenses",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff52595C),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // List of recent expenses
                        Column(
                          children: const [
                            ExpenseTile(
                              icon: Icons.fastfood_rounded,
                              title: "Subway Sandwich",
                              date: "28 Oct 2025",
                              price: "50 EGP",
                            ),
                            ExpenseTile(
                              icon: Icons.local_taxi,
                              title: "Uber Ride",
                              date: "27 Oct 2025",
                              price: "35 EGP",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpenseTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String date;
  final String price;

  const ExpenseTile({
    super.key,
    required this.icon,
    required this.title,
    required this.date,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: Color(0xff4CAF50)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          date,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        trailing: Text(
          price,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
