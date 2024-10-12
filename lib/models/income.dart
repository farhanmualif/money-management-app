// income.dart

class Income {
  String id;
  String name;
  int amount;
  DateTime date;
  bool isRecurring;
  bool isEarned;
  String frequency;
  String accountId;

  Income({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.isRecurring,
    required this.isEarned,
    required this.frequency,
    required this.accountId,
  });

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'],
      name: json['name'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      isRecurring: json['isRecurring'],
      isEarned: json['isEarned'],
      frequency: json['frequency'],
      accountId: json['account_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'date': date.toIso8601String(),
      'isRecurring': isRecurring,
      'frequency': frequency,
      'account_id': accountId,
    };
  }
}