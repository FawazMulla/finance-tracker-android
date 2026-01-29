import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import 'home_screen.dart';
import 'history_screen.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            if (provider.transactions.isEmpty) {
              return const Center(
                  child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('Not enough data for stats'),
              ));
            }

            final income = provider.transactions
                .where((t) => t.amount > 0)
                .fold(0.0, (sum, t) => sum + t.amount);
            final expense = provider.transactions
                .where((t) => t.amount < 0)
                .fold(0.0, (sum, t) => sum + t.amount.abs());
            
            final total = income + expense;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        title: 'Income',
                        amount: income,
                        color: Colors.green,
                        icon: Icons.arrow_upward,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _MetricCard(
                        title: 'Expense',
                        amount: expense,
                        color: Colors.red,
                        icon: Icons.arrow_downward,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Pie Chart
                Card(
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                            children: [
                                const Text("Income vs Expense", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 24),
                                SizedBox(
                                    height: 200,
                                    child: PieChart(
                                        PieChartData(
                                            sections: [
                                                PieChartSectionData(
                                                    value: income,
                                                    color: Colors.green,
                                                    title: '${((income/total)*100).toStringAsFixed(0)}%',
                                                    radius: 50,
                                                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                ),
                                                PieChartSectionData(
                                                    value: expense,
                                                    color: Colors.red,
                                                    title: '${((expense/total)*100).toStringAsFixed(0)}%',
                                                    radius: 50,
                                                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                ),
                                            ],
                                            sectionsSpace: 2,
                                            centerSpaceRadius: 40,
                                        ),
                                    ),
                                ),
                            ],
                        ),
                    ),
                ),

                const SizedBox(height: 24),
                // Balance Trend (Simplified as Line Chart requiring sorted data)
                // Leaving placeholder for line chart complexity reduction in this pass
                // Balance Trend Chart
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text("Balance Trend",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 200,
                          child: _BalanceTrendChart(transactions: provider.transactions),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (idx) {
            if (idx == 0) {
                Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (c,a,s) => const HomeScreen()));
            } else if (idx == 1) {
                Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (c,a,s) => const HistoryScreen()));
            }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.pie_chart), label: 'Stats'),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: color)),
            const SizedBox(height: 4),
            Text(
              '₹${amount.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceTrendChart extends StatelessWidget {
  final List<TransactionModel> transactions;

  const _BalanceTrendChart({required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(child: Text('No data'));
    }

    final sortedTx = List<TransactionModel>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    final Map<String, double> dailyChanges = {};
    for (var tx in sortedTx) {
      final dateKey = DateFormat('yyyy-MM-dd').format(tx.date);
      dailyChanges[dateKey] = (dailyChanges[dateKey] ?? 0) + tx.amount;
    }

    List<FlSpot> spots = [];
    double currentBalance = 0;
    
    final sortedDates = dailyChanges.keys.toList()..sort();
    
    for (int i = 0; i < sortedDates.length; i++) {
        final dateKey = sortedDates[i];
        currentBalance += dailyChanges[dateKey]!;
        spots.add(FlSpot(i.toDouble(), currentBalance));
    }
    
    if (spots.isEmpty) return const Center(child: Text('No data points'));

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index < 0 || index >= sortedDates.length) return const SizedBox();
                
                if (index == 0 || index == sortedDates.length - 1 || index == (sortedDates.length / 2).round()) {
                     final date = DateTime.parse(sortedDates[index]);
                     return Padding(
                         padding: const EdgeInsets.only(top: 8.0),
                         child: Text(DateFormat('MM/dd').format(date), style: const TextStyle(fontSize: 10)),
                     );
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
