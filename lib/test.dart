import 'package:Gomla/contstants.dart';
import 'package:Gomla/main.dart';
import 'package:Gomla/screens/registration_screen.dart';
import 'package:Gomla/shared/utils/app_assets.dart';
import 'package:Gomla/shared/utils/app_values.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/login_screen.dart';

class OpenScreen extends StatelessWidget {


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
              SizedBox(height: mediaQueryHeight(context) * 0.2),
              Center(
                child: Image.asset(
                  ImageAssets.logoWhite,
                  height: mediaQueryHeight(context) * 0.2,
                  width: mediaQueryWidth(context) * 0.7,
                ),
              ),
              SizedBox(height: 30),
              Center(
                  child: Text(
                    AppLocalizations.of(context)!.sign_in_to_account,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
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

                    Text(
                      AppLocalizations.of(context)!.find_reorder_purchases,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                    SizedBox(height: 10),
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
                    side: BorderSide(color: Colors.grey, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  child: Text(
                    AppLocalizations.of(context)!.already_customer_sign_in,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  )),
              SizedBox(height: 10),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.grey.shade200,
                    minimumSize: Size(double.infinity, 50),
                    // Text color
                    side: BorderSide(color: Colors.grey, width: .5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationScreen()));
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
                    side: BorderSide(color: Colors.grey, width: .5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {

                    SharedPreferences.getInstance().then((prefs) {
                      prefs.setBool('isLoggedIn', true);
                    });


                   Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
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
                    borderRadius: BorderRadius.circular(8),
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
                    borderRadius: BorderRadius.circular(8),
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
