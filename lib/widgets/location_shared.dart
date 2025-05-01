import 'package:Gomla/screens/main_screen.dart';
import 'package:Gomla/screens/map_picker.dart';
import 'package:Gomla/shared/utils/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

import '../contstants.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../shared/components/toast_component.dart';

const String _kSavedAddressKey = 'saved_address';

class AddressPickerField extends StatefulWidget {
  final String? initialAddress;
  final void Function(String address)? onAddressChanged;

  const AddressPickerField({
    Key? key,
    this.initialAddress,
    this.onAddressChanged,
  }) : super(key: key);

  @override
  State<AddressPickerField> createState() => _AddressPickerFieldState();
}

class _AddressPickerFieldState extends State<AddressPickerField> {
  String? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
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


  Future<void> _loadSavedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAddress = prefs.getString(_kSavedAddressKey);

    if (savedAddress != null && savedAddress.isNotEmpty) {
      setState(() {
        _selectedAddress = savedAddress;
      });
    } else if (widget.initialAddress != null) {
      setState(() {
        _selectedAddress = widget.initialAddress;
      });
    }
  }

  void _openMapPicker() async {
    // Step 1: Check if location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServiceDialog();
      return;
    }

    // Step 2: Check and request permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      showToast(
        text: AppLocalizations.of(context)!.locationPermissionDenied,
        state: ToastStates.WARNING,
      );
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      showToast(
        text: AppLocalizations.of(context)!.locationPermissionPermanentlyDenied,
        state: ToastStates.ERROR,
      );
      await openAppSettings(); // From permission_handler package
      return;
    }

    // Step 3: All good → Open map picker
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );

    // Step 4: Handle result
    if (result != null && result['address'] != null) {
      final newAddress = result['address'];

      setState(() {
        _selectedAddress = newAddress;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSavedAddressKey, newAddress);

      widget.onAddressChanged?.call(newAddress);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: mainColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: mainColor, size: 18),
          const SizedBox(width: 2),
          Expanded(
            child: GestureDetector(
              onTap: _openMapPicker,
              child: Text(
                _selectedAddress?.isNotEmpty == true
                    ? _selectedAddress!
                    : AppLocalizations.of(context)!.deliveryTo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Icon(Icons.keyboard_arrow_down_sharp, color: mainColor, size: 22),
        ],
      ),
    );
  }
}

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({Key? key}) : super(key: key);

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedPosition;
  String _address = '';
  String _city = '';
  String _state = '';
  String _country = '';
  String _postcode = '';
  bool _isLocationMoved = false;
  bool _isLoading = true;
  bool _isLoadingLocation = false; // Flag for the loading state

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _selectedPosition = LatLng(position.latitude, position.longitude);
    setState(() {
      _isLoading = false;
    });
    _mapController
        ?.animateCamera(CameraUpdate.newLatLngZoom(_selectedPosition!, 16));
    _getAddressFromLatLng(_selectedPosition!);
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        setState(() {
          _address = "${place.street}, ${place.locality}, ${place.country}";
          _city = place.locality ?? '';
          _state = place.administrativeArea ?? '';
          _country = place.country ?? '';
          _postcode = place.postalCode ?? '';
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _confirmLocation() {
    Navigator.pop(context, {
      'address': _address,
      'city': _city,
      'state': _state,
      'country': _country,
      'postcode': _postcode,
    });
  }

  void _moveToCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true; // Show loading when moving the location
    });

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Set the position back to the user's current location
    setState(() {
      _selectedPosition = LatLng(position.latitude, position.longitude);
    });

    // Animate the camera back to the user's current location
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_selectedPosition!, 15),
    );

    setState(() {
      _isLocationMoved = false; // Reset the location moved flag
      _isLoadingLocation = false; // Hide loading after the camera has moved
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:  false,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Image(
          image: AssetImage('assets/app_icon.png'),
          fit: BoxFit.cover,
          height: MediaQuery.of(context).size.height * 0.04,
        ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: _isLoading
          ?  Center(child: CircularProgressIndicator(color: mainColor))
          : Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Stack(
                  children: [
                    _selectedPosition == null
                        ? const Center(child: CircularProgressIndicator())
                        : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _selectedPosition!,
                        zoom: 15,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      onCameraMove: (position) {
                        setState(() {
                          _selectedPosition = position.target;
                          _isLocationMoved = true;
                        });
                      },
                      onCameraIdle: () {
                        if (_selectedPosition != null) {
                          _getAddressFromLatLng(_selectedPosition!);
                        }
                      },
                    ),
                    Align(
                      alignment: Alignment.center, // This centers the icon
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 100),
                        child: Icon(
                          Icons.location_on_rounded,
                          size: 22, // Adjust size as needed
                          color: mainColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child:ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF212224),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    side: BorderSide.none,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed:
                  _confirmLocation,
                  child: Text(
                    AppLocalizations.of(context)!.confirm_location,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),


              ),
            ],
          ),

          Positioned(
            top: mediaQueryHeight(context) * 0.02,
            left: 20,
            right: 20,
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.black,
                      size: 22,
                    ),
                    Expanded(
                      child: Text(
                        _address.isEmpty ? '' : _address,
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLocationMoved)
            AppLocalizations.of(context)!.localeName == 'ar'
                ? Positioned(
              bottom: MediaQuery.of(context).size.height *
                  0.1, // Adjust based on height
              right: 15, // Left for Arabic

              child: IconButton(
                onPressed:
                _moveToCurrentLocation, // Move back to current location
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                icon: _isLoadingLocation
                    ? CircularProgressIndicator(color: Colors.black)
                    : Row(
                  children: [
                    Icon(
                      Icons.my_location,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      AppLocalizations.of(context)!
                          .find_my_location,
                      style: const TextStyle(
                          color: Colors.black, fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
                : Positioned(
              bottom: MediaQuery.of(context).size.height *
                  0.1, // Adjust based on height
              left: 15, // Left for Arabic
              child: IconButton(
                onPressed:
                _moveToCurrentLocation, // Move back to current location
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                icon: _isLoadingLocation
                    ? CircularProgressIndicator(color: Colors.black)
                    : Row(
                  children: [
                    Icon(
                      Icons.my_location,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      AppLocalizations.of(context)!
                          .find_my_location,
                      style: const TextStyle(
                          color: Colors.black, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}