import 'package:flutter/material.dart';
import 'package:money_mate/controllers/controllers.dart';
import 'package:money_mate/core/api/dio_consumer.dart';
import 'package:money_mate/models/bill_model.dart';
import 'package:money_mate/models/user_model.dart';
import 'package:money_mate/services/api_services.dart';
import 'package:money_mate/views/login_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel? user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Bill>> _billsFuture;

  @override
  void initState() {
    super.initState();
    _billsFuture = ApiServices(api: DioConsumer())
        .billsView(widget.user!.userType, widget.user!.token)
        .then((model) => model?.bills ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👋 Hello
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hello, ${widget.user!.userName} 👋",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Controllers.emailController.clear();
                        Controllers.passwordController.clear();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text("Log out", style: TextStyle(fontSize: 16)),
                          Icon(Icons.logout),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // 🧑‍💼 User Info
              _userInfoCard(),

              const SizedBox(height: 25),

              // 🧾 Stats + Recent Bills
              FutureBuilder<List<Bill>>(
                future: _billsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("No bills found");
                  }

                  final bills = snapshot.data!.take(4).toList();
                  final allBills = snapshot.data!.toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Section
                      _buildStatsSection(allBills),
                      const SizedBox(height: 25),

                      // Recent Bills Title
                      const Text(
                        "Recent Bills",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Recent Bills List
                      Column(
                        children: bills.map((bill) => _billTile(bill)).toList(),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 40),

              // 🚪 Logout Button
            ],
          ),
        ),
      ),
    );
  }

  // ================= Helper Widgets =================

  Widget _userInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "User Information",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Email: ${widget.user!.email}",
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            "User Type: ${widget.user!.userType}",
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _billTile(Bill bill) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        title: Text("Bill "),
        subtitle: Text("${bill.billAmount} EGP"),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: bill.billStatus == "paid"
                ? Colors.green.withOpacity(0.2)
                : Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            bill.billStatus ?? "",
            style: TextStyle(
              color: bill.billStatus == "paid" ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(List<Bill> bills) {
    double total = 0, paid = 0, unpaid = 0;

    for (var bill in bills) {
      total += bill.billAmount ?? 0;
      if (bill.billStatus == "paid") {
        paid += bill.billAmount ?? 0;
      } else {
        unpaid += bill.billAmount ?? 0;
      }
    }

    String format(double value) => value.toStringAsFixed(2) + " EGP";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statCard("Total", format(total)),
        _statCard("Paid", format(paid)),
        _statCard("Unpaid", format(unpaid)),
      ],
    );
  }

  Widget _statCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      width: 110,
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
