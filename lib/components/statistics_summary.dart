import 'package:flutter/material.dart';

class StatisticsSummary extends StatelessWidget {
  final double income;
  final double expenses;
  final double balance;

  const StatisticsSummary({
    super.key,
    required this.income,
    required this.expenses,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(12),
          // boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryItem("Total Income", income),
                _summaryItem("Total Expenses", expenses),
                _summaryItem("Balance", balance),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: income != 0 ? expenses / income : 0,
              color: Color(0xff4CAF50),
              backgroundColor: Colors.black26,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _summaryItem(String title, double value) {
  return Column(
    children: [
      Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade800)),
      SizedBox(height: 4),
      Text(
        "\$${value.toStringAsFixed(0)}",
        style: TextStyle(
          fontSize: 18,
          color: Colors.black,
          fontWeight: FontWeight.w900,
        ),
      ),
    ],
  );
}
