class ExpectedExpenseResponse {
  bool status;
  String message;
  ExpectedExpenseData data;

  ExpectedExpenseResponse(
      {required this.status, required this.message, required this.data});

  factory ExpectedExpenseResponse.fromJson(Map<String, dynamic> json) {
    return ExpectedExpenseResponse(
      status: json['status'],
      message: json['message'],
      data: ExpectedExpenseData.fromJson(json['data']),
    );
  }
}

class ExpectedExpenseData {
  String accountId;
  int? expectedExpense;

  ExpectedExpenseData({required this.accountId, required this.expectedExpense});

  factory ExpectedExpenseData.fromJson(Map<String, dynamic> json) {
    return ExpectedExpenseData(
      accountId: json['accountId'],
      expectedExpense: json['expectedExpence'] ,
    );
  }
}
