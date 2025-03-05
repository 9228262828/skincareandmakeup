import 'dart:convert';

import 'package:Gomla/screens/registration_screen.dart';
import 'package:Gomla/shared/utils/app_assets.dart';
import 'package:Gomla/shared/utils/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../contstants.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../shared/global/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;



  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await AuthService.login(
          _usernameController.text,
          _passwordController.text,
        );
        // Navigate to the home screen or wherever
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.loginSuccessful), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)!.loginFailed}: ${e.toString()}')),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: mediaQueryHeight(context) * 0.2,
                ),
                Image.asset(ImageAssets.logoWhite,
                    height: mediaQueryHeight(context) * 0.2,
                    width: mediaQueryWidth(context) * 0.7),
                TextFormField(
                  controller: _usernameController,
                  decoration: customInputDecoration(
                      context,
                      AppLocalizations.of(context)!.userName,
                      AppLocalizations.of(context)!.userName),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.pleaseEnterYourUsername;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: customInputDecoration(
                      context,
                      AppLocalizations.of(context)!.password,
                      AppLocalizations.of(context)!.password),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.pleaseEnterYourPassword;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _isLoading
                    ?  CircularProgressIndicator( color: mainColor  ,)
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                            maximumSize: Size(double.infinity, 50),
                            fixedSize: Size(double.infinity, 45),
                            minimumSize: Size(mediaQueryWidth(context) * .9, 40),
                            backgroundColor: mainColor,
                            foregroundColor: Colors.white,
                            elevation: 0),
                        onPressed: _login,
                        child: Text(AppLocalizations.of(context)!.login),
                      ),
                const SizedBox(height: 20),
                /*Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        signInWithGoogle1();

                        // _deleteAccount();
                      },
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
                      onPressed: (){
                        signInWithFacebook();
                      },
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
                        builder: (context) => RegistrationScreen(),
                      ),
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.dontHaveAccount),
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
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
