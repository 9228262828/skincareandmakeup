import 'dart:async';

import 'package:Gomla/contstants.dart';
import 'package:Gomla/shared/utils/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../screens/product_listing_screen.dart';

class CruosalContainer extends StatefulWidget {
  const CruosalContainer({super.key});

  @override
  _CruosalContainerState createState() => _CruosalContainerState();
}

class _CruosalContainerState extends State<CruosalContainer> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

  }


  @override
  Widget build(BuildContext context) {

    final List<Map<String, String>> productsAr = [
      {
        'image': 'assets/13.png',
        'label': "أفكار جديدة للصبغات",
          "id": "4817"
      },{
        'image': 'assets/14.png',
        'label': "أقوى العروض الحالية",
          "id": "4801"
      },{
        'image': 'assets/15.png',
        'label':"ترند المكياج",
          "id": "4773"
      },{
        'image': 'assets/16.png',
        'label': "عدسات المشاهير",
          "id": "4785"
      },

    ];
    final List<Map<String, String>> productsEn = [
      {
        'image': 'assets/13.png',
        'label': "New Hair Coloring Ideas",
          "id": "5288"
      },{
        'image': 'assets/14.png',
        'label': "Top Current Deals",
          "id": "5288"
      },{
        'image': 'assets/15.png',
        'label':"Makeup Trend","id": "5288"
      },{
        'image': 'assets/16.png',
        'label': "Celebrity Lenses",
          "id": "5191"
      },

    ];

    final String locale = Localizations.localeOf(context).languageCode;
    final List<Map<String, dynamic>> products = locale == 'ar' ? productsAr : productsEn;
    return Column(
      crossAxisAlignment:   CrossAxisAlignment.start,
      mainAxisAlignment:  MainAxisAlignment.start,
      children: [
        Padding(
          padding:  const EdgeInsets.symmetric(horizontal: 3.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(3),
            ),
            height: mediaQueryHeight(context) * 0.23,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),

              itemCount: products.length ,
              itemBuilder: (context, index) {
                final product = products[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductListingScreen(
                          categoryId: int.parse(product['id']!),
                          categoryName: product['label']!,
                          type: "id",
                          isLink: false,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment:   CrossAxisAlignment.start,
                    mainAxisAlignment:  MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          product['label']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        width: mediaQueryWidth(context) * 0.40,
                        // Width of each main container
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child:   Container(
                          decoration: BoxDecoration(
                            color: mainColor,
                            borderRadius:
                            BorderRadius.circular(3),
                          ),
                          child: Image.asset(
                            product['image']!,
                            height: mediaQueryHeight(context) *
                                0.18,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class CruosalContainer2 extends StatefulWidget {
  const CruosalContainer2({super.key});

  @override
  _CruosalContainer2State createState() => _CruosalContainer2State();
}

class _CruosalContainer2State extends State<CruosalContainer2> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> productsAr = [
      {
        'image': 'assets/17.png',
        'label': "استمتع بالدايت",
          "id": "4869"
      },{
        'image': 'assets/18.png',
        'label': "الصحة تبدأ من هنا",
          "id": "4869"
      },{
        'image': 'assets/19.png',
        'label':"بروتينات اللياقة",
          "id": "5023"
      },{
        'image': 'assets/20.png',
        'label': "عيش تحدي الدايت",
          "id": "4728"
      },

    ];
    final List<Map<String, String>> productsEn = [
      {
        'image': 'assets/17.png',
        'label': "Enjoy Dieting",
          "id": "5377"
      },{
        'image': 'assets/18.png',
        'label': "Health Starts Here",
          "id": "5335"
      },{
        'image': 'assets/19.png',
        'label':"Fitness Proteins",
          "id": "5140"
      },{
        'image': 'assets/20.png',
        'label': "Diet Challenge",
          "id": "5150"
      },

    ];
    final String locale = Localizations.localeOf(context).languageCode;
    final List<Map<String, dynamic>> products = locale == 'ar' ? productsAr : productsEn;
    return Column(
      crossAxisAlignment:   CrossAxisAlignment.start,
      mainAxisAlignment:  MainAxisAlignment.start,
      children: [

        Padding(
          padding:  EdgeInsets.symmetric(horizontal: 3.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(3),
            ),
            height: mediaQueryHeight(context) * 0.23,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),

              itemCount: products.length ,
              itemBuilder: (context, index) {
                final product = products[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductListingScreen(
                          categoryId: int.parse(product['id']!),
                          categoryName: product['label']!,
                          type: "id",
                          isLink: false,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment:   CrossAxisAlignment.start,
                    mainAxisAlignment:  MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          product['label']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        width: mediaQueryWidth(context) * 0.40,
                        // Width of each main container
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child:   Container(
                          decoration: BoxDecoration(
                            color: mainColor,
                            borderRadius:
                            BorderRadius.circular(3),
                          ),
                          child: Image.asset(
                            product['image']!,
                            height: mediaQueryHeight(context) *
                                0.18,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}