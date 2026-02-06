import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import 'home_screen.dart';
import 'history_screen.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with TickerProviderStateMixin {
  late AnimationController _pieController;
  late AnimationController _lineController;

  @override
  void initState() {
    super.initState();
    _pieController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _lineController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    // Start animations
    _pieController.forward();
    _lineController.forward();
  }

  @override
  void dispose() {
    _pieController.dispose();
    _lineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            if (provider.transactions.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('Not enough data for stats')),
              );
            }

            final income = provider.transactions
                .where((t) => t.amount > 0)
                .fold(0.0, (sum, t) => sum + t.amount);
            final expense = provider.transactions
                .where((t) => t.amount < 0)
                .fold(0.0, (sum, t) => sum + t.amount.abs());

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Metric Cards
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        title: 'Income',
                        amount: income,
                        color: const Color(0xFF10b981),
                        icon: '↗️',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _MetricCard(
                        title: 'Expense',
                        amount: expense,
                        color: const Color(0xFFef4444),
                        icon: '↙️',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Pie Chart Card
                Card(
                  color: const Color(0xFF1e293b),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text(
                          "Income vs Expense",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 220,
                          child: AnimatedPieChart(
                            income: income,
                            expense: expense,
                            controller: _pieController,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Line Graph Card
                Card(
                  color: const Color(0xFF1e293b),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text(
                          "Balance Trend",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 200,
                          child: AnimatedBalanceChart(
                            transactions: provider.transactions,
                            controller: _lineController,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (idx) {
          if (idx == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          } else if (idx == 1) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.history_outlined), label: 'History'),
          NavigationDestination(icon: Icon(Icons.pie_chart_outline), label: 'Stats'),
        ],
      ),
    );
  }
}

/// Metric Card
class _MetricCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final String icon;

  const _MetricCard({required this.title, required this.amount, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF334155),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
            const SizedBox(height: 8),
            Text('₹${amount.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
          ],
        ),
      ),
    );
  }
}

/// Animated Pie Chart
class AnimatedPieChart extends StatelessWidget {
  final double income;
  final double expense;
  final AnimationController controller;

  const AnimatedPieChart({
    required this.income,
    required this.expense,
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final total = income + expense;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double incomePercent = (controller.value <= 0.5 ? controller.value / 0.5 : 1);
        double expensePercent = (controller.value <= 0.5 ? 0 : (controller.value - 0.5) / 0.5);

        return PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(
                value: income * incomePercent,
                color: const Color(0xFF10b981),
                title: '${((income / total) * incomePercent * 100).toStringAsFixed(0)}%',
                radius: 60,
                titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              PieChartSectionData(
                value: expense * expensePercent,
                color: const Color(0xFFef4444),
                title: '${((expense / total) * expensePercent * 100).toStringAsFixed(0)}%',
                radius: 60,
                titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
            sectionsSpace: 4,
            centerSpaceRadius: 50,
          ),
        );
      },
    );
  }
}

/// Animated Balance Line Chart (progressive draw)
class AnimatedBalanceChart extends StatelessWidget {
  final List<TransactionModel> transactions;
  final AnimationController controller;

  const AnimatedBalanceChart({required this.transactions, required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) return const Center(child: Text('No data'));

    final sortedTx = List<TransactionModel>.from(transactions)..sort((a, b) => a.date.compareTo(b.date));
    final Map<String, double> dailyChanges = {};
    for (var tx in sortedTx) {
      final key = DateFormat('yyyy-MM-dd').format(tx.date);
      dailyChanges[key] = (dailyChanges[key] ?? 0) + tx.amount;
    }

    final dates = dailyChanges.keys.toList()..sort();
    final fullSpots = <FlSpot>[];
    double balance = 0;
    for (int i = 0; i < dates.length; i++) {
      balance += dailyChanges[dates[i]]!;
      fullSpots.add(FlSpot(i.toDouble(), balance));
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        int maxIndex = (controller.value * fullSpots.length).clamp(0, fullSpots.length.toDouble()).toInt();
        final animatedSpots = fullSpots.take(maxIndex).toList();

        return LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, meta) {
                    int i = v.toInt();
                    if (i < 0 || i >= dates.length) return const SizedBox();
                    if (i == 0 || i == dates.length - 1 || i == (dates.length / 2).round()) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          DateFormat('MM/dd').format(DateTime.parse(dates[i])),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: animatedSpots,
                isCurved: true,
                barWidth: 3,
                color: Theme.of(context).colorScheme.primary,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
