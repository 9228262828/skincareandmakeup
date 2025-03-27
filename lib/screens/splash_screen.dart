import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
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
  List<Bannerr> _banners = [];

  @override
  void initState() {
    super.initState();
    _loadSplashData();


  }

  Future<void> _loadSplashData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load saved locale or default to 'ar'
    String savedLocale = prefs.getString("locale") ?? "ar";
    print('Stored locale: $savedLocale');

    // Fetch banners
    await _fetchBanners();

    // Wait 3 seconds for splash delay
    await Future.delayed(const Duration(seconds: 3));

    // Determine navigation flow
    determineNavigation();
  }

  Future<void> _fetchBanners() async {
    try {
      List<Bannerr> banners = await BannerService().fetchBanners();
      setState(() {
        _banners = banners;
      });
      print('Fetched banners: ${banners.length}');
    } catch (error) {
      print('Error fetching banners: $error');
    }
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
      Navigator.pushAndRemoveUntil(context,  (MaterialPageRoute(builder: (context) => MainScreen(banners: _banners,index: 0))), (route) => false);

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
backgroundColor:  Color(0xFF212224),
      body: Center(
        child:Image.asset(
          'assets/logo Gomla Gif 3.gif',
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.4,
          fit: BoxFit.contain,
        ),
      ),
    );  }
}