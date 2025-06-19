import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../contstants.dart';
import '../models/adress_model.dart';
import 'package:Gomla/shared/components/toast_component.dart';
import '../screens/adress_screen.dart';
import '../screens/edit_address_screen.dart';

class LocationWidget extends StatefulWidget {
  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  String _address = "";
  bool _isLoading = false;
  List<Address> _addresses = [];

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


   Future<void> _fetchAddresses() async {
    setState(() {
      _isLoading = true;
    });
    String _tokenKey = 'auth_token';

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_tokenKey);

    try {
      final response = await http.get(
        Uri.parse('https://gomla.egymetrix.net/wp-json/multi-shipping/v1/addresses'),
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
            _addresses = data.map((address) => Address.fromJson(address)).toList();
            if (_addresses.isNotEmpty) {
              _address = _addresses[0].address1;  // Set the first address's address1 as the default
            }
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
  void initState() {
    super.initState();
    _fetchAddresses();
  }
  void _showLocationPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.locationPermissionPermanentlyDenied),
        content: Text(AppLocalizations.of(context)!.enableLocationFromSettings),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Geolocator.openAppSettings();
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: mainColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: mainColor, size: 18),
          SizedBox(width: 2),
          Expanded(
            child: GestureDetector(
                onTap: () async {
                  // Step 1: Check if location services are enabled
                  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                  if (!serviceEnabled) {
                    _showLocationServiceDialog(); // Ask user to enable GPS
                    return;
                  }

                  // Step 2: Check permission
                  LocationPermission permission = await Geolocator.checkPermission();

                  if (permission == LocationPermission.denied) {
                    permission = await Geolocator.requestPermission();
                  }

                  // Step 3: If permanently denied → open app settings
                  if (permission == LocationPermission.deniedForever) {
                    _showLocationPermissionDeniedDialog(); // custom dialog to open settings
                    return;
                  }

                  // Step 4: If permission is granted → continue
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddressScreen()),
                  );
                },
              child: Text(
                _addresses.isEmpty
                    ? AppLocalizations.of(context)!.deliveryTo
                    : _address,  // Display selected address or a fallback message
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Icon(Icons.keyboard_arrow_down_sharp, color: mainColor, size: 22),
        ],
      ),
    );
  }
}
