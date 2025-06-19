import 'dart:convert';
import 'package:Gomla/screens/verifyphone_screen.dart';
import 'package:Gomla/shared/global/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../contstants.dart';
import '../services/auth_service.dart';
import '../shared/components/toast_component.dart';
import '../shared/utils/app_assets.dart';
import '../shared/utils/app_values.dart';
import '../widgets/pass_fiels.dart';
import '../widgets/phone_field.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;

import 'main_screen.dart';

class RegisterPhoneScreen extends StatefulWidget {
  const RegisterPhoneScreen({super.key});

  @override
  State<RegisterPhoneScreen> createState() => _RegisterPhoneScreenState();
}

class _RegisterPhoneScreenState extends State<RegisterPhoneScreen> {
  final _formKey = GlobalKey<FormState>();

  final _phoneController = TextEditingController();
  bool _isLoading = false;


  Future<void> _checkPhone() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Check if phone number is in valid format
      print("${_phoneController.text}");

      try {
        final response = await http.post(
          Uri.parse('https://gomla.egymetrix.net/wp-json/custom-auth/v1/check-phone'),
          body: {
            'phone':
            "${_phoneController.text}" // Corrected line to send the phone as a string
          },
        );

        // Print the raw response body for inspection
        print('Response body: ${response.body}');

        // Check if the response is valid JSON or not
        if (response.statusCode == 200) {
          try {
            // Attempt to decode the response if it is in JSON format
            final Map<String, dynamic> data = json.decode(response.body);
            print('Decoded data: $data');

            if (data['success'] == true) {
              String otp = data['otp'].toString();
              showToast(state: ToastStates.SUCCESS, text: data['message']);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VerifyPhoneScreen(
                    phone: _phoneController.text,

                  ),
                ),
              );
            } else {
              print('Error response: ${response.body}');
            showToast(text: data['message'], state: ToastStates.ERROR);
            }
          } catch (e) {
            print('Error decoding JSON: $e');
            showToast(text: 'خطأ في التحقق من الهاتف', state: ToastStates.ERROR);
          }
        } else {
          print('Error: Received status code ${response.statusCode}');
          print('Response body: ${response.body}');
          final errorResponse = json.decode(response.body);
          showToast(text: errorResponse['message'], state: ToastStates.ERROR);
        }
      } catch (e) {
        print('Error: $e');
        showToast(text: 'خطأ في التحقق من الهاتف', state: ToastStates.ERROR);
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: mediaQueryHeight(context) * 0.04,
                ),
                Image.asset(ImageAssets.logoWhite,
                    height: mediaQueryHeight(context) * 0.08,
                    width: mediaQueryWidth(context) * 0.9),
                SizedBox(height: mediaQueryHeight(context) * 0.14,),
                Text(AppLocalizations.of(context)!.createAccount, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                SizedBox(
                  height: mediaQueryHeight(context) * 0.01,
                ),Text(AppLocalizations.of(context)!.add_your_phone_for_register, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
                SizedBox(
                  height: mediaQueryHeight(context) * 0.04,
                ),

                PhoneNumberField(
                  isRequired:   true,
                  phoneController: _phoneController,
                ),
                SizedBox(height: 10),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator(color: mainColor)
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      maximumSize: Size(double.infinity, 50),
                      fixedSize: Size(double.infinity, 45),
                      minimumSize:
                      Size(mediaQueryWidth(context) * .9, 40),
                      backgroundColor: Color(0xFF212224),
                      foregroundColor: Colors.white,
                      elevation: 0),
                  onPressed: _checkPhone,
                  child: Text(
                    AppLocalizations.of(context)!.send_otp,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                    crossAxisAlignment:   CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.alreadyHaveAnAccount,
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
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)!.login,
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

              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
