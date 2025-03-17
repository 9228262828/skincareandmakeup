import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../env.dart';

class AuthService {
  static const String _baseUrl = '$siteUrl/wp-json/jwt-auth/v1';
  static const String _customBaseUrl = '$siteUrl/wp-json/custom/v1';
  static const String _tokenKey = 'auth_token';
  static const String _userId = 'user_id';
  static const String _userBaseUrl = '$siteUrl/wp-json/custom/v1/user';

  static Future<void> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('https://gomla.sa/wp-json/custom-auth/v1/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'email_or_phone': username,
        'password': password,
      },
    );

    print(response.body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        String token = data['data']['token'];
        int userId = data['data']['user_id'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        await prefs.setInt(_userId, userId);
        await prefs.setBool("isLoggedIn", true);

        print('Login successful: User ID - $userId');
        print('Login successful: Token - $token');
      } else {

        print('Login failed');
        throw Exception('Failed to login');
      }
    } else {
      print('Error: ${response.statusCode}');
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
    await prefs.clear(); // Removes all keys and values in SharedPreferences
  }

  static Future<Map<String, dynamic>>   fetchUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_tokenKey);

    print(prefs.getString(_tokenKey));

    if (token == null) {
      throw Exception('Please login first');
    }
    print(  Uri.parse('https://gomla.sa/wp-json/custom-auth/v1/profile'));
    final responseUser = await http.get(
      Uri.parse("https://gomla.sa/wp-json/custom-auth/v1/profile"),
      headers: {
        "gomla_autherization": 'Bearer $token',
      },
    );

    if (responseUser.statusCode == 200) {
      print('User info fetched');
      return json.decode(responseUser.body);
    } else {
      throw Exception('Failed to fetch user info');
    }
    print('Token validated');
  }

  // is logged in
  static Future<bool> isLoggedIn() async {
    String? token = await getToken();
    return token != null;
  }
}

///

