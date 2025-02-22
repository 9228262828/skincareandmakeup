import 'dart:async';

import 'package:Gomla/contstants.dart';
import 'package:Gomla/shared/utils/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final List<Map<String, String>> products = [
      {
        'image': 'assets/app_icon.png',
        'label': AppLocalizations.of(context)!.offers
      },{
        'image': 'assets/app_icon.png',
        'label': AppLocalizations.of(context)!.offers
      },{
        'image': 'assets/app_icon.png',
        'label': AppLocalizations.of(context)!.offers
      },{
        'image': 'assets/app_icon.png',
        'label': AppLocalizations.of(context)!.offers
      },

    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.buyWithUs,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),

            ],
          ),
        ),
        SizedBox  (height: 5),
        Padding(
          padding:  EdgeInsets.symmetric(horizontal: 3.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(3),
            ),
            height: mediaQueryHeight(context) * 0.2,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),

              itemCount: products.length ,
              itemBuilder: (context, index) {
                final product = products[index];
                return Container(
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
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}