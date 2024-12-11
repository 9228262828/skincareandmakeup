import 'package:Gomla/shared/utils/app_assets.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../Engin/skincare.dart';
import '../shared/global/app_colors.dart';
import '../widgets/app_bar.dart';
import '../widgets/home_banner_slider.dart';
import '../widgets/home_categories_list.dart';
import '../widgets/product_home_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context)!.home,home: true,),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            buildCategoriesList(context),

            HomeBannerSlider(),
            ProductHomeWidget(
              title: AppLocalizations.of(context)!.bestSellers,
              categoryId: 1214, specialProducts: false,
              bestSellers: true,
              bestRatings: false,
              allNeedsGrooming:false ,
              exclusiveDeals: false,
              nearlyArrived: false,
              type:  'bestSellers',
              isLink:  true,
            ),
          //  buildProductSection("عروض جملة", homeScreenProvider.pets, 53),
            const SizedBox(height: 8.0),

            BannerHome(
             image:  ImageAssets.banner2  ,
           ),
            const SizedBox(height: 8.0),
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
            BannerHome(
              image:  ImageAssets.banner3  ,
            ),
            /*const SizedBox(height: 8.0),
            BannerHome(
              image:  ImageAssets.banner3  ,
            ),
            const SizedBox(height: 8.0),*/
           // buildProductSection("احدث منتجات بيوتي", homeScreenProvider.pets, 53),
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
            const SizedBox(height: 8.0),
            BannerHome(
              image:  ImageAssets.banner4  ,
            ),
            const SizedBox(height: 8.0),
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
            BannerHome(
              image:  ImageAssets.banner3  ,
            ),
            const SizedBox(height: 8.0),
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
            BannerHome(
              image:  ImageAssets.banner1  ,
            ),
            const SizedBox(height: 8.0),
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
          final prefs = await SharedPreferences.getInstance();
          String? token = prefs.getString("auth_token");
          print(token);
          token != null ?
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SkincareDetect())) :
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LoginScreen(
              ))
          );
         /* Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SkincareDetect()));*/
        },
      ),
    );
  }
}
