import 'package:Gomla/contstants.dart';
import 'package:Gomla/screens/add_new_adress_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../shared/utils/app_values.dart';

class MapPicker extends StatefulWidget {
  final bool isFromAddAddress;
  final Function(String address, String city, String state, String country, String postcode,) onLocationPicked;

  const MapPicker({Key? key, required this.onLocationPicked, required this.isFromAddAddress}) : super(key: key);

  @override
  _MapPickerState createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  GoogleMapController? _mapController;
  LatLng? _selectedPosition;
  String _address = '';
  String _postalCode = '';
  String _country = '';
  String _state = '';
  String _city = '';
  BitmapDescriptor? _customPin;
  bool _isLocationMoved = false;
  bool _isLoadingLocation = false; // Flag for the loading state

  @override
  void initState() {
    super.initState();
    _loadCustomPin();
    _getCurrentLocation();
  }

  Future<void> _loadCustomPin() async {
    _customPin = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/pin.png',
    );
  }

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

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        print(place);
        print(place.street);
        print(place.subLocality);
        print(place.locality);
        print(place.country);
        print(place.administrativeArea);
        print(place.isoCountryCode);
        print(place.subLocality);
        print(place.subAdministrativeArea);
        print(place.subThoroughfare);
        setState(() {
          _address = "${place.street}, ${place.locality}, ${place.country}";
          _postalCode = "${place.postalCode}";
          _country = "${place.country}";
          _state = "${place.locality}";
          _city = "${place.administrativeArea}";
        });
      }
    } catch (e) {
      print("Error getting address: $e");
    }
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
        centerTitle: true,
        title: Image(
          image: AssetImage('assets/app_icon.png'),
          fit: BoxFit.cover,
          height: MediaQuery.of(context).size.height * 0.04,
        ),
        automaticallyImplyLeading:  false,
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
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _selectedPosition ?? LatLng(23.8859, 45.0792)
                        ,
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
                          size: 20, // Adjust size as needed
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
                  onPressed: () {
                    if (_selectedPosition != null) {
                      // Print all address details before navigating
                      print("Address: $_address");
                      print("City: $_city");
                      print("State: $_state");
                      print("Country: $_country");
                      print("Postal Code: $_postalCode");

                  ! widget.isFromAddAddress? Navigator.pop(context):
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddAddressScreen(
                            address: _address,
                            city: _city,
                            state: _state,
                            country: _country,
                            postcode: _postalCode,
                          ),
                        ),
                      );
                    }
                  },
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
            )
        ],
      ),
    );
  }
}
