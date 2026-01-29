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
        title: const Text('History'),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.transactions.isEmpty) {
            return const Center(child: Text('No transactions yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.transactions.length,
            itemBuilder: (context, index) {
              final tx = provider.transactions[index];
              return Dismissible(
                key: Key(tx.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  provider.deleteTransaction(tx.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transaction deleted')),
                  );
                },
                child: TransactionItem(transaction: tx),
              );
            },
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (idx) {
            if (idx == 0) {
                Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (c,a,s) => const HomeScreen()));
            } else if (idx == 2) {
                Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (c,a,s) => const StatsScreen()));
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
