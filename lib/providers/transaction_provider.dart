import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:money_app_new/models/transaction.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTransactions() async {
    _isLoading = true;
    notifyListeners();

    var storage = const FlutterSecureStorage();

    try {
      final baseUrl = dotenv.env['BASE_URL'];
      final token = await storage.read(key: 'token');

      if (baseUrl == null) {
        throw Exception('BASE_URL not found in .env file');
      }

      final url = Uri.parse('$baseUrl/transaction');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 300) {
        throw Exception(
            'Failed to load transactions. Status: ${response.statusCode}');
      }

      final jsonData = jsonDecode(response.body);

      if (jsonData['status']) {
        _transactions = (jsonData['data'] as List)
            .map((json) => Transaction.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load transactions: ${jsonData['message']}');
      }
    } catch (e) {
      _error = e.toString();
      print('Error fetching transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners when loading is done
    }
  }

  Future<void> refreshTransactions() async {
    _error = null;
    await fetchTransactions();
  }
}
