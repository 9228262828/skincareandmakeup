import 'package:Gomla/shared/utils/app_values.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../contstants.dart';
import '../models/adress_model.dart'; // Address model
import '../screens/edit_address_scree.dart';
import '../screens/map_picker.dart';
import '../screens/add_new_adress_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddressScreen extends StatefulWidget {
  AddressScreen({Key? key}) : super(key: key);

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  List<Address> _addresses = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  // Function to fetch addresses from the API
  Future<void> _fetchAddresses() async {
    setState(() {
      _isLoading = true;
    });
    String _tokenKey = 'auth_token';

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_tokenKey);

    try {
      final response = await http.get(
        Uri.parse('https://gomla.sa/wp-json/multi-shipping/v1/addresses'),
        headers: {
          "gomlaauth": 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);

        // Since the response is directly a list, no need for a 'data' key
        if (data is List) {
          setState(() {
            _addresses =
                data.map((address) => Address.fromJson(address)).toList();
          });
        } else {
          print("Invalid response structure");
          setState(() {
            _addresses = [];
          });
        }
      } else {
        print('Failed to fetch addresses. Status code: ${response.body}');
        setState(() {
          _addresses = [];
        });
      }
    } catch (e) {
      print('Error fetching addresses: $e');
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
              AppLocalizations.of(context)!.addresses,
              style: TextStyle(
                  color: mainColor, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: mediaQueryWidth(context) * 0.25),

          ],
        ),
        leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.only(left: 0.0, right: 8.0),
              child: Icon(Icons.arrow_back_ios, color: mainColor, size: 20),
            )),
      ),
      backgroundColor:  Colors.grey.shade200,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color:  mainColor,))
            : _addresses.isNotEmpty
                ? Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapPicker(              isFromAddAddress: true,

                                onLocationPicked: (address, city, state, country, postcode) {
                                   print('Picked Address: $address');
                                  print('City: $city');
                                  print('State: $state');
                                  print('Country: $country');
                                  print('Postal Code: $postcode');
                                },
                              ),
                            ),
                          );

                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: Color(0xFF212224)),
                            color: Colors.transparent,
                          ),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.06,
                          child: Center(
                              child: Text(
                            AppLocalizations.of(context)!.add_new_address,
                            style: TextStyle(
                                color: Color(0xFF212224),
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          )),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _addresses.length,
                          itemBuilder: (context, index) {
                            final address = _addresses[index];

                            // Define the border color for the first card
                            Color borderColor = index == 0 ? mainColor: Color(0xFFEAEAEA);

                            return Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(
                                  color: borderColor, // Apply the yellow border for the first item
                                  width: 1.0,
                                ),
                              ),
                              margin: EdgeInsets.symmetric(vertical: 8),
                              elevation: 0,
                              child: ListTile(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.map_outlined, color: Colors.black),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditAddressScreen(address: address),
                                          ),
                                        ).then((_) {
                                          // After popping back from EditAddressScreen, refresh the address list
                                          _fetchAddresses();
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!.edit_address,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Icon(
                                            Icons.edit,
                                            size: 16,
                                            color: Colors.black,
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Divider(thickness: .5),
                                    Row(
                                      children: [
                                        Text(
                                          "${AppLocalizations.of(context)!.userName}:   ",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          address.firstName + " " + address.lastName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${AppLocalizations.of(context)!.address}:   ",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            address.address1,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                            maxLines: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          "${AppLocalizations.of(context)!.userName}:   ",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          address.phone,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.add_new_address,
                          style: TextStyle(
                              color: Color(0xFF212224),
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapPicker(              isFromAddAddress: true,

                                  onLocationPicked: (address, city, state, country, postcode) {
                                    print('Picked Address: $address');
                                    print('City: $city');
                                    print('State: $state');
                                    print('Country: $country');
                                    print('Postal Code: $postcode');
                                  },
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: Color(0xFF212224)),
                              color: Colors.transparent,
                            ),
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.06,
                            child: Center(
                                child: Text(
                              AppLocalizations.of(context)!.add_new_address,
                              style: TextStyle(
                                  color: Color(0xFF212224),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            )),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
