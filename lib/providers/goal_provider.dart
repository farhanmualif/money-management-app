import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:money_app_new/models/goal.dart';

class GoalProvider with ChangeNotifier {
  final String? baseUrl = dotenv.env['BASE_URL'];
  final storage = const FlutterSecureStorage();
  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _error;

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchGoals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await storage.read(key: 'token');
      final response = await http.get(
        Uri.parse('$baseUrl/goal'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _goals =
            (data['data'] as List).map((goal) => Goal.fromJson(goal)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        _error = errorData['message'] ?? 'Failed to fetch goals';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Goal?> addGoal(String name, String description) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await storage.read(key: 'token');
      final response = await http.post(
        Uri.parse('$baseUrl/goal'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
        }),
      );
      debugPrint('response create goal ${response.body}');

      if (response.statusCode == 201) {
        await fetchGoals(); // Refresh goals after adding
      } else {
        final errorData = jsonDecode(response.body);
        _error = errorData['message'] ?? 'Failed to add goal';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<void> updateGoal(Goal goal) async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await storage.read(key: 'token');
      final url = Uri.parse('$baseUrl/goal/${goal.id}');
      final response = await http.put(
        url,
        body: jsonEncode(goal.toJson()),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final jsonData = jsonDecode(response.body);

      notifyListeners();
      if (response.statusCode <= 300) {
        _error = jsonData['message'];
        notifyListeners();
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

  Future<void> deleteGoal(String id) async {
    try {
      final token = await storage.read(key: 'token');

      if (baseUrl == null) {
        throw Exception('BASE_URL not found in .env file');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/goal/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 300) {
        throw Exception('Failed to delete income');
      }

      await fetchGoals();
    } catch (e) {
      _error = 'Error deleting income $e';
    }
  }
}
