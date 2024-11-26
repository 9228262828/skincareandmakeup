import 'package:flutter/material.dart';
import 'package:skincare/contstants.dart';
import 'package:skincare/main.dart';
import 'package:skincare/models/order.dart';
import 'package:skincare/screens/fav_screen.dart';
import 'package:skincare/screens/help_screen.dart';
import 'package:skincare/screens/home_screen.dart';
import 'package:skincare/screens/login_screen.dart';
import 'package:skincare/screens/orders_screen.dart';
import 'package:skincare/screens/registration_screen.dart';
import 'package:skincare/services/auth_service.dart';
import 'package:skincare/services/woocommerce_service.dart';
import 'package:skincare/widgets/app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:http/http.dart' as http;

import '../widgets/language_selector.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _userInfo;
  late Future<List<Order>> futureOrders;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      final userInfo = await AuthService.fetchUserInfo();
      print(userInfo);

      setState(() {
        _userInfo = userInfo;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 500),
          backgroundColor: Colors.red,
          content: Text(
            'من فضلك قم بتسجيل الدخول',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _shareApp() {
    Share.share('Check out this amazing app: [App Link]');
  }

  Future<void> _launchUrl(_url) async {
    final Uri url = Uri.parse(_url);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context)!.profile),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_userInfo == null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  // make buttons 50% of the screen width
                  // and spread them evenly
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: mainColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                        child: Text(AppLocalizations.of(context)!.login, style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RegistrationScreen()),
                          );
                        },
                        child: Text(AppLocalizations.of(context)!.register, style: TextStyle(color: mainColor)),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text('${_userInfo!['username']}'),
              ),
            ],
            (_userInfo != null)
                ? ListTile(
                    tileColor: Colors.grey.shade100,
                    leading: Icon(
                      Icons.local_mall,
                      color: Colors.grey.shade500,
                    ),
                    title: Text(AppLocalizations.of(context)!.myOrders),
                    onTap: () {
                      // Navigate to My Favourites
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OrdersScreen()),
                      );
                    },
                  )
                : Container(),
            ListTile(
              tileColor: Colors.grey.shade100,
              leading: Icon(
                Icons.favorite_border,
                color: Colors.grey.shade500,
              ),
              title: Text(AppLocalizations.of(context)!.myFavorites),
              onTap: () {
                // Navigate to My Favourites
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.headset_mic,
                color: Colors.grey.shade500,
              ),
              title: Text(AppLocalizations.of(context)!.helpSupport),
              onTap: () {
                // Navigate to Help & Support
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HelpSupportScreen()),
                );
              },
            ),
            ListTile(
              tileColor: Colors.grey.shade100,
              leading: Icon(
                Icons.policy,
                color: Colors.grey.shade500,
              ),
              title: Text(AppLocalizations.of(context)!.privacyPolicy),
              onTap: () async {
                // _launchUrl('https://mskra.com/privacy-policy/');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delivery_dining,
                color: Colors.grey.shade500,
              ),
              title: Text(AppLocalizations.of(context)!.delveryPolicy),
              onTap: () async {
                // _launchUrl('https://mskra.com/delivery-policy/');
              },
            ),
            ListTile(
              tileColor: Colors.grey.shade100,
              leading: Icon(
                Icons.policy_outlined,
                color: Colors.grey.shade500,
              ),
              title: Text(AppLocalizations.of(context)!.termsOfUse),
              onTap: () async {
                // _launchUrl('https://mskra.com/terms-of-use/');
              },
            ),
            ListTile(
              leading: Icon(Icons.question_answer, color: Colors.grey.shade500),
              title: Text(AppLocalizations.of(context)!.faqs),
              onTap: () async {
                // _launchUrl('https://mskra.com/faq/');
              },
            ),
            ListTile(
              tileColor: Colors.grey.shade100,
              leading: Icon(
                Icons.share,
                color: Colors.grey.shade500,
              ),
              title: Text(AppLocalizations.of(context)!.shareApp),
              onTap: _shareApp,
            ),
            ListTile(
              leading: Icon(Icons.language, color: Colors.grey.shade500),
              title: Text(AppLocalizations.of(context)!.changeLanguage),
              trailing: LanguageSelector(),
              onTap: () {
                // Navigate to Change Language
              },
            ),
            if (_userInfo != null) ...[
              ListTile(
                // add border bottom to the list tile
                tileColor: Colors.grey.shade100,
                leading: Icon(Icons.logout, color: Colors.grey.shade500),
                title: Text(AppLocalizations.of(context)!.logout),
                onTap: () {
                  AuthService.logout();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MainScreen()),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
