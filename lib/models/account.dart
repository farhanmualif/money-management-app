class Accounts {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Accounts({
    required this.id,
    required this.email,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    this.createdAt,
    this.updatedAt,
  });

  factory Accounts.fromJson(Map<String, dynamic> json) {
    return Accounts(
      id: json['id'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      firstName: json['firstName'] ?? "",
      lastName: json['lastName'] ?? "",
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
