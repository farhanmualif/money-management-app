class Transaction {
  final String id;
  final String name;
  final double amount;
  final DateTime date;
  final String type;
  final bool isEarned;

  Transaction({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.type,
    required this.isEarned,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'].toString(),
      name: json['name'],
      amount: double.parse(json['amount'].toString()),
      date: DateTime.parse(json['date']),
      type: json['type'] ?? '',
      isEarned: json['isEarned'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type,
      'isEarned': isEarned,
    };
  }
}
