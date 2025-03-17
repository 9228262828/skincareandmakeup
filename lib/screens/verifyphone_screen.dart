import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../contstants.dart';
import '../shared/utils/app_assets.dart';
import '../shared/utils/app_values.dart';
import 'login_screen.dart';

class VerifyPhoneScreen extends StatefulWidget {
  final String phone;
  final String email;
  final String userName;
  final String password;

  const VerifyPhoneScreen({
    super.key,
    required this.phone,
    required this.email,
    required this.userName,
    required this.password,
  });

  @override
  State<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.please_enter_6_numbers)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final data = {
      'phone': widget.phone,
      'email': widget.email,
      'username': widget.userName,
      'password': widget.password,
      'otp': _otpController.text,
    };

    print("Sending Data: $data");

    try {
      final response = await http.post(
        Uri.parse('https://gomla.sa/wp-json/custom-auth/v1/register'),
        body: data,
      );

      final responseData = json.decode(response.body);
      print("Response Data: $responseData");

      if (responseData['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful!')),
        );
        // يمكنك توجيه المستخدم إلى شاشة تسجيل الدخول
         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      } else {
        String errorMessage = responseData["message"] ?? 'Registration failed, please try again';

        // **التحقق مما إذا كان هناك قائمة `errors`**
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.verifyPhone),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Directionality(
          textDirection: TextDirection.ltr,

          child: Column(

            children: [
              SizedBox(
                height: mediaQueryHeight(context) * 0.1,
              ),
              Image.asset(ImageAssets.logoWhite,
                  height: mediaQueryHeight(context) * 0.15,
                  width: mediaQueryWidth(context) * 0.7),
                SizedBox(
                  height: mediaQueryHeight(context) * 0.1,
                ),
              Text("${AppLocalizations.of(context)!.please_enter_6_numbers}${widget.phone}",
            style:  TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
              ),
              SizedBox(height: 20),
              Pinput(
                length: 6,
                controller: _otpController,
                keyboardType: TextInputType.number,
                autofocus: true,
                defaultPinTheme: PinTheme(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    locale: Localizations.localeOf(context),
                  ),
                ),
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
                      backgroundColor: mainColor, foregroundColor: Colors.white, elevation: 0),
                                  onPressed: _register,
                                  child: Text('Verify & Register'),
                                ),
                  ),

          TextButton(onPressed:
              (){
            _otpController.clear();
                _checkPhone();
              }
              , child: Text(AppLocalizations.of(context)!.resend_otp))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkPhone() async {


      try {
        final response = await http.post(
          Uri.parse('https://gomla.sa/wp-json/custom-auth/v1/check-phone'),
          body: {'phone': widget.phone},
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          print(data); // طباعة البيانات لفحصها

          if (data['success'] == true) {
            String otp = data['otp'].toString(); // حفظ OTP
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['message'] ?? 'تم التحقق من الهاتف')),
            );

          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['message'] ?? 'فشل التحقق من الهاتف')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Phone verification failed')),
          );
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }

}
