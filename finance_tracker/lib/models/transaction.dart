class TransactionModel {
  final String id;
  final DateTime date;
  final double amount;
  final String note;

  final bool isSynced;

  TransactionModel({
    required this.id,
    required this.date,
    required this.amount,
    required this.note,
    this.isSynced = true,
  });

  // Factory to create from JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      note: json['note'] as String? ?? '',
      isSynced: json['isSynced'] as bool? ?? true,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amount': amount,
      'note': note,
      'isSynced': isSynced,
    };
  }
}
