class UpcomingExpense {
  final String id;
  final String name;
  final String date;
  final int amount;
  final bool isRequring;
  final String frequency;
  final String paymentMethod;
  final String accountId;
  final String createdAt;
  final String updatedAt;

  UpcomingExpense({
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

  factory UpcomingExpense.fromJson(Map<String, dynamic> json) {
    return UpcomingExpense(
      id: json['id'],
      name: json['name'],
      date: json['date'],
      amount: json['amount'],
      isRequring: json['isRequring'],
      frequency: json['frequency'],
      paymentMethod: json['paymentMethod'],
      accountId: json['accountId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'amount': amount,
      'isRequiring': isRequring,
      'frequency': frequency,
      'paymentMethod': paymentMethod,
      'accountId': accountId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
