import 'package:money_app_new/models/account.dart';

class Authenticated {
  final String id;
  final String token;
  final String accountId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiresAt;
  final Accounts accounts;

  Authenticated({
    required this.id,
    required this.token,
    required this.accountId,
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
    required this.accounts,
  });

  factory Authenticated.fromJson(Map<String, dynamic> json) {
    return Authenticated(
      id: json['id'],
      token: json['token'],
      accountId: json['accountId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      accounts: Accounts.fromJson(json['Accounts']),
    );
  }
}
