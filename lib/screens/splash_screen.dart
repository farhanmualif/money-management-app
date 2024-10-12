import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:money_app_new/authentication/login_screen.dart';
import 'package:money_app_new/screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:money_app_new/themes/themes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final storage = const FlutterSecureStorage();

  Future<void> _checkAuthentication() async {
    final token = await storage.read(key: 'token');
    print("token: $token");

    if (token == null || token.isEmpty) {
      _navigateTo(const LoginScreen());
      return; // Exit early
    }

    final baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl == null) {
      _navigateTo(const LoginScreen());
      return; // Exit early
    }

    final url = Uri.parse('$baseUrl/account/authenticated');
    try {
      final response = await http.post(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode >= 300) {
        // Handle API error
        _navigateTo(const LoginScreen());
        return;
      }

      final jsonData = jsonDecode(response.body);
      if (jsonData['status'] == false) {
        _navigateTo(const LoginScreen());
        return;
      }

      _navigateTo(const HomeScreen());
    } catch (e) {
      // Handle general error
      print("Error: $e");
      _navigateTo(const LoginScreen());
    }
  }

// Helper function to handle navigation
  void _navigateTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
