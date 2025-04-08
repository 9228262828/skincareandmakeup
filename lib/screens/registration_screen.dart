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
  final String otp;
  final String phone;
  const RegistrationScreen({super.key, required this.otp, required this.phone});

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
   final _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final data = {
      'phone': widget.phone,
      'email': _emailController.text,
      'username': _usernameController.text,
      'password': _passwordController.text,
      'otp': widget.otp,
    };

    print("Sending Data: $data");

    try {
      final response = await http.post(
        Uri.parse('https://gomla.sa/wp-json/custom-auth/v1/register'),
        body: data,
      );

      final responseData = json.decode(response.body);
      print("Response Data: $responseData");

      if (responseData['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful!')),
        );
        await AuthService.login(
         widget.phone,
          _passwordController.text,
        );
        Navigator.pushAndRemoveUntil(context,  (MaterialPageRoute(builder: (context) => MainScreen(

            banners: [],index: 0))), (route) => false);
      } else {
        String errorMessage = responseData["message"] ?? 'Registration failed, please try again';

        // **التحقق مما إذا كان هناك قائمة `errors`**
        if (responseData.containsKey("errors")) {
          Map<String, dynamic> errors = responseData["errors"];
          errorMessage = errors.entries.map((e) => "${e.value}").join("\n");
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                      "${AppLocalizations.of(context)!.email} ${AppLocalizations.of(context)!.optional}",
                    "${AppLocalizations.of(context)!.email} ${AppLocalizations.of(context)!.optional}",
                  ),
                  keyboardType: TextInputType.emailAddress,

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
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _register();
                          }
                        },
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

    super.dispose();
  }
}
