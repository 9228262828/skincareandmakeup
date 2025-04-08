import 'dart:convert';

import 'package:Gomla/widgets/phone_field.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../contstants.dart';
import '../widgets/stackover.dart';
import 'main_screen.dart';
import 'map_picker.dart';
import '../shared/components/toast_component.dart';
import '../shared/global/app_theme.dart';
import '../shared/utils/app_values.dart';

class AddAddressScreen extends StatefulWidget {
  final String address;
  final String city;
  final String state;
  final String country;
  final String postcode;

  AddAddressScreen({
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.postcode,
  });
  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _companyController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _address1Controller.text = widget.address;
    _cityController.text = widget.city;
    _stateController.text = widget.state;
    _countryController.text = widget.country;
    _postcodeController.text = widget.postcode;
  }

  bool _isLoading = false;

  Future<void> _submitAddress() async {
    setState(() {
      _isLoading = true;
    });

    final data = {
      'first_name': _firstNameController.text,
      'last_name': _lastNameController.text,
      'company': _companyController.text,
      'address_1': _address1Controller.text, // Address 1 from MapPicker
      'address_2': _address2Controller.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'postcode': _postcodeController.text,
      'country': _countryController.text,
      'phone': _phoneController.text,
      'notes': _notesController.text,
    };
    String _tokenKey = 'auth_token';

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_tokenKey);
    final response = await http.post(
      Uri.parse('https://gomla.sa/wp-json/multi-shipping/v1/addresses'),
      headers: {
        'Content-Type': 'application/json',
        "gomlaauth": 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      print(response.body);
      showToast(
          text: AppLocalizations.of(context)!.addressAddedSuccessfully,
          state: ToastStates.SUCCESS);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => MainScreen(
                    index: 0,
                  )),
          (route) => false);
    } else {
      print(response.body);
      final error = jsonDecode(response.body);
      showToast(text: error['message'], state: ToastStates.ERROR);
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.locationServicesDisabled),
        content: Text(AppLocalizations.of(context)!.enableLocationServices),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Geolocator.openLocationSettings(); // Open location settings
            },
            child: Text(
              AppLocalizations.of(context)!.openSettings,
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          showToast(
            text: 'Location permission denied!',
            state: ToastStates.WARNING,
          );
          await Geolocator.openAppSettings();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        showToast(
          text: 'Location permission permanently denied!',
          state: ToastStates.ERROR,
        );
        await openAppSettings();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (position != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapPicker(
              isFromAddAddress: true,
              onLocationPicked: (
                _address,
                _city,
                _state,
                _country,
                _postalCode,
              ) {
                setState(() {
                  _address1Controller.text = _address;
                  _stateController.text = _state;
                  _countryController.text = _country;
                  _postcodeController.text = _postalCode;
                  _cityController.text = _city;
                });
              },
            ),
          ),
        );
      } else {
        showToast(
          text: 'Failed to get location!',
          state: ToastStates.ERROR,
        );
      }
    } catch (e) {
      showToast(
        text: 'Failed to get location!',
        state: ToastStates.ERROR,
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
      appBar: AppBar(
        centerTitle: true,
        surfaceTintColor: Color(0xFF212224),
        backgroundColor: Color(0xFF212224),
        title: Row(
          children: [
            Text(
              AppLocalizations.of(context)!.add_new_address,
              style: TextStyle(
                  color: mainColor, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: mediaQueryWidth(context) * 0.15),
          ],
        ),
        leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.only(left: 0.0, right: 8.0),
              child: Icon(Icons.arrow_back_ios, color: mainColor, size: 20),
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                Text(
                  AppLocalizations.of(context)!.addressInformation,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _address1Controller,
                        decoration: customInputDecoration(
                            prefixIcon:
                                Localizations.localeOf(context).languageCode ==
                                        'ar'
                                    ? Icon(
                                        Icons.location_on_outlined,
                                        size: 20,
                                        color: Color(0xFFDC9D1E),
                                      ) // Prefix for Arabic
                                    : Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: Icon(
                                          Icons.location_on_outlined,
                                          size: 20,
                                          color: Color(0xFFDC9D1E),
                                        ),
                                      ),
                            context,
                            AppLocalizations.of(context)!.address,
                            AppLocalizations.of(context)!.address),
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Address Line 1';
                          }
                          return null;
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: _getCurrentLocation,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          AppLocalizations.of(context)!.edit,
                          style: TextStyle(
                              color: mainColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _address2Controller,
                  decoration: customInputDecoration(
                      prefixIcon:
                          Localizations.localeOf(context).languageCode == 'ar'
                              ? Icon(
                                  Icons.location_on_outlined,
                                  size: 20,
                                  color: Color(0xFFDC9D1E),
                                ) // Prefix for Arabic
                              : Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Icon(
                                    Icons.location_on_outlined,
                                    size: 20,
                                    color: Color(0xFFDC9D1E),
                                  ),
                                ),
                      context,
                      AppLocalizations.of(context)!.address2,
                      AppLocalizations.of(context)!.address2),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _cityController,
                  decoration: customInputDecoration(
                      prefixIcon:
                          Localizations.localeOf(context).languageCode == 'ar'
                              ? Icon(
                                  Icons.location_city,
                                  size: 20,
                                  color: Color(0xFFDC9D1E),
                                ) // Prefix for Arabic
                              : Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Icon(
                                    Icons.location_city,
                                    size: 20,
                                    color: Color(0xFFDC9D1E),
                                  ),
                                ),
                      context,
                      AppLocalizations.of(context)!.city,
                      AppLocalizations.of(context)!.city),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.pleaseEnterYourCity;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _stateController,
                  decoration: customInputDecoration(
                      prefixIcon:
                          Localizations.localeOf(context).languageCode == 'ar'
                              ? Icon(
                                  Icons.location_city_sharp,
                                  size: 20,
                                  color: Color(0xFFDC9D1E),
                                ) // Prefix for Arabic
                              : Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Icon(
                                    Icons.location_city_sharp,
                                    size: 20,
                                    color: Color(0xFFDC9D1E),
                                  ),
                                ),
                      context,
                      AppLocalizations.of(context)!.state,
                      AppLocalizations.of(context)!.state),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return ' ';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 25),
                Text(
                  AppLocalizations.of(context)!.personalInformation,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _firstNameController,
                  decoration: customInputDecoration(
                      prefixIcon:
                          Localizations.localeOf(context).languageCode == 'ar'
                              ? Icon(
                                  Icons.person,
                                  size: 20,
                                  color: Color(0xFFDC9D1E),
                                ) // Prefix for Arabic
                              : Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Icon(
                                    Icons.person_2_rounded,
                                    size: 20,
                                    color: Color(0xFFDC9D1E),
                                  ),
                                ),
                      context,
                      AppLocalizations.of(context)!.firstName,
                      AppLocalizations.of(context)!.firstName),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!
                          .pleaseEnterYourFirstName;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _lastNameController,
                  decoration: customInputDecoration(
                      prefixIcon:
                          Localizations.localeOf(context).languageCode == 'ar'
                              ? Icon(
                                  Icons.person,
                                  size: 20,
                                  color: Color(0xFFDC9D1E),
                                ) // Prefix for Arabic
                              : Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Icon(
                                    Icons.person_2_rounded,
                                    size: 20,
                                    color: Color(0xFFDC9D1E),
                                  ),
                                ),
                      context,
                      AppLocalizations.of(context)!.lastName,
                      AppLocalizations.of(context)!.lastName),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!
                          .pleaseEnterYourLastName;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                PhoneNumberField(
                  phoneController: _phoneController,
                ),
                SizedBox(height: 25),
                Text(
                  "${AppLocalizations.of(context)!.name_of_address}  ${AppLocalizations.of(context)!.optional}",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 15),

                StackOver(
                  notesController: _notesController,
                ),
                SizedBox(height: 20),

                     ElevatedButton(
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
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _submitAddress(); // Call update function
                          }
                        },
                        child:
                        _isLoading
                            ? CircularProgressIndicator(color:  mainColor,): // Show loading indicator while updating
                            Text(AppLocalizations.of(context)!.add_new_address),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



