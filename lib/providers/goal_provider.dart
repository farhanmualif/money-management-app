import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:money_app_new/models/goal.dart';

class GoalProvider extends ChangeNotifier {
  List<Goal> _goals = [];
  String? error;
  bool _isLoading = false;

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;
  var storage = const FlutterSecureStorage();

  final String? _baseUrl = dotenv.env['BASE_URL'];
  // Store this securely

  Future<void> fetchGoals() async {
    final String? token = await storage.read(key: 'token');
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/goal'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode <= 300) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == true && jsonData['data'] != null) {
          _goals = (jsonData['data'] as List)
              .map((goalJson) => Goal.fromJson(goalJson))
              .toList();
        }
      } else {
        // Handle error
        print('Failed to load goals: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exception
      print('Exception when fetching goals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Goal?> addGoal(String name, String description) async {
    final String? token = await storage.read(key: 'token');
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/goal'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "name": name,
          "description": description,
        }),
      );

      if (response.statusCode == 201) {
        // Assuming 201 for successful creation
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == true && jsonData['data'] != null) {
          final newGoal = Goal.fromJson(jsonData['data']);
          _goals.add(newGoal);
          notifyListeners();
          return newGoal;
        }
      } else {
        // Handle error
        print('Failed to add goal: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exception
      print('Exception when adding goal: $e');
    }
    return null;
  }

  Future<void> updateGoal(Goal goal) async {
    _isLoading = true;
    notifyListeners();
    try {
      final baseUrl = dotenv.env['BASE_URL'];
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
        error = jsonData['message'];
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
      final baseUrl = dotenv.env['BASE_URL'];
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
      error = 'Error deleting income $e';
    }
  }

  // Add other methods as needed (e.g., updateGoal, deleteGoal)
}
