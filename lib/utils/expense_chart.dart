import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ExpenseChartCard extends StatefulWidget {
  final List<Map<String, dynamic>> dataList;
  final String currency;

  const ExpenseChartCard({
    super.key,
    required this.dataList,
    required this.currency,
  });

  @override
  State<ExpenseChartCard> createState() => _ExpenseChartCardState();
}

class _ExpenseChartCardState extends State<ExpenseChartCard> {
  String selectedRange = "Month"; // Month or Year
  final DateTime now = DateTime.now();

  Map<int, List<Map<String, dynamic>>> _groupedData() {
    Map<int, List<Map<String, dynamic>>> map = {};

    if (widget.dataList.isNotEmpty) {
      if (selectedRange == "Month") {
        final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
        for (int i = 1; i <= daysInMonth; i++) {
          map[i] =
              widget.dataList.where((e) {
                final d = DateTime.parse(e['expenseDate']);
                return d.year == now.year && d.month == now.month && d.day == i;
              }).toList();
        }
      } else if (selectedRange == "Year") {
        for (int i = 1; i <= 12; i++) {
          map[i] =
              widget.dataList.where((e) {
                final d = DateTime.parse(e['expenseDate']);
                return d.year == now.year && d.month == i;
              }).toList();
        }
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedData();

    // Prepare bars
    List<BarChartGroupData> barGroups =
        grouped.entries.map((entry) {
          double income = entry.value
              .where((e) => e['expenseSpendType'] == 'income')
              .fold(
                0.0,
                (sum, e) => sum + (e['expenseAmount'] as num).toDouble(),
              );
          double expense = entry.value
              .where((e) => e['expenseSpendType'] == 'expense')
              .fold(
                0.0,
                (sum, e) => sum + (e['expenseAmount'] as num).toDouble(),
              );

          List<BarChartRodData> rods = [];
          if (income > 0) {
            rods.add(
              BarChartRodData(toY: income, color: Colors.green, width: 12),
            );
          }
          if (expense > 0) {
            rods.add(
              BarChartRodData(toY: expense, color: Colors.red, width: 12),
            );
          }
          return BarChartGroupData(x: entry.key, barRods: rods, barsSpace: 4);
        }).toList();

    // Determine maxY
    double maxY = 0;
    for (var g in barGroups) {
      for (var rod in g.barRods) {
        if (rod.toY > maxY) maxY = rod.toY;
      }
    }
    maxY *= 1.2;

    // Calculate grouped totals for summary
    double totalIncome = 0;
    double totalExpense = 0;
    for (var list in grouped.values) {
      for (var e in list) {
        final amount = (e['expenseAmount'] as num).toDouble();
        if (e['expenseSpendType'] == 'income') {
          totalIncome += amount;
        } else if (e['expenseSpendType'] == 'expense') {
          totalExpense += amount;
        }
      }
    }

    // Title based on range
    String chartTitle =
        selectedRange == "Month"
            ? "${DateFormat.MMM().format(now)} ${now.year}" // e.g., September 2025
            : "${now.year}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header + dropdown
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Expense Report - $chartTitle",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: selectedRange,
              items:
                  ["Month", "Year"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged: (val) => setState(() => selectedRange = val!),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Bar chart
        if (grouped.isNotEmpty)
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                alignment: BarChartAlignment.spaceAround,
                barGroups: barGroups,
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        String label = '';
                        if (selectedRange == 'Month') {
                          if (value % 5 == 0 ||
                              value == 1 ||
                              value == grouped.length) {
                            label = value.toInt().toString();
                          }
                        } else if (selectedRange == 'Year') {
                          final months = [
                            'Jan',
                            'Feb',
                            'Mar',
                            'Apr',
                            'May',
                            'Jun',
                            'Jul',
                            'Aug',
                            'Sep',
                            'Oct',
                            'Nov',
                            'Dec',
                          ];
                          if (value >= 1 && value <= months.length) {
                            label = months[value.toInt() - 1];
                          }
                        }
                        return Transform.rotate(
                          angle: -0.5,
                          child: Text(
                            label,
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBorderRadius: BorderRadius.circular(12.0),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String xLabel = '';
                      final months = [
                        'Jan',
                        'Feb',
                        'Mar',
                        'Apr',
                        'May',
                        'Jun',
                        'Jul',
                        'Aug',
                        'Sep',
                        'Oct',
                        'Nov',
                        'Dec',
                      ];
                      if (selectedRange == 'Month') {
                        xLabel =
                            '${group.x.toString()} ${months[DateTime.now().month - 1]}'; // day
                      } else if (selectedRange == 'Year') {
                        if (group.x >= 1 && group.x <= months.length) {
                          xLabel = months[group.x - 1];
                        }
                      }
                      return BarTooltipItem(
                        '$xLabel\n${widget.currency} ${rod.toY.toStringAsFixed(0)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        if (grouped.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  const Icon(Icons.arrow_downward, color: Colors.red),
                  const SizedBox(width: 6),
                  Text(
                    "${widget.currency} ${totalExpense.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.arrow_upward, color: Colors.green),
                  const SizedBox(width: 6),
                  Text(
                    "${widget.currency} ${totalIncome.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          )
        else
          Center(
            child: Text(
              'No Data to Display',
              style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}
