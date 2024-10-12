class ApiResponse<T> {
  bool status;
  String message;
  T? data;
  String? errorCode;
  String? errorMessage;

  ApiResponse({
    required this.status,
    required this.message,
    required this.data,
    this.errorCode,
    this.errorMessage,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    if (json['status']) {
      return ApiResponse(
        status: json['status'],
        message: json['message'],
        data: fromJson != null ? fromJson(json['data']) : null,
      );
    } else {
      return ApiResponse(
        status: json['status'],
        message: json['message'],
        data: null,
        errorCode: json['errorCode'],
        errorMessage: json['message'],
      );
    }
  }
}
