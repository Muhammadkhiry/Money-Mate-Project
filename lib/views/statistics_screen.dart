import 'package:flutter/material.dart';
import 'package:money_mate/components/statistics_categories.dart';
import 'package:money_mate/components/statistics_chart.dart';
import 'package:money_mate/components/statistics_drop_down_menue.dart';
import 'package:money_mate/components/statistics_summary.dart';
import 'package:money_mate/core/api/dio_consumer.dart';
import 'package:money_mate/core/api/end_point.dart';
import 'package:money_mate/models/user_model.dart';
import 'package:money_mate/services/api_services.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String selectedMonth = "This Month";

  double income = 0;
  double expenses = 0;
  double balance = 0;

  List<double> weekly = [];
  Map<String, double> categories = {};

  late ApiServices api;

  @override
  void initState() {
    super.initState();
    api = ApiServices(api: DioConsumer());
    loadData(selectedMonth);
  }

  Future<void> loadData(String selectedMonth) async {
    try {
      debugPrint("USER TYPE: ${UserModel.currentUser?.userType}");
      debugPrint("TOKEN: ${UserModel.currentUser?.token}");

      String period = _mapPeriod(selectedMonth);

      debugPrint("PERIOD: $period");

      String token = UserModel.currentUser!.token;

      Map<String, dynamic> stats;

      debugPrint(
        "URL HIT: ${UserModel.currentUser!.userType == "company" ? "${EndPoint.baseURL}stats/company/$period" : "${EndPoint.baseURL}stats/customer/$period"}",
      );

      if (UserModel.currentUser!.userType == "company") {
        stats = await api.getCompanyStats(period: period, token: token);
        debugPrint("STATS RECEIVED: $stats", wrapWidth: 1024);

        setState(() {
          income = (stats["total_paid"] ?? 0).toDouble();
          expenses = (stats["total_unpaid"] ?? 0).toDouble();
          balance = income - expenses;

          weekly = [300, 380, 250, 200, 500, 220, 430];
          categories = {
            "Food": 0.4,
            "Shopping": 0.25,
            "Transport": 0.15,
            "Bills": 0.1,
          };
        });
      } else {
        stats = await api.getCustomerStats(period: period, token: token);
        debugPrint("STATS RECEIVED: $stats", wrapWidth: 1024);

        setState(() {
          income = (stats["total_paid"] ?? 0).toDouble();
          expenses = (stats["total_unpaid"] ?? 0).toDouble();
          balance = (stats["total_balance"] ?? 0).toDouble();

          weekly = [300, 380, 250, 200, 500, 220, 430];
          categories = {
            "Food": 0.4,
            "Shopping": 0.25,
            "Transport": 0.15,
            "Bills": 0.1,
          };
        });
      }
    } catch (e) {
      debugPrint("API ERROR: $e");

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error Loading Stats")));
      });
    }
  }

  String _mapPeriod(String value) {
    switch (value) {
      case "Today":
        return "day";
      case "This Week":
        return "week";
      case "This Month":
        return "month";
      case "This Year":
        return "year";
      default:
        return "month";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            height: 100,
            width: double.infinity,
            color: Color(0xff4CAF50),
            child: StatisticsDropDownMenue(
              onSelected: (value) {
                setState(() => selectedMonth = value!);
                loadData(value!);
              },
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Monthly Expense Summary",
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          StatisticsSummary(
            income: income,
            expenses: expenses,
            balance: balance,
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Expenses Trend",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          StatisticsChart(weekly: weekly),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Where Your Money Went",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          StatisticsCategories(categories: categories),
        ],
      ),
    );
  }
}
