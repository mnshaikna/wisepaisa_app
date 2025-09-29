import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wisepaise/utils/utils.dart';
import '../models/expense_model.dart';

class ExpensePieChart extends StatelessWidget {
  final List<dynamic> expenses;

  const ExpensePieChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    // 1. Group by Category
    final Map<String, double> groupedData = {};
    for (var exp in expenses) {
      ExpenseModel expense = ExpenseModel.fromJson(exp);
      groupedData[expense.expenseCategory] =
          (groupedData[expense.expenseCategory] ?? 0) + expense.expenseAmount;
    }

    final totalAmount = groupedData.values.fold(0.0, (a, b) => a + b);

    // 2. Colors
    final List<Color> chartColors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.brown,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
    ];

    int colorIndex = 0;
    final sections = groupedData.entries.map((entry) {
      final percent = (entry.value / totalAmount) * 100;
      final color = chartColors[colorIndex % chartColors.length];
      colorIndex++;

      return PieChartSectionData(
        value: entry.value,
        color: color,
        radius: 70,
        title: "${percent.toStringAsFixed(1)}%",
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    // 3. Legend widget
    Widget buildLegend() {
      int index = 0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groupedData.entries.map((entry) {
          final percent = (entry.value / totalAmount) * 100;
          final color = chartColors[index % chartColors.length];
          index++;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  "${formatCurrency(entry.value, context)}  (${percent.toStringAsFixed(1)}%)",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    // 4. Chart + Legend with finite sizes
    return SizedBox(
      width: double.infinity,
      height: 350, // 👈 fixed height, prevents infinite size error
      child: Column(
        children: [
          SizedBox(height: 25.0,),
          SizedBox(
            height: 200, // 👈 chart area height
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Expanded(
            child: SingleChildScrollView(
              child: buildLegend(),
            ),
          ),
        ],
      ),
    );
  }
}