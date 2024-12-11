import 'package:flutter/material.dart';
import 'package:Gomla/screens/registration_screen.dart';
import 'package:Gomla/shared/utils/app_values.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../contstants.dart';
import '../screens/login_screen.dart';
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
            height: mediaQueryHeight(context) * 0.16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.welcome,
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                  Text(
                    AppLocalizations.of(context)!.welcomeText,
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w100),
                  ),
                  SizedBox(height: mediaQueryHeight(context) * 0.02),
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
                                  const RegistrationScreen()),
                            );
                          }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: mediaQueryHeight(context) * 0.0),
        Text(
          AppLocalizations.of(context)!.settings,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: mediaQueryHeight(context) * 0.02),
        Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: _buildLanguageSelector(context)),
        SizedBox(height: mediaQueryHeight(context) * 0.06),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
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
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: Text(label, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
