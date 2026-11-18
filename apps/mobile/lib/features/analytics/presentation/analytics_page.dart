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
    final byCategory = ref.watch(monthExpenseByCategoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          summary.when(
            data: (s) {
              final inc = s.incomeMinor / 100;
              final exp = s.expenseMinor / 100;
              final maxY = [inc, exp, 10000].reduce((a, b) => a > b ? a : b) * 1.2;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('This month', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 240,
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
                  const SizedBox(height: 8),
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
          const SizedBox(height: 24),
          Text('Spending by category', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          byCategory.when(
            data: (list) {
              if (list.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No expenses this month.'),
                  ),
                );
              }
              final maxTotal = list.first.totalMinor == 0 ? 1 : list.first.totalMinor;
              return Column(
                children: list.map((e) {
                  final ratio = (e.totalMinor / maxTotal).clamp(0.0, 1.0).toDouble();
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(e.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                              ),
                              Text(formatBdtMinor(e.totalMinor)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 8,
                              backgroundColor:
                                  Theme.of(context).colorScheme.surfaceContainerHighest,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error: $err'),
          ),
        ],
      ),
    );
  }
}