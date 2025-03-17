import 'package:Gomla/Engin/skincare.dart';
import 'package:Gomla/contstants.dart';
import 'package:Gomla/shared/components/toast_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function ontap;
  final List<Bannerr> banners;

  const HomeScreen({super.key, required this.banners, required this.ontap});

  @override
  Widget build(BuildContext context) {
    Bannerr banner;
    return Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context)!.home,home: true,),
      backgroundColor: Colors.grey.shade200,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
         /*  buildCategoriesList(context),*/

            LocationWidget(),
            const SizedBox(
              height: 6,
            ),
            HomeBannerSlider(
              banners: banners,
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
              allNeedsGrooming:false ,
              exclusiveDeals: false,
              nearlyArrived: false,
              type:  'bestSellers',
              isLink:  true,
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
              bestSellers:false ,
              bestRatings:false ,
              allNeedsGrooming:false ,
              exclusiveDeals: true,
              nearlyArrived: false,
              type:  'exclusiveDeals',
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
            if (banners.length > 4)
            IndexedBannerWidget(index: 8, banners: banners),
            const SizedBox(
              height: 10,
            ),

              IndexedBannerWidget(index: 7, banners: banners),

            const SizedBox(
              height: 10,
            ),


              IndexedBannerWidget(index: 6, banners: banners),
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

            if (banners.length > 1)
              IndexedBannerWidget(index: 5, banners: banners),
            const SizedBox(height: 10.0),

            if (banners.length > 2)
              IndexedBannerWidget(index: 4, banners: banners),
            const SizedBox(height: 8.0),


            CircleBrands(
              ontap: ontap,
            ),


              IndexedBannerWidget(index: 2, banners: banners),
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
              specialProducts:false ,
              bestSellers:false ,
              bestRatings:false ,
              allNeedsGrooming:true ,
              exclusiveDeals: false,
              nearlyArrived: false,
              type: 'relatedProducts',
              isLink:  false,

            ),
          ],
        ),
      ),
      floatingActionButton:Stack(
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
              Navigator.push(context, MaterialPageRoute(builder: (context)=> SkincareDetect()));
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


class CameraScreen extends StatefulWidget {
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _image;

  // ✅ دالة لطلب إذن الكاميرا
  Future<void> _requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.request();

    if (status.isGranted) {
      _openCamera(); // ✅ إذا تمت الموافقة → افتح الكاميرا
    } else if (status.isDenied) {
      _showPermissionDeniedDialog(); // ✅ عرض رسالة عند الرفض
    } else if (status.isPermanentlyDenied) {
      _openCamera(); // ✅ فتح إعدادات التطبيق مباشرة في حالة رفض دائم
    }
  }

  // ✅ دالة لفتح الكاميرا باستخدام image_picker
  Future<void> _openCamera() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // ✅ دالة لعرض رسالة عند رفض الإذن
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Denied"),
        content: const Text("Please allow camera permission to use this feature."),
        actions: [
          TextButton(
            onPressed: () {
              _openCamera(); // ✅ فتح إعدادات التطبيق مباشرة
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Camera Example")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? Image.file(
              _image!,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            )
                : const Icon(Icons.camera_alt, size: 100),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestCameraPermission,
              child: const Text("Open Camera"),
            ),
          ],
        ),
      ),
    );
  }
}
