import 'dart:convert';

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


  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Google Sign-In method
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential googleCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(googleCredential);

        if (userCredential.user != null) {
          print(userCredential.user!.photoURL);
          print(userCredential.user!.phoneNumber);
          // Populate form fields with user data
          _emailController.text = userCredential.user!.email!;
          _phoneController.text = userCredential.user!.phoneNumber ?? '';
          // Extract first and last name from displayName (if available)
          String displayName = userCredential.user!.displayName ?? '';
          List<String> nameParts = displayName.split(' ');
          if (nameParts.isNotEmpty) {
            _firstNameController.text = nameParts[0];  // First part of the display name is first name
          }
          if (nameParts.length > 1) {
            _lastNameController.text = nameParts.sublist(1).join(' '); // The rest is considered last name
          }

          // Save user data to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('userEmail', _emailController.text);
          prefs.setString('userPhone', _phoneController.text);
          prefs.setString('userFirstName', _firstNameController.text);
          prefs.setString('userPhoto', userCredential.user!.photoURL ?? ''); // Save photo URL if available

        }
      }
    } catch (error) {
      print("Google sign-in error: $error");
    }
  }

  // Facebook Sign-In method
  Future<void> signInWithFacebook() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status == LoginStatus.success) {
        final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

        if (userCredential.user != null) {
          // If the user is already signed in, populate the fields
          _emailController.text = userCredential.user!.email!;

          // Check if the email already exists with a different sign-in method
          if (userCredential.user!.email != null) {
            try {
              List<String> providers =
              await FirebaseAuth.instance.fetchSignInMethodsForEmail(userCredential.user!.email!);

              // If the email is already associated with another provider, just fill the email and proceed
              if (providers.isNotEmpty) {
                // Fill the email field automatically
                _emailController.text = userCredential.user!.email!;
                // You can populate other fields as needed (e.g., phone, display name, etc.)
                _phoneController.text = userCredential.user!.phoneNumber ?? '';
                _firstNameController.text = userCredential.user!.displayName ?? '';
              }
            } catch (e) {
              print('Error fetching providers for email: $e');
            }
          }

          // Save user data to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('userEmail', _emailController.text);
          prefs.setString('userPhone', _phoneController.text);
          prefs.setString('userFirstName', _firstNameController.text);
          prefs.setString('userPhoto', userCredential.user!.photoURL ?? ''); // Save photo URL if available

          // Navigate to the main screen
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => MainScreen()));
        }
      } else {
        print('Facebook login failed: ${loginResult.message}');
      }
    } catch (error) {
      if (error is FirebaseAuthException) {
        if (error.code == 'account-exists-with-different-credential') {
          // Handle error where email exists with a different provider, no dialog is shown
          final FirebaseAuthException e = error as FirebaseAuthException;
          String email = e.email!;
          print('Email: $email');

          // Fetch the list of providers for the email
          List<String> providers = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

          // Just populate the email field and proceed with the flow
          _emailController.text = email;
          if (providers.contains('google.com')) {
            // Handle specific logic for Google sign-in if necessary
          } else if (providers.contains('password')) {
            // Handle specific logic for Email/Password sign-in if necessary
          }
          // Add other provider checks as needed
        }
      }
      print('Facebook sign-in error: $error');
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

                /*TextFormField(
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
                ),*/
                SizedBox(height: 20),
               /* TextFormField(
                  controller: _phoneController,
                  decoration: customInputDecoration(
                      context
                      , AppLocalizations.of(context)!.phoneNumber, AppLocalizations.of(context)!.phoneNumber),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!
                          .pleaseEnterYourPhoneNumber;
                    }
                    return null;
                  },
                ),*/
                /*SizedBox(height: 20),*/TextFormField(
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
                /*SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: customInputDecoration(
                      context
                      , AppLocalizations.of(context)!.confirmPassword, AppLocalizations.of(context)!.confirmPassword),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!
                          .pleaseEnterYourPhoneNumber;
                    }
                    return null;
                  },
                ),*/
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator(color: mainColor)
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      maximumSize:    Size(double.infinity, 50),
                      fixedSize:   Size(double.infinity, 45),
                      minimumSize:    Size(mediaQueryWidth(context)*.9, 40),
                      backgroundColor: mainColor, foregroundColor: Colors.white, elevation: 0),
                  onPressed: _register,
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
