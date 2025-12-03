import 'package:flutter/material.dart';
import 'package:money_mate/components/statistics_categories.dart';
import 'package:money_mate/components/statistics_chart.dart';
import 'package:money_mate/components/statistics_drop_down_menue.dart';
import 'package:money_mate/components/statistics_summary.dart';

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

  @override
  void initState() {
    super.initState();
    loadData(selectedMonth);
  }

  Future<void> loadData(String selectedMonth) async {
    // TODO: api call

    // TODO: all data here comes from api call
    // this is dummy data for implementing the ui
    setState(() {
      income = 2100;
      expenses = 1240;
      balance = 860;

      weekly = [300, 380, 250, 200, 500, 220, 430];

      categories = {
        "Food": 0.4,
        "Shopping": 0.25,
        "Transport": 0.15,
        "Bills": 0.1,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
      ),
    );
  }
}
