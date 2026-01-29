import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class AddTransactionModal extends StatefulWidget {
  const AddTransactionModal({super.key});

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isIncome = false; // Default to Expense as per original UI logic often

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

    final finalAmount = _isIncome ? amountVal : -amountVal;
    final note = _noteController.text.trim();

    Provider.of<TransactionProvider>(context, listen: false)
        .addTransaction(finalAmount, note);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Add Transaction',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Expense'), icon: Icon(Icons.arrow_downward)),
                    ButtonSegment(value: true, label: Text('Income'), icon: Icon(Icons.arrow_upward)),
                  ],
                  selected: {_isIncome},
                  onSelectionChanged: (Set<bool> newSelection) {
                    setState(() {
                      _isIncome = newSelection.first;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount (₹)',
              border: OutlineInputBorder(),
              prefixText: '₹ ',
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: "What's this for?",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submit,
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('Save Transaction'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
