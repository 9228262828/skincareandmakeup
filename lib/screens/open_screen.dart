import 'package:Gomla/screens/register_phone_screen.dart';
import 'package:Gomla/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../contstants.dart';
import '../models/banner.dart';
import '../providers/banner_repo.dart';
import '../shared/utils/app_assets.dart';
import '../shared/utils/app_values.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class OpenScreen extends StatefulWidget {


  @override
  State<OpenScreen> createState() => _OpenScreenState();
}

class _OpenScreenState extends State<OpenScreen> {
  List<Bannerr> _banners = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchBanners();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: mediaQueryHeight(context) * 0.15),
              Center(
                child: Image.asset(
                  ImageAssets.logoWhite,
                  height: mediaQueryHeight(context) * 0.15,
                  width: mediaQueryWidth(context) * 0.65,
                ),
              ),
              SizedBox(height: 30),
              Center(
                  child: Text(
                    AppLocalizations.of(context)!.sign_in_to_account,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )),
              SizedBox(height: 20),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.view_wish_list,
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                    SizedBox(height: 10),

                   /* Text(
                      AppLocalizations.of(context)!.find_reorder_purchases,
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                    SizedBox(height: 10),*/
                    Text(
                      AppLocalizations.of(context)!.track_purchases,
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                  ]),
              SizedBox(height: 20),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: mainColor,
                    minimumSize: Size(double.infinity, 50),
                    // Text color
                    side: BorderSide(color: mainColor, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  child: Text(
                    AppLocalizations.of(context)!.already_customer_sign_in,
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  )),
              SizedBox(height: 10),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.grey.shade200,
                    minimumSize: Size(double.infinity, 50),
                    // Text color
                    side: BorderSide(color: Colors.grey.shade400, width: .5),
                    shadowColor:  Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPhoneScreen()));
                  },
                  child: Text(
                    AppLocalizations.of(context)!.new_to_gomla_create_account,
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  )),
              SizedBox(height: 10),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.grey.shade200,
                    minimumSize: Size(double.infinity, 50),
                    // Text color
                    side: BorderSide(color: Colors.grey.shade400, width: .5),
                    shadowColor:  Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  onPressed: () {

                    SharedPreferences.getInstance().then((prefs) {
                      prefs.setBool('isLoggedIn', true);
                    });


                    Navigator.pushAndRemoveUntil(context,  (MaterialPageRoute(builder: (context) => MainScreen(banners: _banners,index: 0))), (route) => false);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.skip_sign_in,
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  )),
              SizedBox(height: 10),

              /* ElevatedButton.icon(
                onPressed: _signInWithGoogle,
                icon: Image.asset(
                  ImageAssets.logoWhite,
                  height: 24,
                ),
                label: Text(
                  'Sign In with Google',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  // Text color
                  side: BorderSide(color: Colors.grey, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Facebook Sign-In Button
              ElevatedButton.icon(
                onPressed: signInWithFacebook,
                icon: Image.asset(
                  ImageAssets.logo,
                  height: 24,
                ),
                label: Text(
                  'Sign In with Facebook',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 50),
                  // Text color
                  side: BorderSide(color: Colors.blue, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}