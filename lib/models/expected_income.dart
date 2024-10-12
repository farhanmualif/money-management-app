class ExpectedIncome {
  final String accountId;
  final int expectedIncome;

  ExpectedIncome({required this.accountId, required this.expectedIncome});

  factory ExpectedIncome.fromJson(Map<String, dynamic> json) {
    return ExpectedIncome(
      accountId: json['accountId'],
      expectedIncome: json['expectedIncome'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'expectedIncome': expectedIncome,
    };
  }
}

class ExpectedIncomeResponse {
  final bool status;
  final String message;
  final ExpectedIncome data;

  ExpectedIncomeResponse({required this.status, required this.message, required this.data});

  factory ExpectedIncomeResponse.fromJson(Map<String, dynamic> json) {
    return ExpectedIncomeResponse(
      status: json['status'],
      message: json['message'],
      data: ExpectedIncome.fromJson(json['data']),
    );
  }
}