import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:Gomla/screens/registration_screen.dart';
import 'package:Gomla/shared/utils/app_assets.dart';
import 'package:Gomla/shared/utils/app_values.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../contstants.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../shared/global/app_theme.dart';
import '../widgets/fade_image.dart';

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
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  static const String _tokenKey = 'auth_token';

  Future<UserCredential> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        print('Google sign-in failed: User canceled the sign-in process');
        throw Exception('User canceled the sign-in process');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, credential.accessToken!);
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      loginWithFacebookToken( credential.accessToken!);
      User? user = userCredential.user;

      if (user != null) {
        print('User signed in with Google:');
        print('Email: ${user.email}');
        print('Phone: ${user.phoneNumber ?? "No phone number"}');
        print('Display Name: ${user.displayName ?? "No display name"}');
        print('Profile Image URL: ${user.photoURL ?? "No profile image"}');
        _saveUserData(userCredential  );
      } else {
        print('Google sign-in failed: User object is null');
      }

      // Return the UserCredential
      return userCredential;
    } catch (error) {
      print("Google sign-in error: $error");
      rethrow; // Optionally rethrow the error
    }
  }



  // Facebook Sign-In method
  Future<void> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow with Facebook
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status == LoginStatus.success) {
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCredential(facebookAuthCredential);

        if (userCredential.user != null) {
          print('User signed in with Facebook: ${userCredential.user!.email}');
          _saveUserData(userCredential); // Save the data to SharedPreferences
        }
      } else {
        print('Facebook login failed: ${loginResult.message}');
        throw Exception('Facebook login failed');
      }
    } catch (error) {
      if (error is FirebaseAuthException &&
          error.code == 'account-exists-with-different-credential') {
        final FirebaseAuthException e = error;
        String email = e.email!;

        print('Email already associated with another provider: $email');

        List<String> providers = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

        final LoginResult loginResult = await FacebookAuth.instance.login();
        if (loginResult.status == LoginStatus.success) {
          print('Facebook token: ${loginResult.accessToken!.tokenString}');
          loginWithFacebookToken(loginResult.accessToken!.tokenString);
        }
        _usernameController.text = email;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', email);
        await prefs.setString(
            'userFirstName', loginResult.accessToken?.tokenString ?? '');


      } else {
        print('Error during Facebook sign-in: $error');
      }
    }
  }



  Future<void> loginWithFacebookToken( String accessToken) async {
    const String url = 'http://gomla.sa/wp-json/nextend-social-login/v1/google/get_user';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final Map<String, String> body = {
      'access_token': "EAAYsoWZBUIZBMBO2kMPhMugTwt6kQQZC1LECk3pZAZCOxDva5NQTOE4ZCqi8cyL02xqZAOfAX9DiNceUfmaFHv3DNclJx7rq1DMBCLPLePmc8Wh51OrlwnBOqOZBegae2kgK5P3ZAmpbr3EtXXDiVeNvJwtbkvpULiYSszPyGYGH8ZAHdxD3YUGfP45ZAOwG375ekkEEo3XdIU8frCDB7A46CaOZBHo0TgFq73mMhYsuO0Br2jTIBUedOgZDZD",
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {

        final responseData = json.decode(response.body);
        print('Response Data: $responseData');
      } else {
        print('Failed to get user data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error making POST request: $error');
    }
  }

  void _saveUserData(UserCredential userCredential) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userEmail', userCredential.user!.email!);
    await prefs.setString('userPhone', userCredential.user!.phoneNumber ?? '');
    await prefs.setString('userFirstName', userCredential.user!.displayName ?? '');
    await prefs.setString('userPhoto', userCredential.user!.photoURL ?? '');
    print('User data saved successfully!');
  }

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
        Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
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
      body: Padding(
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
                  ? const FadeInOutImage(height: 200)
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
              Row(
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
              ),
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
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
