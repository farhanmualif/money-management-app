// expense.dart

class Expense {
  String id;
  String name;
  DateTime date;
  int amount;
  bool isRequring;
  String frequency;
  String paymentMethod;
  String accountId;
  DateTime createdAt;
  DateTime updatedAt;

  Expense({
    required this.id,
    required this.name,
    required this.date,
    required this.amount,
    required this.isRequring,
    required this.frequency,
    required this.paymentMethod,
    required this.accountId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      date: DateTime.parse(json['date']),
      amount: json['amount'],
      isRequring: json['isRequring'],
      frequency: json['frequency'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      accountId: json['accountId'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'amount': amount,
      'isRequring': isRequring,
      'frequency': frequency,
      'paymentMethod': paymentMethod,
      'accountId': accountId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
