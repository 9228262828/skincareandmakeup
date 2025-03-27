import 'package:Gomla/Engin/skincare.dart';
import 'package:Gomla/contstants.dart';
import 'package:Gomla/main.dart';
import 'package:Gomla/shared/components/toast_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../Engin/ads.dart';
import '../Engin/pdf_screen.dart';
import '../models/banner.dart';
import '../widgets/app_bar.dart';
import '../widgets/circleBrands.dart';
import '../widgets/crousal_container.dart';
import '../widgets/grid_offers.dart';
import '../widgets/home_banner_slider.dart';
import '../widgets/location_widget.dart';
import '../widgets/product_home_widget.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'lang_screen.dart';
import 'login_screen.dart';
import 'map_picker.dart';

class HomeScreen extends StatefulWidget {
  final Function ontap;
  final List<Bannerr> banners;

  const HomeScreen({super.key, required this.banners, required this.ontap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;

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
              onLocationPicked: (address) {
                print('Selected Address: $address');
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
    Bannerr banner;
    return Scaffold(
      appBar: CustomAppBar(
        title: "",
        home: true,
      ),
      backgroundColor: Colors.grey.shade200,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /*  buildCategoriesList(context),*/


            GestureDetector(
                onTap: () {
                  _getCurrentLocation();
                },
                child: LocationWidget()),
            const SizedBox(
              height: 6,
            ),
            HomeBannerSlider(
              banners: widget.banners,
            ),

            const SizedBox(
              height: 10,
            ),
            /*  CircleBrands(),*/
            GridOffers(),
            const SizedBox(
              height: 10,
            ),
            const CruosalContainer(),
            ProductHomeWidget(
              title: AppLocalizations.of(context)!.bestSellers,
              categoryId: 1214,
              specialProducts: false,
              bestSellers: true,
              bestRatings: false,
              allNeedsGrooming: false,
              exclusiveDeals: false,
              nearlyArrived: false,
              type: 'bestSellers',
              isLink: true,
            ),
            const SizedBox(
              height: 10,
            ),
            const CruosalContainer2(),
            const SizedBox(
              height: 5,
            ),
            ProductHomeWidget(
              title: AppLocalizations.of(context)!.exclusiveDeals,
              categoryId: 153,
              specialProducts: false,
              bestSellers: false,
              bestRatings: false,
              allNeedsGrooming: false,
              exclusiveDeals: true,
              nearlyArrived: false,
              type: 'exclusiveDeals',
              isLink: false,
            ),
            const SizedBox(height: 10.0),
            GridOffers2(),
            ProductHomeWidget(
              title: AppLocalizations.of(context)!.healthAndBeauty,
              categoryId: 53,
              specialProducts: true,
              bestSellers: false,
              bestRatings: false,
              allNeedsGrooming: false,
              exclusiveDeals: false,
              nearlyArrived: false,
              type: 'healthAndBeauty',
              isLink: false,
            ),
            if (widget.banners.length > 4)
              IndexedBannerWidget(index: 8, banners: widget.banners),
            const SizedBox(
              height: 10,
            ),

            IndexedBannerWidget(index: 7, banners: widget.banners),

            const SizedBox(
              height: 10,
            ),

            IndexedBannerWidget(index: 6, banners: widget.banners),
            const SizedBox(height: 10.0),
//
            ProductHomeWidget(
              title: AppLocalizations.of(context)!.bestRatings,
              categoryId: 229,
              specialProducts: false,
              bestSellers: false,
              bestRatings: true,
              allNeedsGrooming: false,
              exclusiveDeals: false,
              nearlyArrived: false,
              type: 'bestRatings',
              isLink: true,
            ),

            const SizedBox(height: 8.0),

            if (widget.banners.length > 1)
              IndexedBannerWidget(index: 5, banners: widget.banners),
            const SizedBox(height: 10.0),

            if (widget.banners.length > 2)
              IndexedBannerWidget(index: 4, banners: widget.banners),
            const SizedBox(height: 8.0),

            CircleBrands(
              ontap: widget.ontap,
            ),

            IndexedBannerWidget(index: 2, banners: widget.banners),
            const SizedBox(height: 5.0),

            ProductHomeWidget(
              title: AppLocalizations.of(context)!.specialProducts,
              categoryId: 53,
              specialProducts: true,
              bestSellers: false,
              bestRatings: false,
              allNeedsGrooming: false,
              exclusiveDeals: false,
              nearlyArrived: false,
              type: 'specialProducts',
              isLink: false,
            ),

            ProductHomeWidget(
              title: AppLocalizations.of(context)!.recentlyViewedProducts,
              categoryId: 53,
              specialProducts: true,
              bestSellers: false,
              bestRatings: false,
              allNeedsGrooming: false,
              exclusiveDeals: false,
              nearlyArrived: false,
              type: 'recentlyViewedProducts',
              isLink: false,
            ),

            ProductHomeWidget(
              title: AppLocalizations.of(context)!.relatedProductss,
              categoryId: 53,
              specialProducts: false,
              bestSellers: false,
              bestRatings: false,
              allNeedsGrooming: true,
              exclusiveDeals: false,
              nearlyArrived: false,
              type: 'relatedProducts',
              isLink: false,
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        alignment: Alignment.center,
        children: [
          // Shimmer effect in the background
          Shimmer.fromColors(
            baseColor: mainColor.withOpacity(0.5),
            highlightColor: Colors.white,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade300,
              ),
            ),
          ),
          FloatingActionButton(
            backgroundColor: Colors.transparent,
            shape: const CircleBorder(),
            tooltip: AppLocalizations.of(context)!.skinCare,
            elevation: 0,
            child: Image.asset(
              "assets/skin.png",
              width: 55,
            ),
            onPressed: () async {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SkincareDetect()));
              /*  // Check for token before navigating
              final pref = await SharedPreferences.getInstance();
              final String? jwtToken = pref.getString('auth_token');

              if (jwtToken != null && jwtToken.isNotEmpty) {
                // ✅ Token exists, navigate to AdPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdPage(
                      isbeforetest: true,
                      reports: {},
                      skinAnalysisData: {},
                      capturedFeatures: [],
                      scores: {},
                    ),
                  ),
                );
              } else {
               showToast(text:  AppLocalizations.of(context)!.pleaseLogin, state: ToastStates.ERROR);
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen())); // Ensure you have a named route for login
              }*/
            },
          ),
        ],
      ),
    );
  }
}
