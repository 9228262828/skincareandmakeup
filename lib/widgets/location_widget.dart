import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../contstants.dart';
import '../shared/components/toast_component.dart';

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
    if (_isLocationFetched) return;

    try {
      // ✅ التحقق من صلاحية الموقع
      Position position = await checkLocationPermission();

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _address = "${AppLocalizations.of(context)!.deliveryTo} ${place.name}";
          _isLocationFetched = true;
        });

        // ✅ حفظ العنوان في SharedPreferences
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
  }

  Future<Position> checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      _showLocationServiceDialog(); // ✅ فتح الإعدادات لو الخدمة غير مفعلة
      throw "${AppLocalizations.of(context)!.locationServicesDisabled}";
    }
    print("checkLocationPermission");

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showToast(
          text: AppLocalizations.of(context)!.locationPermissionDenied,
          state: ToastStates.WARNING,
        );
        print("locationPermissionDenied");
        // ✅ فتح الإعدادات تلقائياً إذا تم الرفض
        await Geolocator.openAppSettings();
        throw "${AppLocalizations.of(context)!.locationPermissionDenied}";
      }
    }print("locationPermissionDenied");


    if (permission == LocationPermission.deniedForever) {
      showToast(
        text: AppLocalizations.of(context)!.locationPermissionPermanentlyDenied,
        state: ToastStates.ERROR,
      );
      print("locationPermissionPermanentlyDenied");
      // ✅ فتح إعدادات التطبيق في حالة رفض دائم
      await openAppSettings();
      throw "${AppLocalizations.of(context)!.locationPermissionPermanentlyDenied}";
    }
print("locationPermissionPermanentlyDenied");
    // ✅ الحصول على الموقع الحالي أو آخر موقع محفوظ
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    ).catchError((e) async {

      final lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null) {
        print("lastPosition");
        print(lastPosition);
        return lastPosition;
      } else {
        showToast(
          text: AppLocalizations.of(context)!.locationPermissionDenied,
          state: ToastStates.ERROR,
        );
        throw "${AppLocalizations.of(context)!.locationPermissionPermanentlyDenied}";
      }
    });
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
              Geolocator.openLocationSettings(); // ✅ فتح إعدادات الموقع
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
    return GestureDetector(
      onTap: (){
        print("onTap");
        _getAddressFromLatLng();
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: mainColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on, color: mainColor, size: 18),
            SizedBox(width: 2),
            Expanded(
              child: Text(
                _address.isEmpty ? AppLocalizations.of(context)!.deliveryTo : " $_address",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, fontWeight:  FontWeight.w700),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_sharp, color: mainColor, size: 18),
          ],
        ),
      ),
    );
  }
}
