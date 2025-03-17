import 'dart:convert';

import 'package:Gomla/screens/verifyphone_screen.dart';
import 'package:Gomla/shared/global/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../contstants.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../shared/utils/app_assets.dart';
import '../shared/utils/app_values.dart';
import '../widgets/app_bar.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController(); // Phone number controller
  final _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.passwordsDoNotMatch)),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Register user
        await AuthService.register(
          _usernameController.text,
          _emailController.text,
          _passwordController.text,
          _firstNameController.text,
          _lastNameController.text,
          _phoneController.text,
        );

        // Save user data to SharedPreferences after successful registration
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userEmail', _emailController.text);
        prefs.setString('userPhone', _phoneController.text);
        prefs.setString('userFirstName', _firstNameController.text);
        prefs.setString('userLastName', _lastNameController.text);
        prefs.setString('userPhoto', ''); // You can store the photo URL here if available

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainScreen()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }




  Future<void> _checkPhone() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Check if phone number is in valid format
      print("+966${_phoneController.text}");

      try {
        final response = await http.post(
          Uri.parse('https://gomla.sa/wp-json/custom-auth/v1/check-phone'),
          body: {
            'phone': "+966${_phoneController.text}" // Corrected line to send the phone as a string
          },
        );

        // Print the raw response body for inspection
        print('Response body: ${response.body}');

        // Check if the response is valid JSON or not
        if (response.statusCode == 200) {
          try {
            // Attempt to decode the response if it is in JSON format
            final Map<String, dynamic> data = json.decode(response.body);
            print('Decoded data: $data');

            if (data['success'] == true) {
              String otp = data['otp'].toString(); // حفظ OTP
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(data['message'] ?? 'تم التحقق من الهاتف')),
              );
              _otpController.text = otp;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VerifyPhoneScreen(
                    phone: _phoneController.text,
                    email: _emailController.text,
                    userName: _usernameController.text,
                    password: _passwordController.text,
                  ),
                ),
              );
            } else {
              print('Error response: ${response.body}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(data['message'] ?? 'فشل التحقق من الهاتف')),
              );
            }
          } catch (e) {
            // Catching FormatException or any other decoding issues
            print('Error decoding JSON: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error decoding response: $e')),
            );
          }
        } else {
          print('Error: Received status code ${response.statusCode}');
          print('Response body: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Phone verification failed with status: ${response.statusCode}')),
          );
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: mediaQueryHeight(context) * 0.06,
                ),
                Image.asset(ImageAssets.logoWhite,
                    height: mediaQueryHeight(context) * 0.15,
                    width: mediaQueryWidth(context) * 0.7),
                Text(AppLocalizations.of(context)!.registerAccount, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                SizedBox(
                  height: mediaQueryHeight(context) * 0.05,
                ),
                /*TextFormField(
                  controller: _firstNameController,
                  decoration: customInputDecoration(
                    context
                  , AppLocalizations.of(context)!.firstName, AppLocalizations.of(context)!.firstName),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!
                          .pleaseEnterYourFirstName;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _lastNameController,
                  decoration: customInputDecoration(
                      context
                      , AppLocalizations.of(context)!.lastName, AppLocalizations.of(context)!.lastName),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!
                          .pleaseEnterYourLastName;
                    }
                    return null;
                  },
                ),*/
                SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  decoration: customInputDecoration(
                      context
                      , AppLocalizations.of(context)!.userName, AppLocalizations.of(context)!.userName),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!
                          .pleaseEnterYourUsername;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: customInputDecoration(
                      context
                      , AppLocalizations.of(context)!.email, AppLocalizations.of(context)!.email),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.pleaseEnterYourEmail;
                    }
                    if (!value.contains('@')) {
                      return AppLocalizations.of(context)!.pleaseEnterYourEmail;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  textDirection: TextDirection.ltr,
                  controller: _phoneController,
                  maxLength: 9,
                  decoration: customInputDecoration(
                      context
                      , AppLocalizations.of(context)!.phoneNumber, AppLocalizations.of(context)!.phoneNumber,suffixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      '+966',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!
                          .pleaseEnterYourPhoneNumber;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  decoration: customInputDecoration(
                      context
                      , AppLocalizations.of(context)!.password, AppLocalizations.of(context)!.password),
                  keyboardType: TextInputType.visiblePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!
                          .pleaseEnterYourPhoneNumber;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: customInputDecoration(
                      context
                      , AppLocalizations.of(context)!.confirmPassword, AppLocalizations.of(context)!.confirmPassword),
                  keyboardType: TextInputType.visiblePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!
                          .pleaseEnterYourPhoneNumber;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator(color: mainColor)
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      maximumSize:    Size(double.infinity, 50),
                      fixedSize:   Size(double.infinity, 45),
                      minimumSize:    Size(mediaQueryWidth(context)*.9, 40),
                      backgroundColor: mainColor, foregroundColor: Colors.white, elevation: 0),
                  onPressed: _checkPhone,
                  child: Text(AppLocalizations.of(context)!.register),
                ),
                SizedBox(height: 20),
             /*   Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _signInWithGoogle,
                      icon: Icon(
                        Icons.g_mobiledata,
                        size: 25,
                      ),
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          maximumSize: Size(40, 40),
                          // Text color
                          side: BorderSide(color: Colors.grey, width: 1),
                          shape: CircleBorder(
                            side: BorderSide(color: Colors.grey, width: 1),
                          )),
                    ),
                    SizedBox(width: 10),
                    // Facebook Sign-In Button
                    IconButton(
                      onPressed: signInWithFacebook,
                      icon: Icon(
                        Icons.facebook,
                        size: 25,
                      ),
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          animationDuration: Duration(milliseconds: 1000),
                          backgroundColor: Colors.blue,
                          // Text color
                          side: BorderSide(color: Colors.blue, width: 1),
                          shape: CircleBorder(
                            side: BorderSide(color: Colors.blue, width: 1),
                          )),
                    ),
                  ],
                ),*/
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: Text(AppLocalizations.of(context)!
                      .alreadyHaveAnAccount),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}



