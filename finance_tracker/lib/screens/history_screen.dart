import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_item.dart';
import 'home_screen.dart';
import 'stats_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📜', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: provider.transactions.length,
            itemBuilder: (context, index) {
              final tx = provider.transactions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Dismissible(
                  key: Key(tx.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFef4444),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFF1e293b),
                        title: const Text('Delete?'),
                        content: const Text('Remove this transaction record?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete', style: TextStyle(color: Color(0xFFef4444)))),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) {
                    provider.deleteTransaction(tx.id);
                  },
                  child: TransactionItem(transaction: tx),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF1e293b),
        indicatorColor: const Color(0xFF6366f1).withValues(alpha: 0.2),
        selectedIndex: 1,
        onDestinationSelected: (idx) {
          if (idx == 0) {
            Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (c, a, s) => const HomeScreen()));
          } else if (idx == 2) {
            Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (c, a, s) => const StatsScreen()));
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF6366f1)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: Color(0xFF6366f1)),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart, color: Color(0xFF6366f1)),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}
