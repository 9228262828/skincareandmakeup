import 'dart:async';

import 'package:Gomla/contstants.dart';
import 'package:Gomla/shared/utils/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GridOffers extends StatefulWidget {
  @override
  _GridOffersState createState() => _GridOffersState();
}

class _GridOffersState extends State<GridOffers> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Timer.periodic(Duration(seconds: 4), (Timer timer) {
      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.position.pixels;
        double nextScroll = currentScroll + mediaQueryHeight(context) * 0.45;

        if (nextScroll >= maxScroll) {
          _scrollController.animateTo(0.0,
              duration: Duration(seconds: 2), curve: Curves.easeInOut);
        } else {
          _scrollController.animateTo(nextScroll,
              duration: Duration(seconds: 2), curve: Curves.easeInOut);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> products = [
      {
        'image': 'assets/app_icon.png',
        "mainLabel": AppLocalizations.of(context)!.bestDeals,
        'label': AppLocalizations.of(context)!.offers
      },
      {
        'image': 'assets/app_icon.png',
        "mainLabel": AppLocalizations.of(context)!.bestDeals,
        'label': AppLocalizations.of(context)!.offers
      },
      {
        'image': 'assets/app_icon.png',
        "mainLabel": AppLocalizations.of(context)!.bestDeals,
        'label': AppLocalizations.of(context)!.offers
      },
      {
        'image': 'assets/app_icon.png',
        "mainLabel": AppLocalizations.of(context)!.bestDeals,
        'label': AppLocalizations.of(context)!.offers
      },
      {
        'image': 'assets/app_icon.png',
        "mainLabel": AppLocalizations.of(context)!.bestDeals,
        'label': AppLocalizations.of(context)!.offers
      },
      {
        'image': 'assets/app_icon.png',
        "mainLabel": AppLocalizations.of(context)!.bestDeals,
        'label': AppLocalizations.of(context)!.offers
      },
      {
        'image': 'assets/app_icon.png',
        "mainLabel": AppLocalizations.of(context)!.bestDeals,
        'label': AppLocalizations.of(context)!.offers
      },
      {
        'image': 'assets/app_icon.png',
        "mainLabel": AppLocalizations.of(context)!.bestDeals,
        'label': AppLocalizations.of(context)!.offers
      },
      {
        'image': 'assets/app_icon.png',
        "mainLabel": AppLocalizations.of(context)!.bestDeals,
        'label': AppLocalizations.of(context)!.offers
      },
      {
        'image': 'assets/app_icon.png',
        "mainLabel": AppLocalizations.of(context)!.bestDeals,
        'label': AppLocalizations.of(context)!.offers
      },
      {
        'image': 'assets/app_icon.png',
        "mainLabel": AppLocalizations.of(context)!.bestDeals,
        'label': AppLocalizations.of(context)!.brand
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(5),
        ),
        height: mediaQueryHeight(context) * 0.55,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          reverse: true,
          physics: BouncingScrollPhysics(),
          controller: _scrollController,
          itemCount: (products.length / 4).ceil(),
          // Number of main containers
          itemBuilder: (context, index) {
            int start = index * 4;
            int end = start + 4;

            // Ensure we don't go beyond the length of the products list
            if (end > products.length) {
              end = products.length;
            }

            return Container(
              width: mediaQueryWidth(context) * 0.95,
              // Width of each main container
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                    child: Text(
                      products[start]['mainLabel'] ?? '',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      // First row with 2 items
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Row(
                          children: List.generate(2, (subIndex) {
                            final productIndex = start + subIndex;
                            if (productIndex < end) {
                              final product = products[productIndex];
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    print('Tapped on ${product['label']}');
                                  },
                                  child: Container(
                                    margin: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: mainColor,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Image.asset(
                                            product['image']!,
                                            height: mediaQueryHeight(context) *
                                                0.18,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(
                                            product['label']!,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Expanded(
                                  child:
                                      Container()); // Return an empty container if no product
                            }
                          }),
                        ),
                      ),
                      // Second row with 2 items
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Row(
                          children: List.generate(2, (subIndex) {
                            final productIndex = start + 2 + subIndex;
                            if (productIndex < end) {
                              final product = products[productIndex];
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    print('Tapped on ${product['label']}');
                                  },
                                  child: Container(
                                    margin: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: mainColor,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Image.asset(
                                            product['image']!,
                                            height: mediaQueryHeight(context) *
                                                0.18,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(
                                            product['label']!,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Expanded(
                                  child:
                                      Container()); // Return an empty container if no product
                            }
                          }),
                        ),
                      ),
                    ],
                  ),
                  // "Show More" button at the bottom of each main container
                  TextButton(
                    onPressed: () {
                      // Action to show more items
                    },
                    child: Text(
                      AppLocalizations.of(context)!.all,
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
