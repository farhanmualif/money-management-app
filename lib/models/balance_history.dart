class BalanceHistory {
  final String id;
  final String accountId;
  final int balance;
  final DateTime createdAt;
  final DateTime updatedAt;

  BalanceHistory({
    required this.id,
    required this.accountId,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BalanceHistory.fromJson(Map<String, dynamic> json) {
    return BalanceHistory(
      id: json['id'],
      accountId: json['accountId'],
      balance: json['balance'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}