import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:home_widget/home_widget.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_item.dart';
import '../widgets/add_transaction_modal.dart';
import '../widgets/quick_add_transaction_modal.dart';
import '../services/widget_service.dart';

import 'history_screen.dart';
import 'stats_screen.dart';
import 'backup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  final WidgetService _widgetService = WidgetService();

  @override
  void initState() {
    super.initState();

    // Reduced animation duration for better performance
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    // Defer heavy operations to after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
      _listenToWidgetClicks();
      // Defer widget update to avoid blocking UI
      Future.microtask(() => _updateHomeWidget());
    });
    WidgetsBinding.instance.addObserver(this);
  }



  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload from storage first (to get widget/volume gesture transactions)
      // then sync with API
      if (kDebugMode) {
        print('[HomeScreen] App resumed - reloading transactions');
      }
      Provider.of<TransactionProvider>(context, listen: false).loadInitialData();
    }
  }



  void _listenToWidgetClicks() {
    HomeWidget.widgetClicked.listen((uri) {
      if (uri != null) {
        if (uri.host == 'addtransaction') {
          _openAddTransactionModal();
        } else if (uri.host == 'quickadd') {
          final type = uri.queryParameters['type'];
          _openQuickAddModal(type);
        }
      }
    });
  }

  void _openAddTransactionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTransactionModal(),
    ).then((_) => _updateHomeWidget());
  }

  void _openQuickAddModal(String? type) {
    if (type == null) {
      _openAddTransactionModal();
      return;
    }
    
    final isIncome = type == 'income';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickAddTransactionModal(isIncome: isIncome),
    ).then((_) => _updateHomeWidget());
  }

  Future<void> _updateHomeWidget() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    await _widgetService.updateWidget(
      balance: provider.currentBalance,
      transactionCount: provider.transactions.length,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Consumer<TransactionProvider>(
            builder: (context, provider, child) {
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 120,
                    pinned: true,
                    backgroundColor: const Color(0xFF6366f1),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF6366f1),
                              Color(0xFF4f46e5),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '₹',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Finance Tracker',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      titlePadding:
                      const EdgeInsets.only(left: 16, bottom: 16),
                    ),
                    actions: [
                      // Sync status indicator
                      if (provider.syncStatus != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (provider.isSyncing)
                                    const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                  if (provider.isSyncing) const SizedBox(width: 8),
                                  Text(
                                    provider.syncStatus!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: () => provider.fetchTransactions(),
                      ),
                    ],
                  ),

                  /// CONTENT
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          /// BALANCE CARD
                          Card(
                            color: const Color(0xFF334155),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Current Balance',
                                    style: TextStyle(
                                      color: Colors.white
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  /// Animated balance
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(
                                      begin: 0,
                                      end: provider.currentBalance,
                                    ),
                                    duration:
                                    const Duration(milliseconds: 600),
                                    builder: (context, value, _) {
                                      return Text(
                                        '₹${value.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      _trend(
                                        'Income',
                                        provider.transactions
                                            .where((t) => t.amount > 0)
                                            .fold(
                                            0.0,
                                                (sum, t) =>
                                            sum + t.amount),
                                        const Color(0xFF10b981),
                                      ),
                                      const SizedBox(width: 24),
                                      _trend(
                                        'Expenses',
                                        provider.transactions
                                            .where((t) => t.amount < 0)
                                            .fold(
                                            0.0,
                                                (sum, t) =>
                                            sum + t.amount.abs()),
                                        const Color(0xFFef4444),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          /// ADD BUTTON
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF6366f1),
                              padding:
                              const EdgeInsets.symmetric(vertical: 16),
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text('New Transaction'),
                            onPressed: _openAddTransactionModal,
                          ),

                          const SizedBox(height: 12),

                          /// SHAKE HINT
                          Center(

                          ),

                          const SizedBox(height: 32),

                          /// HEADER
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Recent Transactions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const HistoryScreen(),
                                    ),
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

                  /// LIST
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: provider.isLoading
                        ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: LoadingListAnimator(),
                      ),
                    )
                        : provider.transactions.isEmpty
                        ? SliverToBoxAdapter(
                      child: _emptyState(),
                    )
                        : SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final tx = provider.transactions[index];
                          // Simplified animation - no staggered delays
                          return _dismissible(context, tx, provider);
                        },
                        childCount:
                        provider.transactions.take(5).length,
                      ),
                    ),
                  ),


                  const SliverToBoxAdapter(
                      child: SizedBox(height: 100)),
                ],
              );
            },
          ),
        ),
      ),

      /// NAV BAR
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (idx) {
          if (idx == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const HistoryScreen()),
            );
          } else if (idx == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const StatsScreen()),
            );
          } else if (idx == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const BackupScreen()),
            );
          }
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.history_outlined), label: 'History'),
          NavigationDestination(
              icon: Icon(Icons.pie_chart_outline), label: 'Stats'),
          NavigationDestination(
              icon: Icon(Icons.cloud_outlined), label: 'Backup'),
        ],
      ),
    );
  }

  Widget _trend(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54)),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style:
          TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.95 + value * 0.05,
            child: child,
          ),
        );
      },
      child: const Padding(
        padding: EdgeInsets.all(48),
        child: Center(
          child: Text(
            '📊 No transactions yet',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  }

  Widget _dismissible(BuildContext context, TransactionModel tx,
      TransactionProvider provider) {
    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFef4444),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child:
        const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => provider.deleteTransaction(tx.id),
      child: TransactionItem(transaction: tx),
    );
  }
}
class LoadingListAnimator extends StatelessWidget {
  const LoadingListAnimator({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFF334155).withOpacity(0.6),
            borderRadius: BorderRadius.circular(14),
          ),
        );
      }),
    );
  }
}
