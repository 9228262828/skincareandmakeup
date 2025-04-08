import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:Gomla/screens/verifyphone_screen.dart';
import 'package:Gomla/shared/global/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pinput/pinput.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../contstants.dart';
import '../services/auth_service.dart';
import '../shared/utils/app_assets.dart';
import '../shared/utils/app_values.dart';
import '../widgets/phone_field.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;

import 'main_screen.dart';
class ResetPassScreen extends StatefulWidget {
  const ResetPassScreen({super.key});

  @override
  State<ResetPassScreen> createState() => _ResetPassScreenState();
}

class _ResetPassScreenState extends State<ResetPassScreen> {
  final _formKey = GlobalKey<FormState>();

  final _phoneController = TextEditingController(); // Phone number controller
  final _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _checkPhone() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Check if phone number is in valid format
      print("+966${_phoneController.text}");

      try {
        final response = await http.post(
          Uri.parse('https://gomla.sa/wp-json/custom-auth/v1/request-password-reset'),
          body: {
            'phone': "+966${_phoneController.text}" // Corrected line to send the phone as a string
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
              String otp = data['otp'].toString(); // حفظ OTP
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(data['message'] ?? 'تم التحقق من الهاتف')),
              );
              _otpController.text = otp;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VerifyPhoneRestScreen(
                    phone: _phoneController.text,

                  ),
                ),
              );
            } else {
              print('Error response: ${response.body}');
              final Map<String, dynamic> data = json.decode(response.body);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(' ${data['message']}')),
              );
            }
          } catch (e) {
            // Catching FormatException or any other decoding issues
            print('Error decoding JSON: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error decoding response: $e')),
            );
          }
        } else {
          print('Error: Received status code ${response.statusCode}');
          print('Response body: ${response.body}');
          final Map<String, dynamic> data = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(' ${data['message']}')),
          );
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: ${e.toString()}')),
        );
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
      appBar:   AppBar(
        surfaceTintColor:   Colors.white,
        backgroundColor: Colors.white,
        title: Text(AppLocalizations.of(context)!.resetPassword,style: TextStyle(color: Colors.black,fontSize: 16),),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: mediaQueryHeight(context) * 0.06,
                ),
                Image.asset(ImageAssets.logoWhite,
                    height: mediaQueryHeight(context) * 0.09,
                    width: mediaQueryWidth(context) * 0.7),
                SizedBox(height: mediaQueryHeight(context) * 0.08,),
                Text(AppLocalizations.of(context)!.resetPassword, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                SizedBox(
                  height: mediaQueryHeight(context) * 0.05,
                ),
                PhoneNumberField(
                  phoneController: _phoneController,
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator(color: mainColor)
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      maximumSize:    Size(double.infinity, 50),
                      fixedSize:   Size(double.infinity, 45),
                      minimumSize:    Size(mediaQueryWidth(context)*.9, 40),
                      backgroundColor: Color(0xFF212224), foregroundColor: Colors.white, elevation: 0),
                  onPressed: _checkPhone,
                  child: Text(AppLocalizations.of(context)!.send_otp),
                ),
                SizedBox(height: 20),
                /*   Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _signInWithGoogle,
                      icon: Icon(
                        Icons.g_mobiledata,
                        size: 25,
                      ),
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          maximumSize: Size(40, 40),
                          // Text color
                          side: BorderSide(color: Colors.grey, width: 1),
                          shape: CircleBorder(
                            side: BorderSide(color: Colors.grey, width: 1),
                          )),
                    ),
                    SizedBox(width: 10),
                    // Facebook Sign-In Button
                    IconButton(
                      onPressed: signInWithFacebook,
                      icon: Icon(
                        Icons.facebook,
                        size: 25,
                      ),
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          animationDuration: Duration(milliseconds: 1000),
                          backgroundColor: Colors.blue,
                          // Text color
                          side: BorderSide(color: Colors.blue, width: 1),
                          shape: CircleBorder(
                            side: BorderSide(color: Colors.blue, width: 1),
                          )),
                    ),
                  ],
                ),*/
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

class VerifyPhoneRestScreen extends StatefulWidget {
  final String phone;


  const VerifyPhoneRestScreen({
    super.key,
    required this.phone,
  });

  @override
  State<VerifyPhoneRestScreen> createState() => _VerifyPhoneRestScreenState();
}

class _VerifyPhoneRestScreenState extends State<VerifyPhoneRestScreen> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _resetPassword() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.please_enter_6_numbers)),
      );
      return;
    }

    // Validate if the password is entered
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseEnterYourNewPassword)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final data = {
      'phone': "+966${widget.phone}",
      'new_password': _passwordController.text,
      'otp': _otpController.text,
    };

    print("Sending Data: $data");

    try {
      final response = await http.post(
        Uri.parse('https://gomla.sa/wp-json/custom-auth/v1/reset-password'),
        body: data,
      );

      final responseData = json.decode(response.body);
      print("Response Data: $responseData");

      if (responseData['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.password_reset_successfully)),
        );
        await AuthService.login(
          widget.phone,
          _passwordController.text,
        );
        Navigator.pushAndRemoveUntil(context,  (MaterialPageRoute(builder: (context) => MainScreen(

            banners: [],index: 0))), (route) => false);
      } else {
        String errorMessage = responseData["message"] ?? '';

        // Check if there is an 'errors' list
        if (responseData.containsKey("errors")) {
          Map<String, dynamic> errors = responseData["errors"];
          errorMessage = errors.entries.map((e) => "${e.value}").join("\n");
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  void _listenOtp() async {
    await SmsAutoFill().listenForCode();
    print("OTP Listen is called");
  }
  @override
  void initState() {
    _listenOtp();
    super.initState();
  }
  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    print("unVerify Listener");
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.verifyPhone),surfaceTintColor:   Colors.white,backgroundColor:   Colors.white,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Directionality(
          textDirection: TextDirection.ltr,

          child: Form(
            key: _formKey,
            child: Column(

              children: [
                SizedBox(
                  height: mediaQueryHeight(context) * 0.05,
                ),

                Text("${AppLocalizations.of(context)!.please_enter_6_numbers}${widget.phone}",
                  style:  TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                PinFieldAutoFill(
                  currentCode: _otpController.text,
                  cursor:   Cursor(
                    color: mainColor,
                    height: 20,
                    width: 1.5,
                  ),
                  decoration:  BoxLooseDecoration(
                      radius: Radius.circular(5),

                      strokeColorBuilder: FixedColorBuilder(
                          mainColor)),
                  codeLength: 6,

                  onCodeChanged: (code) {
                    print("OnCodeChanged : $code");
                    _otpController.text = code.toString();
                  },
                  onCodeSubmitted: (val) {
                    print("OnCodeSubmitted : $val");
                  },
                ),

                SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  decoration: customInputDecoration(
                      context
                      , AppLocalizations.of(context)!.password, AppLocalizations.of(context)!.newPassword),
                  keyboardType: TextInputType.visiblePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!
                          .pleaseEnterYourPhoneNumber;
                    }
                    return   null;
                  },
                ),


                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        maximumSize:    Size(mediaQueryWidth(context)*.9, 50),
                        fixedSize:   Size(mediaQueryWidth(context)*.7, 45),
                        minimumSize:    Size(mediaQueryWidth(context)*.9, 40),
                        backgroundColor: Color(0xFF212224),
                        foregroundColor: Colors.white, elevation: 0),
                    onPressed: _resetPassword,
                    child: Text(AppLocalizations.of(context)!.resetPassword),
                  ),
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }


}

