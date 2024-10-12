class Goal {
  final String id;
  final String name;
  final String description;
  final String? accountId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Goal({
    required this.id,
    required this.name,
    required this.description,
    this.accountId,
    this.createdAt,
    this.updatedAt,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      accountId: json['accountId'] ?? "",
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:json['updatedAt'] != null ?  DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'accountId': accountId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
