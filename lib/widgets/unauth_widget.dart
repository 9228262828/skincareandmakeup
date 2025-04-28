import 'package:flutter/material.dart';
import 'package:Gomla/screens/registration_screen.dart';
import 'package:Gomla/shared/utils/app_values.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../contstants.dart';
import '../screens/login_screen.dart';
import '../screens/policy_screen.dart';
import '../screens/register_phone_screen.dart';
import '../screens/terms_screen.dart';
import 'language_selector.dart';

class UnauthWidget extends StatelessWidget {
  const UnauthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: mediaQueryHeight(context) * 0.1),
        Center(
          child: SizedBox(
            height: mediaQueryHeight(context) * 0.1,
            child: Image(
              image: AssetImage("assets/app_icon.png",),
              width: mediaQueryWidth(context) * 0.5,
            ),
          ),
        ),
        Padding(
          padding:
          const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4),
          child: Container(
            height: mediaQueryHeight(context) * 0.22,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizations.of(context)!.welcome,
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      AppLocalizations.of(context)!.welcomeText,
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w100),
                    ),
                  ),
                  SizedBox(height: mediaQueryHeight(context) * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildAuthButton(
                          context, AppLocalizations.of(context)!.login,
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            );
                          }),
                      SizedBox(
                          width:
                          MediaQuery.of(context).size.width * 0.05),
                      _buildAuthButton(
                          context, AppLocalizations.of(context)!.register,
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const RegisterPhoneScreen()),
                            );
                          }),
                    ],
                  ),
                  SizedBox(height: mediaQueryHeight(context) * 0.01),

                ],
              ),
            ),
          ),
        ),
        SizedBox(height: mediaQueryHeight(context) * 0.0),
        Row(
          crossAxisAlignment:   CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.settings,

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: mediaQueryHeight(context) * 0.02),
        Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
            ),
            child: _buildLanguageSelector(context)),
        SizedBox(height: mediaQueryHeight(context) * 0.01),
        /*Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Column(
            children: [
              Center(
                child: Text(
                  AppLocalizations.of(context)!.sellwithus,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: mediaQueryHeight(context) * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      AppLocalizations.of(context)!.helpSupport,
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey.shade500),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                        AppLocalizations.of(context)!.privacyPolicy,
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade500)),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                        AppLocalizations.of(context)!.delveryPolicy,
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade500)),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      AppLocalizations.of(context)!.termsOfUse,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      AppLocalizations.of(context)!.faqs,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      AppLocalizations.of(context)!.shareApp,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),*/
        Container(   width:  MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(3),
          ),
          child:Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment:   CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment:   CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                        onTap:()  async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.getString("locale");
                          print("Locale: ${prefs.getString("locale")}");

                          prefs.getString("locale")=="ar"?
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PrivacyPolicyScreen(url: 'https://gomla.sa/shipping-policies-and-rates/',title:   AppLocalizations.of(context)!.shipping_policies_and_pricing,)),
                          ):
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PrivacyPolicyScreen(url: "https://gomla.sa/en/shipping-policies-and-rates/",title:  AppLocalizations.of(context)!.shipping_policies_and_pricing,)),
                          );
                        },
                        child: Text(AppLocalizations.of(context)!.shipping_policies_and_pricing,style: TextStyle(fontSize: 12, color: Colors.grey.shade500),)),
                    SizedBox(height: 7,),
                    GestureDetector(
                        onTap:()  async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.getString("locale");
                          print("Locale: ${prefs.getString("locale")}");

                          prefs.getString("locale")=="ar"?
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PrivacyPolicyScreen(url: 'https://gomla.sa/privacy-policy/',title:  AppLocalizations.of(context)!.privacyPolicy,)),
                          ):
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PrivacyPolicyScreen(url: "https://gomla.sa/en/privacy-policy/", title:  AppLocalizations.of(context)!.privacyPolicy,)),
                          );
                        },
                        child: Text(AppLocalizations.of(context)!.privacyPolicy,style: TextStyle(fontSize: 12, color: Colors.grey.shade500),)),
                    SizedBox(height: 7,),
                    GestureDetector(
                        onTap:()  async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.getString("locale");
                          print("Locale: ${prefs.getString("locale")}");

                          prefs.getString("locale")=="ar"?
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PrivacyPolicyScreen(url: 'https://gomla.sa/return-and-exchange-policy/',title:  AppLocalizations.of(context)!.return_and_exchange_policy,)),
                          ):
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PrivacyPolicyScreen(url: "https://gomla.sa/en/return-and-exchange-policy/",title:   AppLocalizations.of(context)!.return_and_exchange_policy,)),
                          );
                        },
                        child: Text(AppLocalizations.of(context)!.return_and_exchange_policy,style: TextStyle(fontSize: 12, color: Colors.grey.shade500),)),
                    SizedBox(height: 7,),

                    GestureDetector(
                        onTap:()  async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.getString("locale");
                          print("Locale: ${prefs.getString("locale")}");

                          prefs.getString("locale")=="ar"?
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PrivacyPolicyScreen(url: 'https://gomla.sa/customer-service-policy/', title:   AppLocalizations.of(context)!.technical_support_and_customer_service_policy,)),
                          ):
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PrivacyPolicyScreen(url: "https://gomla.sa/en/customer-service-policy/",  title:   AppLocalizations.of(context)!.technical_support_and_customer_service_policy,)),
                          );
                        },
                        child: Text(AppLocalizations.of(context)!.technical_support_and_customer_service_policy,style: TextStyle(fontSize: 12, color: Colors.grey.shade500),)),
                  ],
                ),



              ],
            ),
          ),
        ),
        SizedBox(height: mediaQueryHeight(context) * 0.06),
        Center(
            child: Text(
              AppLocalizations.of(context)!.version,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            )),
        Center(
            child: Text(
              AppLocalizations.of(context)!.all_rights_reserved,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            )),
      ]
    );
  }
  Widget _buildLanguageSelector(BuildContext context) {
    return ListTile(
      tileColor: Colors.grey.shade100,
      leading: Icon(Icons.language, color: Colors.grey.shade500),
      title: Text(AppLocalizations.of(context)!.changeLanguage),
      trailing: LanguageSelector(),
      onTap: () {},
    );
  }


  Widget _buildAuthButton(
      BuildContext context, String label, VoidCallback onPressed) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: mainColor,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        ),
        onPressed: onPressed,
        child: Text(label, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
