import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:money_app_new/models/expected_income.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ExpectedIncomeProvider with ChangeNotifier {
  ExpectedIncome? _expectedIncome;
  bool _isLoading = false;
  String? _error;

  ExpectedIncome? get expectedIncome => _expectedIncome;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchExpectedIncome() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    var storage = const FlutterSecureStorage();

    try {
      final baseUrl = dotenv.env['BASE_URL'];
      final token = await storage.read(key: 'token');

      if (baseUrl == null) {
        throw Exception('BASE_URL not found in .env file');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/expected-income'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 300) {
        throw Exception(
            'Failed to load expected income. Status: ${response.statusCode}');
      }

      final jsonData = jsonDecode(response.body);

      if (jsonData['status']) {
        _expectedIncome = ExpectedIncomeResponse.fromJson(jsonData).data;
      } else {
        throw Exception(
            'Failed to load expected income: ${jsonData['message']}');
      }
    } catch (e) {
      print('Error fetching expected income: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
