import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

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
    _gifImage = Image.asset('assets/logo Gomla Gif 3.gif');
    _loadSplashData();
  }

   Future<void> _loadSplashData() async {
     LocationPermission permission = await Geolocator.checkPermission();
     print("Initial permission status: $permission");

     if (permission == LocationPermission.denied ||
         permission == LocationPermission.deniedForever) {
       permission = await Geolocator.requestPermission();
       print("Requested permission status: $permission");

       if (permission == LocationPermission.denied ||
           permission == LocationPermission.deniedForever) {
         print("Permission denied again: $permission");
         // Still allow the app to continue
       }
     } else {
       print("Permission already granted: $permission");
     }

     SharedPreferences prefs = await SharedPreferences.getInstance();

     // Step 2: Load saved locale
     String savedLocale = prefs.getString("locale") ?? "ar";
     print('Stored locale: $savedLocale');

     // Step 3: Wait for splash duration
     await Future.delayed(Duration(milliseconds: _gifDuration));

     // Step 4: Navigate
     determineNavigation(); // ✅ always call it
   }

  Future<void> determineNavigation() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final token = prefs.getString('auth_token');

    print('isFirstLaunch: $isFirstLaunch');
    print('isLoggedIn: $isLoggedIn');
    print('auth_token: $token');

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
            (route) => false,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF212224),
      body: Center(
        child: _gifImage,
      ),
    );
  }
}
