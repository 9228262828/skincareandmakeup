import 'package:Gomla/contstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';

import '../Engin/ads.dart';
import '../models/banner.dart';
import '../widgets/app_bar.dart';
import '../widgets/circleBrands.dart';
import '../widgets/crousal_container.dart';
import '../widgets/grid_offers.dart';
import '../widgets/home_banner_slider.dart';
import '../widgets/location_widget.dart';
import '../widgets/product_home_widget.dart';


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
            IndexedBannerWidget(index: 5, banners: banners),
            const SizedBox(
              height: 10,
            ),

              IndexedBannerWidget(index: 4, banners: banners),

            const SizedBox(
              height: 10,
            ),

            if (banners.length > 1)
              IndexedBannerWidget(index: 3, banners: banners),
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
              IndexedBannerWidget(index: 2, banners: banners),
            const SizedBox(height: 10.0),
            const SizedBox(height: 8.0),
            if (banners.length > 2)
              IndexedBannerWidget(index: 1, banners: banners),
            const SizedBox(height: 8.0),
            CircleBrands(
              ontap: ontap,
            ),


              IndexedBannerWidget(index: 0, banners: banners),
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
            tooltip:  AppLocalizations.of(context)!.skinCare,
            elevation: 0,
            child: Image.asset(
              "assets/skin.png",
              width: 55,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdPage(
                    isbeforetest: true,
                    reports: {},
                    skinAnalysisData: {},
                    capturedFeatures: [],
                    scores: {},
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
