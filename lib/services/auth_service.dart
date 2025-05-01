import 'dart:convert';

import 'package:Gomla/shared/components/toast_component.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../env.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthService {
  static const String _baseUrl = '$siteUrl/wp-json/jwt-auth/v1';
  static const String _customBaseUrl = '$siteUrl/wp-json/custom/v1';
  static const String _tokenKey = 'auth_token';
  static const String _userId = 'user_id';
  static const String _userBaseUrl = '$siteUrl/wp-json/custom/v1/user';

  static Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('https://gomla.sa/wp-json/custom-auth/v1/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'email_or_phone': username,
        'password': password,
      },
    );

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

        return 'Login successful'; // Return success message
      } else {
        print(response.body);
        print('Login failed');
        return data['message'] ?? 'Failed to login'; // Return API error message without Exception
      }
    } else {
      print('Error: ${response.statusCode}');
      final data = json.decode(response.body);
      print(data['message']);
      throw (data['message']);
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

      throw (data['message']);
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userId);
      
    await prefs.remove("isLoggedIn");

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
        "gomlaauth": 'Bearer $token',
      },
    );

    if (responseUser.statusCode == 200) {
      print('User info fetched');
      return json.decode(responseUser.body);
    } else {
      print("${json.decode(responseUser.body)}");
      throw Exception('Failed to fetch user info');
    }
    print('Token validated');
  }

  // is logged in
  static Future<bool> isLoggedIn() async {
    String? token = await getToken();
    return token != null;
  }
  static Future<Map<String, dynamic>> updateUserProfile({
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token'); // Retrieve the auth token

      final response = await http.post(
        Uri.parse('https://gomla.sa/wp-json/custom-auth/v1/edit-profile'), // Endpoint for updating the profile
        headers: {
          'gomlaauth': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded', // Form-data encoding
        },
        body: {
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
        },
      );

      if (response.statusCode == 200) {
        // If successful, return the JSON response
        return json.decode(response.body);
      } else {
final errorResponse = json.decode(response.body);
print(errorResponse);
showToast(text: errorResponse['message'], state: ToastStates.ERROR);
throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
       throw Exception('Error updating profile: $e');
    }
  }
}

///

