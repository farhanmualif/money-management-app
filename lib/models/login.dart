class Login {
  final String id;
  final String token;
  final String accountId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiresAt;

  Login({
    required this.id,
    required this.token,
    required this.accountId,
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
  });

  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(
      id: json['id'],
      token: json['token'],
      accountId: json['accountId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'token': token,
      'accountId': accountId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }
}
