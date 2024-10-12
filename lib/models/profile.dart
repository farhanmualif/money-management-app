class Profile {
  final String id;
  final String firstName;
  final String lastName;
  final int totalBalance;
  final int totalIncome;
  final int totalExpenses;
  final String? description;
  final String createdAt;
  final String updatedAt;
  final String accountId;
  final String email;
  final String phoneNumber;

  Profile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpenses,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.accountId,
    required this.email,
    required this.phoneNumber,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      totalBalance: json['totalBalance'],
      totalIncome: json['totalIncome'],
      totalExpenses: json['totalExpenses'],
      description: json['description'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      accountId: json['accountId'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
    );
  }
}
