import 'dart:convert';

import 'package:Gomla/screens/register_phone_screen.dart';
import 'package:Gomla/screens/registration_screen.dart';
import 'package:Gomla/screens/reset_pass_screen.dart';
import 'package:Gomla/shared/utils/app_assets.dart';
import 'package:Gomla/shared/utils/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../contstants.dart';
import '../main.dart';
import '../models/banner.dart';
import '../providers/banner_repo.dart';
import '../services/auth_service.dart';
import '../shared/components/toast_component.dart';
import '../shared/global/app_theme.dart';
import '../widgets/pass_fiels.dart';
import '../widgets/phone_field.dart';
import 'main_screen.dart';

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

  List<Bannerr> _banners = [];

  @override
  void initState() {
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

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Prepend +966 to the username (phone number)
        String phoneNumber = '+966${_usernameController.text.replaceFirst(RegExp(r'^[+966]+'), '')}'; // Make sure to clean existing +966 if there is any

        String message = await AuthService.login(
          _usernameController.text,
          _passwordController.text,
        );

        // Show success message in the Snackbar
       showToast(text: message, state: ToastStates.SUCCESS);

        // Navigate to the home screen or wherever
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen(index: 0)),
        );
      } catch (e) {
        // Show error message from API
        showToast(text: e.toString(), state: ToastStates.ERROR);
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
                  height: mediaQueryHeight(context) * 0.04,
                ),
                Image.asset(ImageAssets.logoWhite,
                    height: mediaQueryHeight(context) * 0.08,
                    width: mediaQueryWidth(context) * 0.9),
                 SizedBox(height: mediaQueryHeight(context) * 0.14,),
                Text(AppLocalizations.of(context)!.login, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                SizedBox(
                  height: mediaQueryHeight(context) * 0.04,
                ),

                PhoneNumberField(
                  isRequired: true,
                  phoneController: _usernameController,
                ),



                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: PasswordField(
                    passwordController: _passwordController,
                    name:   AppLocalizations.of(context)!.password,
                  ),
                ),

                const SizedBox(height: 15),
                Align(
                    alignment: Alignment.centerLeft,
                    child:  GestureDetector(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>  ResetPassScreen(),
                            ),
                          );
                        },
                        child: Text(AppLocalizations.of(context)!.forgetPassword,style:   TextStyle(color: mainColor,fontSize: 12  ,),))),
                const SizedBox(height: 15),
                _isLoading
                    ?  CircularProgressIndicator( color: mainColor  ,)
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            maximumSize: Size(double.infinity, 50),
                            fixedSize: Size(double.infinity, 45),
                            minimumSize: Size(mediaQueryWidth(context) * .9, 40),
                            backgroundColor: Color(0xFF212224 ),
                            foregroundColor: Colors.white,
                            elevation: 0),
                        onPressed: _login,
                        child: Text(AppLocalizations.of(context)!.login,style:   TextStyle(color: Colors.white,fontWeight: FontWeight.w600 ,),
                      ),),

                const SizedBox(height: 17),

                Row(
                  crossAxisAlignment:   CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.dontHaveAccount,  // Make sure this matches the text you want
                      style: TextStyle(
                        fontSize: 14, // Adjust font size
                        fontWeight: FontWeight.w400, // Make the text bold
                        color: Colors.black, // Default color
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterPhoneScreen(),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.register,
                        style:   TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: mainColor,
                          decoration: TextDecoration.underline,
                          decorationColor:  mainColor
                        ),
                      ),
                    ),

                    ]
                ),


                SizedBox(height: mediaQueryHeight(context) * 0.1),
                TextButton(onPressed: (){
                  Navigator.pushAndRemoveUntil(context,  (MaterialPageRoute(builder: (context) => MainScreen(banners: _banners,index: 0))), (route) => false);

                }, child: Row(
                  mainAxisAlignment:  MainAxisAlignment.center,

                  children: [
                    Text(AppLocalizations.of(context)!.visitAsGuest,style: TextStyle(color: Colors.grey.shade600,fontWeight: FontWeight.w500),),
                    SizedBox(width: 0,),
                    Icon(Icons.arrow_forward_ios_outlined,color:  Colors.grey.shade600,size: 14,)
                  ],
                ))
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


