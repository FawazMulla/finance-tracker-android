import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.amount > 0;
    final color = isIncome ? Colors.green : Colors.red;
    final dateStr = DateFormat('MMM d, y').format(transaction.date);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isIncome ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
          ),
        ),
        title: Text(
          transaction.note.isNotEmpty ? transaction.note : 'No description',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(dateStr),
        trailing: Text(
          '${isIncome ? '+' : ''}₹${transaction.amount.abs().toStringAsFixed(0)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
