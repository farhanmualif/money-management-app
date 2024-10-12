class Transaction {
  final String id;
  final String accountId;
  final String name;
  final int amount;
  final String paymentMethod;
  final String date;
  final String frequency;
  final bool isRequring;

  Transaction({
    required this.id,
    required this.accountId,
    required this.name,
    required this.amount,
    required this.paymentMethod,
    required this.date,
    required this.frequency,
    required this.isRequring,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      accountId: json['accountId'],
      name: json['name'],
      amount: json['amount'],
      paymentMethod: json['paymentMethod'],
      date: json['date'],
      frequency: json['frequency'],
      isRequring: json['isRequring'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'name': name,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'date': date, // Assuming date is already a string
      'frequency': frequency,
      'isRequring': isRequring,
    };
  }
}
