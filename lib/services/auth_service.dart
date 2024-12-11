import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../env.dart';

class AuthService {
  static const String _baseUrl = '$siteUrl/wp-json/jwt-auth/v1';
  static const String _customBaseUrl = '$siteUrl/wp-json/custom/v1';
  static const String _tokenKey = 'auth_token';
  static const String _userBaseUrl = '$siteUrl/wp-json/custom/v1/user';

  static Future<void> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/token'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    print(response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String token = data['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);

      print('Login successful: $token');
    } else {
      throw Exception('Failed to login');
    }
  }

  static Future<void> register(String username, String email, String password,
      String firstName, String lastName, String phoneNumber) async {
    final response = await http.post(
      Uri.parse('$_customBaseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'phone number': phoneNumber,
      }),
    );

    if (response.statusCode == 200) {
      print('Registration successful');
      login(username, password);
    } else {
      final data = jsonDecode(response.body);
      print(data['message']);
      throw Exception(data['message']);
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<Map<String, dynamic>> fetchUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_tokenKey);

    // print(prefs.getString(_tokenKey));

    // if (token == null) {
    //   throw Exception('Please login first');
    // }

    final response = await http.post(
      Uri.parse('$_baseUrl/token/validate'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseUser = await http.get(
        Uri.parse('$_userBaseUrl'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (responseUser.statusCode == 200) {
        return json.decode(responseUser.body);
      } else {
        throw Exception('Failed to fetch user info');
      }
    } else {
      throw Exception('Token validation failed');
    }
  }

  // is logged in
  static Future<bool> isLoggedIn() async {
    String? token = await getToken();
    return token != null;
  }
}
