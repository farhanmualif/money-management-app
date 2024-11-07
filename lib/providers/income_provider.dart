import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:money_app_new/models/income.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class IncomeProvider with ChangeNotifier {
  List<Income>? _incomes;
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _error;

  List<Income>? get incomes => _incomes;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get error => _error;

  void setError(String? msg) {
    _error = msg;
  }

  final _storage = const FlutterSecureStorage();

  Future<void> fetchIncomes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final baseUrl = dotenv.env['BASE_URL'];
      final token = await _storage.read(key: 'token');

      if (baseUrl == null) {
        throw Exception('BASE_URL not found in .env file');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/income'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 300) {
        throw Exception(
            'Failed to load incomes. Status: ${response.statusCode}');
      }

      final jsonData = jsonDecode(response.body);

      if (jsonData['status']) {
        _incomes =
            (jsonData['data'] as List).map((e) => Income.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load incomes: ${jsonData['message']}');
      }
    } catch (e) {
      _error = e.toString();
      print('Error fetching incomes: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners when loading is done
    }
  }

  Future<void> update(Income incomeResource) async {
    _isUpdating = true;
    notifyListeners(); // Notify listeners when loading starts

    try {
      final baseUrl = dotenv.env['BASE_URL'];
      final token = await _storage.read(key: 'token');

      final response = await http.put(
        Uri.parse('$baseUrl/income/${incomeResource.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(incomeResource.toJson()),
      );

      if (response.statusCode >= 300) {
        throw Exception(
            'Failed to update income. Status: ${response.statusCode}');
      }

      await fetchIncomes();
    } catch (e) {
      _error = e.toString();
      print('Error updating income: $e');
    } finally {
      _isUpdating = false;
      notifyListeners(); // Notify listeners when loading is done
    }
  }

  Future<void> earned(BuildContext context, String id) async {
    try {
      setError(null);
      final baseUrl = dotenv.env['BASE_URL'];
      final token = await _storage.read(key: 'token');

      final response = await http.post(
        Uri.parse('$baseUrl/income/$id/earned'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var jsonBody = jsonDecode(response.body);

      if (response.statusCode >= 300) {
        _error = jsonBody['message'];
      }

      await fetchIncomes();
    } catch (e) {
      _handleError('Error marking income as earned', e);
    }
  }

  Future<void> addIncome(Income income) async {
    try {
      final baseUrl = dotenv.env['BASE_URL'];
      final token = await _storage.read(key: 'token');

      if (baseUrl == null) {
        throw Exception('BASE_URL not found in .env file');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/income'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(income.toJson()),
      );

      if (response.statusCode >= 300) {
        throw Exception('Failed to add income');
      }

      await fetchIncomes();
    } catch (e) {
      _handleError('Error adding income', e);
    }
  }

  Future<void> deleteIncome(String id) async {
    try {
      final baseUrl = dotenv.env['BASE_URL'];
      final token = await _storage.read(key: 'token');

      if (baseUrl == null) {
        throw Exception('BASE_URL not found in .env file');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/income/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 300) {
        throw Exception('Failed to delete income');
      }

      await fetchIncomes();
    } catch (e) {
      _handleError('Error deleting income', e);
    }
  }

  void _handleError(String message, dynamic error) {
    print('$message: $error');
    _error = error.toString();
  }
}
