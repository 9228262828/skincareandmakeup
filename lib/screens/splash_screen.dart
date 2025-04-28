import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/banner.dart';
import '../providers/banner_repo.dart';
import 'lang_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
   late Image _gifImage;
  final int _gifDuration =6900;

  @override
  void initState() {
    super.initState();
    _loadSplashData();
    _gifImage = Image.asset('assets/logo Gomla Gif 3.gif',); // Ensure the path is correct
  }


  Future<void> _loadSplashData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load saved locale or default to 'ar'
    String savedLocale = prefs.getString("locale") ?? "ar";
    print('Stored locale: $savedLocale');

    // Fetch banners

    // Wait until the GIF finishes
    await Future.delayed(Duration(milliseconds: _gifDuration));

    // Determine navigation flow
    determineNavigation();
  }


  Future<void> determineNavigation() async {
    final prefs = await SharedPreferences.getInstance();

    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    print('isFirstLaunch: $isFirstLaunch');

    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    print('isLoggedIn: $isLoggedIn');

    final token = prefs.getString('auth_token');
    print('auth_token: $token');

    // Navigate based on first launch and logged-in status
    if (isFirstLaunch) {
      await prefs.setBool('isFirstLaunch', false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen(banners: [], index: 0)),
              (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF212224),
      body: Center(
        child: _gifImage, // Preloaded GIF
      ),
    );
  }
}
