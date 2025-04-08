import 'dart:async';

import 'package:Gomla/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../contstants.dart';
import '../main.dart';
import '../models/banner.dart';
import '../providers/banner_repo.dart';
import '../services/auth_service.dart';
import '../shared/utils/app_assets.dart';
import '../shared/utils/app_values.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class VerifyPhoneScreen extends StatefulWidget {
  final String phone;

  const VerifyPhoneScreen({
    super.key,
    required this.phone,

  });

  @override
  State<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  List<Bannerr> _banners = [];
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



  void _listenOtp() async {
    await SmsAutoFill().listenForCode();
    print("OTP Listen is called");
  }
  @override
  void initState() {
    _listenOtp();
    super.initState();
     _startResendTimer();
  }


  Timer? _resendTimer;
  int _resendSeconds = 120;
  bool _canResend = false;
  void _startResendTimer() {
    setState(() {
      _resendSeconds = 120;
      _canResend = false;
    });

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendSeconds == 0) {
        timer.cancel();
        setState(() {
          _canResend = true;
        });
      } else {
        setState(() {
          _resendSeconds--;
        });
      }
    });
  }
  @override
  void dispose() {
    _resendTimer?.cancel();
    SmsAutoFill().unregisterListener();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor:   Colors.white,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(AppLocalizations.of(context)!.verifyPhone,style: TextStyle(color: Colors.black,fontSize: 16),),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Directionality(
          textDirection: TextDirection.ltr,

          child: SingleChildScrollView(
            child: Column(

              children: [
                SizedBox(
                  height: mediaQueryHeight(context) * 0.04,
                ),
                Image.asset(ImageAssets.logoWhite,
                    height: mediaQueryHeight(context) * 0.1,
                    width: mediaQueryWidth(context) * 0.7),
                  SizedBox(
                    height: mediaQueryHeight(context) * 0.1,
                  ),
                Text("${AppLocalizations.of(context)!.please_enter_6_numbers}",
              style:  TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),

                ),
                PhoneNumberField1(
                  phone: widget.phone,),
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


                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        maximumSize:    Size(mediaQueryWidth(context)*.9, 50),
                        fixedSize:   Size(mediaQueryWidth(context)*.7, 45),
                        minimumSize:    Size(mediaQueryWidth(context)*.9, 40),
                        backgroundColor: Color(0xFF212224),
                                        foregroundColor: Colors.white, elevation: 0),
                                    onPressed: () {
                                      print(_otpController.text);
                                      print(widget.phone);
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RegistrationScreen(otp: _otpController.text,phone : widget.phone),));
                                    },
                                    child: Text(AppLocalizations.of(context)!.verifyOtp,style:  TextStyle(fontSize: 16,fontWeight: FontWeight.w500,),),
                                  ),
                    ),

                TextButton(
                  onPressed: _canResend
                      ? () {
                    _otpController.clear();
                    _checkPhone();
                    _startResendTimer();
                  }
                      : null, // Disable button if timer is running
                  child: Text(
                    _canResend
                        ? AppLocalizations.of(context)!.resend_otp
                        : "${AppLocalizations.of(context)!.resend_otp} ($_resendSeconds)",
                    style: TextStyle(
                      color: _canResend ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
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


class PhoneNumberField1 extends StatefulWidget {
  final String phone;

  PhoneNumberField1({required this.phone});

  @override
  _PhoneNumberField1State createState() => _PhoneNumberField1State();
}

class _PhoneNumberField1State extends State<PhoneNumberField1> {
  @override
  Widget build(BuildContext context) {
    String formattedPhoneNumber = _formatPhoneNumber(widget.phone);

    return Text(
      formattedPhoneNumber,
      style: TextStyle(fontSize: 16),
    );
  }

  String _formatPhoneNumber(String phone) {
    // Get the current locale
    String countryCode = '+966'; // Default to Saudi Arabia code
    if (Localizations.localeOf(context).languageCode == 'ar') {
      return '$countryCode$phone'; // If the language is Arabic, just concatenate the number with the code
    } else {
      // Default to international format
      return '$countryCode$phone'; // Format for other languages (you can adjust as needed)
    }
  }
}
