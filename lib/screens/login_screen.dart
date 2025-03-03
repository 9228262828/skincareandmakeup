import 'dart:convert';

import 'package:Gomla/screens/registration_screen.dart';
import 'package:Gomla/shared/utils/app_assets.dart';
import 'package:Gomla/shared/utils/app_values.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:url_launcher/url_launcher.dart';
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

  // Initialize GoogleSignIn with openid scope to get idToken
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
  );

  // Handle Google Sign-In

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print('User canceled the sign-in process');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Use FirebaseAuth to sign in
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;
      print('User: ${user?.displayName}');
      print('Access Token: ${googleAuth.accessToken}');
      print('ID Token: ${googleAuth.idToken}');
      print('ID Token: ${user?.uid}');
      loginWithGoogleToken(
        googleAuth.accessToken!,
        user!.uid,
      );
    } catch (error) {
      print("Error signing in with Google: $error");
    }
  }





  Future<void> signInWithGoogle1() async {


    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      // User canceled the sign-in process
      return;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

// You can now get the accessToken and idToken
    String? accessToken = googleAuth.accessToken;
    String? idToken = googleAuth.idToken;
    print('Access Token: $accessToken');
    print('ID Token: $idToken');

  }


  Future<void> loginWithGoogleToken(String accessToken, String idToken) async {
    const String url =
        'https://gomla.sa/wp-json/nextend-social-login/v1/google/get_user';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> body = {
      'access_token': accessToken,
      "id_token": idToken, // Make sure the id_token is also passed here
      "token_type": "bearer",
      "expires_in": 5183946
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
        print('Error Message: ${response.body}');
      }
    } catch (error) {
      print('Error making POST request: $error');
    }
  }

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
          loginWithFacebookToken(loginResult.accessToken!.toString());
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
    const String url = 'http://gomla.sa/wp-json/nextend-social-login/v1/Facebook/get_user';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> body = {
      "access_token": accessToken,
      "token_type": "bearer",
      "expires_in": 5183946
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
                Row(
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
