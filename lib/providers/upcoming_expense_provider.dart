import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:money_app_new/models/upcoming_expense.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UpcomingExpenseProvider with ChangeNotifier {
  List<UpcomingExpense> _upcomingExpenses = [];
  List<UpcomingExpense> get upcomingExpenses => _upcomingExpenses;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchUpcomingExpenses() async {
    _isLoading = true;
    notifyListeners(); // Notify listeners when loading starts

    var storage = const FlutterSecureStorage();

    try {
      final baseUrl = dotenv.env['BASE_URL'];
      final token = await storage.read(key: 'token');

      if (baseUrl == null) {
        throw Exception('BASE_URL not found in .env file');
      }

      final url = Uri.parse('$baseUrl/expence-upcoming');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 300) {
        throw Exception(
            'Failed to load upcoming expenses. Status: ${response.statusCode}');
      }

      final jsonData = jsonDecode(response.body);

      if (jsonData['status']) {
        _upcomingExpenses = (jsonData['data'] as List)
            .map((json) => UpcomingExpense.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Failed to load upcoming expenses: ${jsonData['message']}');
      }
    } catch (e) {
      print('Error fetching upcoming expenses: $e');
      // You might want to set an error state here
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners when loading is done
    }
  }
}
