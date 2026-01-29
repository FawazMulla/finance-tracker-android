import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_item.dart';
import '../widgets/add_transaction_modal.dart';
import 'history_screen.dart';
import 'stats_screen.dart'; // We will create this next

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  title: const Text('Finance Tracker'),
                  actions: [
                    IconButton(
                       icon: const Icon(Icons.refresh),
                       onPressed: () => provider.fetchTransactions(),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Balance Card
                        Card(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Text(
                                  'Current Balance',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '₹${provider.currentBalance.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                if (provider.isLoading)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Quick Actions
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                icon: const Icon(Icons.add),
                                label: const Text('Add Transaction'),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (_) => const AddTransactionModal(),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Recent Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Transactions',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                                );
                              },
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Transaction List (Top 5)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: provider.transactions.isEmpty
                      ? SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Center(
                              child: Text(
                                'No transactions yet',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey,
                                    ),
                              ),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
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
                                confirmDismiss: (direction) async {
                                  return await showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete Transaction?'),
                                      content: const Text('This cannot be undone.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(ctx).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(ctx).pop(true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onDismissed: (direction) {
                                  provider.deleteTransaction(tx.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Transaction deleted')),
                                  );
                                },
                                child: TransactionItem(transaction: tx),
                              );
                            },
                            childCount: provider.transactions.take(5).length,
                          ),
                        ),
                ),
                 SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (idx) {
            if (idx == 1) {
                Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (c,a,s) => const HistoryScreen()));
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
