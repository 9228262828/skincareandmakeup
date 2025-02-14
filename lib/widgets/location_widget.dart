import 'package:Gomla/contstants.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationWidget extends StatefulWidget {
  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  String _address = "";
  String _permissionStatus = "";
  bool _isLocationFetched = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
  }

  Future<void> _loadSavedLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedAddress = prefs.getString('saved_address');
    if (savedAddress != null) {
      setState(() {
        _address = savedAddress;
        _isLocationFetched = true;
      });
    }
  }

  Future<void> _getAddressFromLatLng() async {
    if (_isLocationFetched) return; // Stop execution if location is already fetched

    await _requestLocationPermission();

    if (_permissionStatus == AppLocalizations.of(context)!.locationPermissionGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;

          setState(() {
            _address = "${AppLocalizations.of(context)!.deliveryTo} ${place.street}";
            _isLocationFetched = true;
          });

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('saved_address', _address);
        } else {
          setState(() {
            _address = AppLocalizations.of(context)!.addressNotAvailable;
          });
        }
      } catch (e) {
        setState(() {
          _address = "${AppLocalizations.of(context)!.errorRetrievingAddress}: $e";
        });
      }
    } else {
      setState(() {
        _address = AppLocalizations.of(context)!.pleaseAllowLocationAccess;
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      _showLocationServiceDialog();
      return;
    }
    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      setState(() {
        _permissionStatus = AppLocalizations.of(context)!.locationPermissionGranted;
      });
    } else if (status.isDenied) {
      setState(() {
        _permissionStatus = AppLocalizations.of(context)!.locationPermissionDenied;
      });
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _permissionStatus = AppLocalizations.of(context)!.locationPermissionPermanentlyDenied;
      });
      openAppSettings();
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
              Geolocator.openLocationSettings();
            },
            child: Text(AppLocalizations.of(context)!.openSettings, style: TextStyle(color: mainColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _getAddressFromLatLng,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: mainColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on, color: mainColor, size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                _address.isEmpty ? AppLocalizations.of(context)!.deliveryTo : " $_address",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
