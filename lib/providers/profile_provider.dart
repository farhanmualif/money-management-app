import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:money_app_new/models/profile.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfileProvider with ChangeNotifier {
  Profile? _profile;
  bool _isLoading = false;
  String? _error;

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();

    var storage = const FlutterSecureStorage();

    try {
      final baseUrl = dotenv.env['BASE_URL'];
      final token = await storage.read(key: 'token');

      if (baseUrl == null) {
        throw Exception('BASE_URL not found in .env file');
      }

      final url = Uri.parse('$baseUrl/profile');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 300) {
        throw Exception(
            'Failed to load profile. Status: ${response.statusCode}');
      }

      final jsonData = jsonDecode(response.body);

      if (jsonData['status']) {
        _profile = Profile.fromJson(jsonData['data']);
      } else {
        throw Exception('Failed to load profile: ${jsonData['message']}');
      }
    } catch (e) {
      _error = e.toString();
      print('Error fetching profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners when loading is done
    }
  }

  Future<void> updateProfile({required Profile updatedProfile}) async {
    _isLoading = true;
    notifyListeners(); // Notify listeners when loading starts

    var storage = const FlutterSecureStorage();

    try {
      final baseUrl = dotenv.env['BASE_URL'];
      final token = await storage.read(key: 'token');

      if (baseUrl == null) {
        throw Exception('BASE_URL not found in .env file');
      }

      final url = Uri.parse('$baseUrl/profile/${updatedProfile.id}');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'email': updatedProfile.email,
          'phoneNumber': updatedProfile.phoneNumber,
          'firstName': updatedProfile.firstName,
          'lastName': updatedProfile.lastName,
        }),
      );

      if (response.statusCode >= 300) {
        throw Exception(
            'Failed to update profile. Status: ${response.statusCode}');
      }

      final jsonData = jsonDecode(response.body);

      if (jsonData['status']) {
        _profile = Profile.fromJson(jsonData['data']);
        notifyListeners();
      } else {
        throw Exception('Failed to update profile: ${jsonData['message']}');
      }
    } catch (e) {
      _error = e.toString();
      print('Error updating profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners when loading is done
    }
  }
}
