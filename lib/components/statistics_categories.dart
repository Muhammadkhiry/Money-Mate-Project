import 'package:flutter/material.dart';

class StatisticsCategories extends StatelessWidget {
  final Map<String, double> categories;

  const StatisticsCategories({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: categories.entries.map((e) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    e.key,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    child: LinearProgressIndicator(
                      value: e.value,
                      color: Color(0xff4CAF50),
                      backgroundColor: Colors.black26,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  "${(e.value * 100).toInt()}%",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
