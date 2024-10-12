// expense_provider.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:money_app_new/models/expense.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:money_app_new/providers/expected_expense_provider.dart';
import 'package:provider/provider.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = false;
  final _storage = const FlutterSecureStorage();

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  var storage = const FlutterSecureStorage();

  Future<void> fetchExpenses() async {
    _isLoading = true;
    notifyListeners();
    try {
      final baseUrl = dotenv.env['BASE_URL'];
      final token = await storage.read(key: 'token');
      final url = Uri.parse('$baseUrl/expence');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final jsonData = jsonDecode(response.body);
      if (response.statusCode <= 300) {
        final List<Expense> expenses = (jsonData['data'] as List)
            .map((expense) => Expense.fromJson(expense))
            .toList();
        _expenses = expenses;
        notifyListeners();
      } else {
        throw Exception('Failed to load expenses');
      }
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(Expense expense) async {
    _isLoading = true;
    notifyListeners();
    try {
      final baseUrl = dotenv.env['BASE_URL'];
      final token = await storage.read(key: 'token');
      final url = Uri.parse('$baseUrl/expence');
      final response = await http.post(
        url,
        body: jsonEncode({
          "name": expense.name,
          "amount": expense.amount,
          "date": expense.date.toIso8601String(),
          "payment_method": expense.paymentMethod,
          "isRequring": expense.isRequring,
          "frequency": expense.frequency
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final jsonData = jsonDecode(response.body);
      if (response.statusCode <= 300) {
        final Expense newExpense = Expense.fromJson(jsonData);
        _expenses.add(newExpense);
        notifyListeners();
      } else {
        _error = jsonData['messsage'];
        notifyListeners();
        throw Exception('Failed to add expense');
      }
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateExpense(Expense expense) async {
    _isLoading = true;
    notifyListeners();
    try {
      final baseUrl = dotenv.env['BASE_URL'];
      final token = await storage.read(key: 'token');
      final url = Uri.parse('$baseUrl/expence/${expense.id}');
      final response = await http.put(
        url,
        body: jsonEncode(expense.toJson()),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode <= 300) {
        final jsonData = jsonDecode(response.body);
        final updatedExpense = Expense.fromJson(jsonData['data']);
        final index =
            _expenses.indexWhere((element) => element.id == expense.id);
        if (index != -1) {
          _expenses[index] = updatedExpense;
          notifyListeners();
        }
      } else {
        throw Exception('Failed to update expense');
      }
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteExpense(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final baseUrl = dotenv.env['BASE_URL'];
      final token = await storage.read(key: 'token');
      final url = Uri.parse('$baseUrl/expence/$id');
      final response = await http.delete(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      var resBody = jsonDecode(response.body);

      if (response.statusCode <= 300) {
        final index = _expenses.indexWhere((element) => element.id == id);
        if (index != -1) {
          _expenses.removeAt(index);
          notifyListeners();
        }
      } else {
        _error = resBody['message'];
        throw Exception('Failed to delete expense');
      }
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> earned(BuildContext context, String id) async {
    try {
      final baseUrl = dotenv.env['BASE_URL'];
      final token = await _storage.read(key: 'token');

      final response = await http.post(
        Uri.parse('$baseUrl/expence/$id/earned'),
        headers: _headers(token),
      );

      var jsonBody = jsonDecode(response.body);

      if (response.statusCode >= 300) {
        _error = jsonBody['message'];
      }

      _handleResponse(response, _error ?? 'Failed to mark income as earned');

      await fetchExpenses();
      await Provider.of<ExpectedExpenseProvider>(context, listen: false)
          .fetchExpectedExpense();
    } catch (e) {
      _handleError('Error marking income as earned', e);
    }
  }

  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  void _handleResponse(http.Response response, String errorMessage) {
    if (response.statusCode >= 300) {
      throw Exception(errorMessage);
    }
  }

  void _handleError(String message, dynamic error) {
    _error = error.toString();
  }
}
