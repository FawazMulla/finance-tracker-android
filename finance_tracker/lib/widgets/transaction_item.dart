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
    final primaryColor = isIncome ? const Color(0xFF10b981) : const Color(0xFFef4444);
    final bgColor = isIncome ? const Color(0xFF064e3b) : const Color(0xFF7f1d1d);
    final dateStr = DateFormat('MMM d, y').format(transaction.date);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF334155).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: bgColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            isIncome ? '↗️' : '↙️',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        title: Text(
          transaction.note.isNotEmpty ? transaction.note : 'No description',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          dateStr,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        trailing: Text(
          '${isIncome ? '+' : ''}₹${transaction.amount.abs().toStringAsFixed(0)}',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
