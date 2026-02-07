import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class QuickAddTransactionModal extends StatefulWidget {
  final bool isIncome;
  
  const QuickAddTransactionModal({super.key, required this.isIncome});

  @override
  State<QuickAddTransactionModal> createState() => _QuickAddTransactionModalState();
}

class _QuickAddTransactionModalState extends State<QuickAddTransactionModal> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final amountText = _amountController.text;
    if (amountText.isEmpty) return;

    final amountVal = double.tryParse(amountText);
    if (amountVal == null || amountVal <= 0) return;

    final finalAmount = widget.isIncome ? amountVal : -amountVal;
    final note = _noteController.text.trim();

    Provider.of<TransactionProvider>(context, listen: false)
        .addTransaction(finalAmount, note);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1e293b),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.isIncome ? '↗️' : '↙️',
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              Text(
                'Quick ${widget.isIncome ? 'Income' : 'Expense'}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _amountController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixText: '₹ ',
              prefixStyle: TextStyle(
                color: widget.isIncome ? const Color(0xFF10b981) : const Color(0xFFef4444),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              filled: true,
              fillColor: const Color(0xFF0f172a).withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: widget.isIncome ? const Color(0xFF10b981) : const Color(0xFFef4444),
                  width: 2,
                ),
              ),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Description (Optional)',
              labelStyle: const TextStyle(color: Colors.white70),
              hintText: "What's this for?",
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true,
              fillColor: const Color(0xFF0f172a).withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: widget.isIncome ? const Color(0xFF10b981) : const Color(0xFFef4444),
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: widget.isIncome ? const Color(0xFF10b981) : const Color(0xFFef4444),
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _submit,
            child: Text(
              'Add ${widget.isIncome ? 'Income' : 'Expense'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
