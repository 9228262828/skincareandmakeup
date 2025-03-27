import 'dart:convert';
import 'package:Gomla/screens/verifyphone_screen.dart';
import 'package:Gomla/shared/global/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../contstants.dart';
import '../services/auth_service.dart';
import '../shared/utils/app_assets.dart';
import '../shared/utils/app_values.dart';
import '../widgets/pass_fiels.dart';
import '../widgets/phone_field.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;

import 'main_screen.dart';

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
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.passwordsDoNotMatch)),
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
        prefs.setString(
            'userPhoto', ''); // You can store the photo URL here if available

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainScreen(index: 0)));
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
            'phone':
                "+966${_phoneController.text}" // Corrected line to send the phone as a string
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
                SnackBar(
                    content: Text(data['message'] ?? 'تم التحقق من الهاتف')),
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
                SnackBar(
                    content: Text(data['message'] ?? 'فشل التحقق من الهاتف')),
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
            SnackBar(
                content: Text(
                    'Phone verification failed with status: ${response.statusCode}')),
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
                  height: mediaQueryHeight(context) * 0.04,
                ),
                Image.asset(ImageAssets.logoWhite,
                    height: mediaQueryHeight(context) * 0.08,
                    width: mediaQueryWidth(context) * 0.9),
                SizedBox(height: mediaQueryHeight(context) * 0.14,),
                Text(AppLocalizations.of(context)!.createAccount, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                SizedBox(
                  height: mediaQueryHeight(context) * 0.04,
                ),

                TextFormField(
                  controller: _usernameController,
                  decoration: customInputDecoration(
                      prefixIcon: Localizations.localeOf(context)
                                  .languageCode ==
                              'ar'
                          ? Icon(Icons.person, size: 20,color:  Color(0xFFDC9D1E),) // Prefix for Arabic
                          : Directionality(
                              textDirection: TextDirection.ltr,
                              child: Icon(Icons.person_2_rounded, size: 20,color:   Color(0xFFDC9D1E),),
                            ),
                      context,
                      AppLocalizations.of(context)!.userName,
                      AppLocalizations.of(context)!.userName),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!
                          .pleaseEnterYourUsername;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  decoration: customInputDecoration(
                      prefixIcon:
                          Localizations.localeOf(context).languageCode == 'ar'
                              ? Icon(Icons.email_outlined,
                                  size: 20,color:   Color(0xFFDC9D1E),) // Prefix for Arabic
                              : Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Icon(Icons.email_outlined, size: 20, color:  Color(0xFFDC9D1E),),
                                ),
                      context,
                      AppLocalizations.of(context)!.email,
                      AppLocalizations.of(context)!.email),
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
                SizedBox(height: 10),
                PhoneNumberField(
                  phoneController: _phoneController,
                ),
                SizedBox(height: 10),
                PasswordField(
                  passwordController: _passwordController,
                  name: AppLocalizations.of(context)!.password,
                ),
                SizedBox(height: 10),
                PasswordField(
                  passwordController: _confirmPasswordController,
                  name: AppLocalizations.of(context)!.confirmPassword,
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator(color: mainColor)
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            maximumSize: Size(double.infinity, 50),
                            fixedSize: Size(double.infinity, 45),
                            minimumSize:
                                Size(mediaQueryWidth(context) * .9, 40),
                            backgroundColor: Color(0xFF212224),
                            foregroundColor: Colors.white,
                            elevation: 0),
                        onPressed: _checkPhone,
                        child: Text(
                          AppLocalizations.of(context)!.register,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                SizedBox(height: 20),
                Row(
                    crossAxisAlignment:   CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.alreadyHaveAnAccount,
                        style: TextStyle(
                          fontSize: 14, // Adjust font size
                          fontWeight: FontWeight.w400, // Make the text bold
                          color: Colors.black, // Default color
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)!.login,
                          style:   TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: mainColor,
                              decoration: TextDecoration.underline,
                              decorationColor:  mainColor
                          ),
                        ),
                      ),

                    ]
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
