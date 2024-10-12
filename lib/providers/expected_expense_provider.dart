import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:money_app_new/models/expexted_expense.dart';

class ExpectedExpenseProvider with ChangeNotifier {
  ExpectedExpenseResponse? _expectedExpenseResponse;

  ExpectedExpenseResponse? get expectedExpenseResponse =>
      _expectedExpenseResponse;
  var storage = const FlutterSecureStorage();

  Future<void> fetchExpectedExpense() async {
    final baseUrl = dotenv.env['BASE_URL'];
    final token = await storage.read(key: 'token');
    final response = await http.get(
      Uri.parse('$baseUrl/expected-expence'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode <= 300) {
      final jsonData = jsonDecode(response.body);
      _expectedExpenseResponse = ExpectedExpenseResponse.fromJson(jsonData);
      notifyListeners();
    } else {
      throw Exception('Failed to load expected expense');
    }
  }
}
