import 'package:Gomla/shared/utils/app_assets.dart';
import 'package:Gomla/shared/utils/app_values.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../Engin/ads.dart';
import '../Engin/pdf_screen.dart';
import '../Engin/skincare.dart';
import '../contstants.dart';
import '../models/banner.dart';
import '../widgets/app_bar.dart';
import '../widgets/circleBrands.dart';
import '../widgets/crousal_widget_assets.dart';
import '../widgets/grid_offers.dart';
import '../widgets/home_banner_slider.dart';
import '../widgets/location_widget.dart';
import '../widgets/product_home_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class HomeScreen extends StatelessWidget {
  final List<Bannerr> banners;
  const HomeScreen({super.key, required this.banners});

  @override
  Widget build(BuildContext context) {
    Bannerr banner;
    return Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context)!.home,home: true,),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

         /*  buildCategoriesList(context),*/
            LocationWidget(),
            HomeBannerSlider(
              banners: banners,
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/banner1.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: mediaQueryHeight(context) * 0.12,
                ),),
            ),


            GridOffers(),
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
          //  buildProductSection("عروض جملة", homeScreenProvider.pets, 53),
            CircleBrands(),
            IndexedBannerWidget(index: 0, banners: banners),

            /*BannerHome(
             image:  ImageAssets.banner2  ,
           ),*/
            const SizedBox(height: 4.0),
            GridOffers(),
            ScrollingCarouselWidget(isMain:  false,),
          //  buildProductSection("الاعلى تقييما", homeScreenProvider.pets, 53),
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
            const SizedBox(height: 8.0),

      /*    BannerHome(banner: ), */
            /*const SizedBox(height: 8.0),
            BannerHome(
              image:  ImageAssets.banner3  ,

            ),
            const SizedBox(height: 8.0),*/

            if (banners.length > 1)
              IndexedBannerWidget(index: 1, banners: banners),
            GridOffers(),           // buildProductSection("احدث منتجات بيوتي", homeScreenProvider.pets, 53),
            ProductHomeWidget(
              title: AppLocalizations.of(context)!.nearlyArrived,
              categoryId: 1199,
              specialProducts:false ,
              bestSellers: false,
              bestRatings: false,
              allNeedsGrooming:false ,
              exclusiveDeals: false,
              nearlyArrived: true,
              type:  'nearlyArrived',
              isLink: true,

            ),


            /*BannerHome(
              image:  ImageAssets.banner4  ,
            ),*/
            if (banners.length > 2)
              IndexedBannerWidget(index: 2, banners: banners),
            GridOffers(),

           // buildProductSection("احدث منتجات الجيم", homeScreenProvider.pets, 53),
            ProductHomeWidget(
              title: AppLocalizations.of(context)!.bestRatings,
              categoryId: 229,
              specialProducts: false,
              bestSellers: false,
              bestRatings: true,
              allNeedsGrooming: false,
              exclusiveDeals:false ,
              nearlyArrived: false,
              type:  'bestRatings',
              isLink:  true,

            ),
            const SizedBox(height: 8.0),
            if (banners.length > 3)
              IndexedBannerWidget(index: 3, banners: banners),
          /*  BannerHome(
              image:  ImageAssets.banner3  ,
            ),*/
            const SizedBox(height: 8.0),
            if (banners.length > 5)
              IndexedBannerWidget(index: 5, banners: banners),
            SizedBox(height: 8.0),
            GridOffers(),
          //  buildProductSection("احدث منتجات بيتس", homeScreenProvider.pets, 53),
            ProductHomeWidget(
              title: AppLocalizations.of(context)!.allNeedsGrooming,
              categoryId: 53,
              specialProducts:false ,
              bestSellers:false ,
              bestRatings:false ,
              allNeedsGrooming:true ,
              exclusiveDeals: false,
              nearlyArrived: false,
              type:  'allNeedsGrooming',
              isLink:  false,

            ),
            const SizedBox(height: 8.0),
            if (banners.length > 4)
              IndexedBannerWidget(index: 4, banners: banners),
            /*BannerHome(
              image:  ImageAssets.banner1  ,
            ),*/
            GridOffers(),
           // buildProductSection("منتجات مميزة", homeScreenProvider.pets, 53),
            ProductHomeWidget(
              title: AppLocalizations.of(context)!.specialProducts,
              categoryId: 53,
              specialProducts:true ,
              bestSellers: false,
              bestRatings: false,
              allNeedsGrooming:false ,
              exclusiveDeals: false,
              nearlyArrived: false,
              type:  'specialProducts',
              isLink:  false,

            ),

            if (banners.length > 5)
              IndexedBannerWidget(index: 5, banners: banners),
            /*BannerHome(
              image:  ImageAssets.banner1  ,
            ),*/
            GridOffers(),
            ProductHomeWidget(
              title: AppLocalizations.of(context)!.recentlyViewedProducts,
              categoryId: 53,
              specialProducts:true ,
              bestSellers: false,
              bestRatings: false,
              allNeedsGrooming:false ,
              exclusiveDeals: false,
              nearlyArrived: false,
              type:  'recentlyViewedProducts',
              isLink:  false,

            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
      floatingActionButton:   FloatingActionButton(
        backgroundColor: Colors.transparent,
        shape:  CircleBorder(),
        elevation: 2,
        child: Image(
          image: AssetImage(ImageAssets.skin),
          width: 55,
        ),
        onPressed: () async{
         /* final prefs = await SharedPreferences.getInstance();
          String? token = prefs.getString("auth_token");
          print(token);
          token != null ?*/
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AdPage(
                    isbeforetest: true,
                    reports:  {},
                    skinAnalysisData: {},
                    capturedFeatures: [],
                    scores: {},
                  )));


         /* Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SkincareDetect()));*/
        },
      ),
    );
  }


}

