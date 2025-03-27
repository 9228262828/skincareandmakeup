import 'package:Gomla/shared/utils/app_values.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../shared/utils/app_assets.dart';

class MapPicker extends StatefulWidget {
  final Function(String) onLocationPicked;

  const MapPicker({Key? key, required this.onLocationPicked}) : super(key: key);

  @override
  _MapPickerState createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  GoogleMapController? _mapController;
  LatLng? _selectedPosition;
  String _address = '';
  BitmapDescriptor? _customPin;
  bool _isLocationMoved = false; // Flag to track if the user has moved the map
  bool _isLoadingLocation = false; // Flag for the loading state

  @override
  void initState() {
    super.initState();
    _loadCustomPin(); // ✅ Load custom pin
    _getCurrentLocation(); // ✅ Get current location
  }

  // ✅ Load Custom Pin Image
  Future<void> _loadCustomPin() async {
    _customPin = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/pin.png', // Path to the pin in assets folder
    );
  }

  // ✅ Get Current Location
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _selectedPosition = LatLng(position.latitude, position.longitude);
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_selectedPosition!, 15),
    );

    _getAddressFromLatLng(_selectedPosition!);
  }

  // ✅ Convert LatLng to Address
  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _address = "${place.street}, ${place.locality}, ${place.country}";
        });
      }
    } catch (e) {
      print("Error getting address: $e");
    }
  }

  // ✅ Move Camera Back to User's Location
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
        centerTitle: true,
        title: Image(
          image: AssetImage(
            ImageAssets.logoWhite,
          ),
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
        automaticallyImplyLeading: false,
        leadingWidth: MediaQuery.of(context).size.width * 0.2,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // ✅ Google Map with Camera Move Handling inside Column
          Column(
            children: [
              Expanded(
                child: GoogleMap(
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
                      _isLocationMoved =
                          true; // Set flag when user moves the map
                    });
                  },
                  onCameraIdle: () {
                    if (_selectedPosition != null) {
                      _getAddressFromLatLng(_selectedPosition!);
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF212224),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    side: BorderSide.none,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    if (_selectedPosition != null) {
                      widget.onLocationPicked(_address);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    AppLocalizations.of(context)!.confirm_location,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),

          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              child: Icon(
                Icons.location_pin,
                size: 45,
                color: Colors.red,
              ),
            ),
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
            )
        ],
      ),
    );
  }
}
