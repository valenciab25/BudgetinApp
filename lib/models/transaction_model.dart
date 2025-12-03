class TransactionModel {
  final int? id;
  final String category;
  final double amount;
  final String date; // yyyy-MM-dd
  final String note;
  final String type; // 'income' or 'spend'

  TransactionModel({
    this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.note,
    required this.type,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type,
    'category': category,
    'amount': amount,
    'date': date,
    'note': note,
  };

  factory TransactionModel.fromMap(Map<String, dynamic> m) => TransactionModel(
    id: m['id'] as int?,
    category: m['category'] as String,
    amount: (m['amount'] as num).toDouble(),
    date: m['date'] as String,
    note: m['note'] as String? ?? '',
    type: m['type'] as String,
  );
}
