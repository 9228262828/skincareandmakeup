import 'dart:async';

import 'package:Gomla/shared/components/toast_component.dart';
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
import '../widgets/pass_fiels.dart';
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
          Uri.parse('https://gomla.egymetrix.net/wp-json/custom-auth/v1/request-password-reset'),
          body: {
            'phone': "${_phoneController.text}" // Corrected line to send the phone as a string
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

              showToast(text: data['message'] , state: ToastStates.SUCCESS);
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
             showToast(text: data['message'], state: ToastStates.ERROR);
            }
          } catch (e) {
            // Catching FormatException or any other decoding issues
            print('Error decoding JSON: $e');
         showToast(text: e.toString(), state: ToastStates.ERROR);
          }
        } else {
          print('Error: Received status code ${response.statusCode}');
          print('Response body: ${response.body}');
          final Map<String, dynamic> data = json.decode(response.body);
          showToast(text: data['message'], state: ToastStates.ERROR);
        }
      } catch (e) {
        print('Error: $e');
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
                  isRequired: true,
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
    if (_otpController.text.length != 6 ) {

      showToast(text: AppLocalizations.of(context)!.please_enter_6_numbers, state: ToastStates.ERROR);
      return;
    }

    // Validate if the password is entered
    if (_passwordController.text.isEmpty) {

      showToast(text: AppLocalizations.of(context)!.pleaseEnterYourNewPassword, state: ToastStates.ERROR);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final data = {
      'phone': "${widget.phone}",
      'new_password': _passwordController.text,
      'otp': _otpController.text,
    };

    print("Sending Data: $data");

    try {
      final response = await http.post(
        Uri.parse('https://gomla.egymetrix.net/wp-json/custom-auth/v1/reset-password'),
        body: data,
      );

      final responseData = json.decode(response.body);
      print("Response Data: $responseData");

      if (responseData['success'] == true) {

        showToast(text: AppLocalizations.of(context)!.password_reset_successfully, state: ToastStates.SUCCESS);
        await AuthService.login(
          widget.phone,
          _passwordController.text,
        );
        Navigator.pushAndRemoveUntil(context,  (MaterialPageRoute(builder: (context) => MainScreen(

            banners: [],index: 0))), (route) => false);
      } else {
        String errorMessage = responseData["message"] ?? '';
print("Error Message: $errorMessage");
        // Check if there is an 'errors' list
        if (responseData.containsKey("errors")) {
          Map<String, dynamic> errors = responseData["errors"];
          errorMessage = errors.entries.map((e) => "${e.value}").join("\n");
        }


        showToast(text: errorMessage, state: ToastStates.ERROR);
      }
    } catch (e) {
      print("Error: $e");

      showToast(text: e.toString(), state: ToastStates.ERROR);
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
  Timer? _resendTimer;
  int _resendSeconds = 120;
  bool _canResend = false;

  @override
  void initState() {
    _listenOtp();
    super.initState();
    _startResendTimer();

  }
  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    print("unVerify Listener");
    super.dispose();
  }
  Future<void> _checkPhone() async {

setState(() {
  _isLoading = true;
});    print("+966${widget.phone}");

    try {
      final response = await http.post(
        Uri.parse('https://gomla.egymetrix.net/wp-json/custom-auth/v1/request-password-reset'),
        body: {
          'phone': "${widget.phone}" // Corrected line to send the phone as a string
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

            showToast(text: data['message'] , state: ToastStates.SUCCESS);

          } else {
            print('Error response: ${response.body}');
            final Map<String, dynamic> data = json.decode(response.body);
            showToast(text: data['message'], state: ToastStates.ERROR);
          }
        } catch (e) {
          // Catching FormatException or any other decoding issues
          print('Error decoding JSON: $e');
          showToast(text: e.toString(), state: ToastStates.ERROR);
        }
      } else {
        print('Error: Received status code ${response.statusCode}');
        print('Response body: ${response.body}');
        final Map<String, dynamic> data = json.decode(response.body);
        showToast(text: data['message'], state: ToastStates.ERROR);
      }
    } catch (e) {
      print('Error: $e');
      showToast(text: e.toString(), state: ToastStates.ERROR);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

                Text("${AppLocalizations.of(context)!.please_enter_6_numbers} ${widget.phone}",
                  style:  TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                PinFieldAutoFill(
                  currentCode: _otpController.text,
                  cursor: Cursor(
                    color: mainColor,  // تعيين لون المؤشر للون البارز
                    height: 20,
                    width: 2.0,  // جعل المؤشر أكثر سمكًا
                  ),
                  decoration: BoxLooseDecoration(
                    radius: Radius.circular(5),
                    strokeColorBuilder: FixedColorBuilder(mainColor),
                    bgColorBuilder: FixedColorBuilder(Colors.white),
                    textStyle: TextStyle(
                      color: Colors.black,  // تعيين لون النص داخل الحقل
                      fontSize: 18,         // تعيين حجم النص لرمز OTP
                    ),
                  ),
                  codeLength: 6,
                  onCodeChanged: (code) {
                    print("OnCodeChanged : $code");
                    _otpController.text = code.toString();
                  },
                  onCodeSubmitted: (val) {
                    print("OnCodeSubmitted : $val");
                  },
                    enabled: true,
                ),

                SizedBox(height: 10),
                PasswordField(
                  passwordController: _passwordController,
                  name:   AppLocalizations.of(context)!.password,
                ),


                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator(color: mainColor)
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _resetPassword();
                      }
                        print("OTP: ${_otpController.text}");
                    },
                    child: Text(AppLocalizations.of(context)!.resetPassword),
                  ),
                ),
                SizedBox(height: 10),

                TextButton(
                  onPressed: _canResend
                      ? () {
                    _otpController.clear();
                     _startResendTimer();
                    _checkPhone ();
                  }
                      : null, // Disable button if timer is running
                  child: Text(
                    _canResend
                        ? AppLocalizations.of(context)!.resend_otp
                        : "${AppLocalizations.of(context)!.resend_otp} ($_resendSeconds)",
                    style: TextStyle(
                      color: _canResend ? mainColor : Colors.grey,
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


}

