import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/app_providers.dart';
import '../../../core/utils/money.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(monthSummaryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: summary.when(
          data: (s) {
            final inc = s.incomeMinor.toDouble();
            final exp = s.expenseMinor.toDouble();
            final maxY = [inc, exp, 10000].reduce((a, b) => a > b ? a : b) * 1.2;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This month (BDT minor units shown as ৳)', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 24),
                SizedBox(
                  height: 260,
                  child: BarChart(
                    BarChartData(
                      maxY: maxY == 0 ? 100 : maxY,
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: inc, color: Colors.teal, width: 48, borderRadius: BorderRadius.circular(4))]),
                        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: exp, color: Colors.red.shade400, width: 48, borderRadius: BorderRadius.circular(4))]),
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 44)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) => Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(v == 0 ? 'Income' : 'Expense'),
                            ),
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: true),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    title: const Text('Income'),
                    trailing: Text(formatBdtMinor(s.incomeMinor)),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text('Expense'),
                    trailing: Text(formatBdtMinor(s.expenseMinor)),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
        ),
      ),
    );
  }
}
