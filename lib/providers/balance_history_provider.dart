import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:money_app_new/models/balance_history.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BalanceHistoryProvider with ChangeNotifier {
  List<BalanceHistory> _balanceHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BalanceHistory> get balanceHistory => _balanceHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchBalanceHistory() async {
    _isLoading = true;
    notifyListeners(); // Notify listeners when loading starts

    var storage = const FlutterSecureStorage();

    try {
      final baseUrl = dotenv.env['BASE_URL'];
      final token = await storage.read(key: 'token');

      if (baseUrl == null) {
        throw Exception('BASE_URL not found in .env file');
      }

      final url = Uri.parse('$baseUrl/balance-history');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final jsonData = jsonDecode(response.body);

      if (response.statusCode >= 300) {
        throw Exception(
            'Failed to load balance history. Status: ${response.statusCode}');
      }

      if (jsonData['status']) {
        _balanceHistory = (jsonData['data'] as List)
            .map((json) => BalanceHistory.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Failed to load balance history: ${jsonData['message']}');
      }
    } catch (e) {
      print('Error fetching balance history: $e');
      // You might want to set an error state here
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners when loading is done
    }
  }
}
