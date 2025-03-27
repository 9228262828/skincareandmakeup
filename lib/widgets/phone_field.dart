import 'package:Gomla/shared/utils/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PhoneNumberField extends StatefulWidget {
  final TextEditingController phoneController;

  PhoneNumberField({required this.phoneController});
  @override
  _PhoneNumberFieldState createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {

  String selectedCountryCode = '+966'; // Default Saudi Arabia country code
  String selectedFlag = ImageAssets.arab_flag; // Default flag

  // List of country codes and corresponding flags
  final List<Map<String, String>> countries = [
    {'code': '+966', 'flag': ImageAssets.arab_flag}, // Saudi Arabia
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side: Dropdown for country code and flag
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xFFEAEAEA),
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                color: Colors.white70,
              ),
              padding: const EdgeInsets.only(left: 8.0),
              child: DropdownButton<String>(
                underline: const Divider(color: Colors.transparent),
                value: selectedCountryCode,
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 16,
                elevation: 14,
                style: TextStyle(color: Colors.black),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCountryCode = newValue!;
                    // Find and update the flag based on the selected country code
                    selectedFlag = countries.firstWhere((country) =>
                        country['code'] == selectedCountryCode)['flag']!;
                  });
                },
                items: countries.map<DropdownMenuItem<String>>(
                    (Map<String, String> country) {
                  return DropdownMenuItem<String>(
                    value: country['code'],
                    child: Row(
                      children: [
                        Image.asset(
                          country['flag']!, // Set the flag from the list
                          width: 24,
                          height: 24,
                        ),
                        SizedBox(width: 8),
                        Text(country['code']!), // Display country code
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(width: 10),
            // Right side: Phone number input
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: TextFormField(
                  controller: widget.phoneController,
                  decoration: InputDecoration(
                    labelText: " 5xxxxxxxx",
                    labelStyle:   TextStyle(color: Color(0xFFD9D9D9)),
                    hintStyle:   TextStyle(color: Color(0xFFD9D9D9)),
                    hintText: " 5xxxxxxxx",

                    hintTextDirection: TextDirection.ltr,
                    floatingLabelBehavior:  FloatingLabelBehavior.never,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                    suffixIcon: Icon(Icons.phone_enabled,
                        size: 18, color: Color(0xFFDC9D1E)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: Color(
                            0xFFEAEAEA), // Green border when the user types
                        width: 1.5, // Border thickness
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color: Color(0xFFEAEAEA),
                          width:
                              1), // Yellow border when the field is enabled
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color: Color(0xFFEAEAEA).withOpacity(.8),
                          width: 1), // Green border when focused
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color: Colors.red,
                          width: 1), // Red border for error state
                    ),
                    errorStyle: TextStyle(
                        fontSize: 12), // Adjust the error message size
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                        9), // Allow only 9 digits
                    FilteringTextInputFormatter
                        .digitsOnly, // Allow only numbers
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
