import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:money_app_new/models/profile.dart';

class SignupProvider with ChangeNotifier {
  Profile? _profile;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  setLoading(bool condition) {
    _isLoading = condition;
    notifyListeners();
  }

  Profile? get profile => _profile;
  var storage = const FlutterSecureStorage();

  Future<void> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required int totalBalance,
    required int totalIncome,
    required int totalExpenses,
  }) async {
    try {
      setLoading(true);
      final baseUrl = dotenv.env['BASE_URL'];
      final body = {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'total_balance': 0,
        'total_income': 0,
        'total_expenses': 0,
      };

      print("pre signup $body");

      final response = await http.post(
        Uri.parse('$baseUrl/account/signup'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print("response register: ${response.body}");

      final jsonData = jsonDecode(response.body);
      if (response.statusCode <= 300) {
      } else {
        throw Exception(jsonData['message']);
      }
    } catch (e) {
      throw Exception(e);
    } finally {
      setLoading(false);
    }
  }
}
