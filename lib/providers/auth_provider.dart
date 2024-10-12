import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:money_app_new/models/account.dart';
import 'package:money_app_new/models/api_response.dart';
import 'package:money_app_new/models/authenticated.dart';
import 'package:money_app_new/models/login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  ApiResponse<Login>? _loginResponse;
  ApiResponse<Authenticated>? _authResponse;
  ApiResponse? _logoutResponse;
  bool _isLoading = false;
  String? _message;
  int? _statusCode;

  ApiResponse<Login>? get loginResponse => _loginResponse;
  ApiResponse<Authenticated>? get authResponse => _authResponse;
  ApiResponse? get logoutResponse => _logoutResponse;
  bool get isLoading => _isLoading;
  String? get message => _message;
  int? get statusCode => _statusCode; 

  final _storage = const FlutterSecureStorage();
  final String _baseUrl = dotenv.env['BASE_URL'] ?? '';

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setMessage(String msg) {
    _message = msg;
    notifyListeners();
  }

  void _setStatusCode(int code) {
    _statusCode = code;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/account/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final jsonData = jsonDecode(response.body);
      _loginResponse = ApiResponse.fromJson(jsonData, Login.fromJson);
      _setMessage(jsonData['message']);
    } catch (e) {
      _setMessage('An error occurred: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp(Accounts account, String password) async {
    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/account/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': account.email,
          'password': password,
          'phone_number': account.phoneNumber,
          'first_name': account.firstName,
          'last_name': account.lastName,
          "total_balance": 50,
          "total_income": 50,
          "total_expenses": 50
        }),
      );

      final jsonData = jsonDecode(response.body);
      _setStatusCode(response.statusCode);
      _setMessage(jsonData['message']);
    } catch (e) {
      _setMessage('An error occurred: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> authenticated() async {
    try {
      String? token = await _storage.read(key: 'token');

      final response = await http.post(
        Uri.parse('$_baseUrl/account/authenticated'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("response auth: ${response.body}");

      final jsonData = jsonDecode(response.body);
      _authResponse = ApiResponse.fromJson(jsonData, Authenticated.fromJson);
      notifyListeners();
    } catch (e) {
      _setMessage('Authentication failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      String? token = await _storage.read(key: 'token');
      final response = await http.post(
        Uri.parse('$_baseUrl/account/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode < 300) {
        await _storage.delete(key: 'token');
        final logoutResponse = jsonDecode(response.body);
        _logoutResponse = ApiResponse.fromJson(logoutResponse, null);
        notifyListeners();
      } else {
        throw Exception('Failed to logout');
      }
    } catch (e) {
      _setMessage('Logout failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
}
