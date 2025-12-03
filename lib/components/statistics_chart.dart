import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatisticsChart extends StatelessWidget {
  final List<double> weekly;

  const StatisticsChart({super.key, required this.weekly});

  @override
  Widget build(BuildContext context) {
    if (weekly.isEmpty) {
      return Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey),
        ),
      );
    }

    double maxValue = weekly.reduce((a, b) => a > b ? a : b);
    double maxY = ((maxValue / 200).ceil() * 200).toDouble();

    return SizedBox(
      height: 120,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: BarChart(
          BarChartData(
            maxY: maxY,
            minY: 0,

            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 200,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: Colors.grey.shade300, strokeWidth: 1),
            ),

            borderData: FlBorderData(
              show: true,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 1),
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),

            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                    return Text(days[value.toInt()]);
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: 200,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      "\$${value.toInt().toString()}",
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    );
                  },
                ),
              ),

              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),

              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            barGroups: List.generate(
              weekly.length,
              (i) => BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: weekly[i],
                    color: Color(0xff4CAF50),
                    width: 20,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                tooltipMargin: 8,
                getTooltipColor: (group) => Colors.black87,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    "\$${rod.toY.toInt()}",
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
