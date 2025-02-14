import 'package:Gomla/contstants.dart';
import 'package:Gomla/shared/utils/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';

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
    Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.position.pixels;
        double nextScroll = currentScroll + mediaQueryHeight(context) * 0.22;

        if (nextScroll >= maxScroll) {
          _scrollController.animateTo(0.0,
              duration: Duration(seconds: 1), curve: Curves.easeInOut);
        } else {
          _scrollController.animateTo(nextScroll,
              duration: Duration(seconds: 1), curve: Curves.easeInOut);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> products = [
      {
        'image': 'assets/app_icon.png',
        'label': AppLocalizations.of(context)!.offers,
      },
      {
        'image': 'assets/app_icon.png',
        'label': AppLocalizations.of(context)!.offers,
      },
      {
        'image': 'assets/app_icon.png',
        'label': AppLocalizations.of(context)!.offers,
      },
      {
        'image': 'assets/app_icon.png',
        'label': AppLocalizations.of(context)!.offers,
      },
      {
        'image': 'assets/app_icon.png',
        'label': AppLocalizations.of(context)!.offers,
      },
      {
        'image': 'assets/app_icon.png',
        'label': AppLocalizations.of(context)!.offers,
      },
      {
        'image': 'assets/app_icon.png',
        'label': AppLocalizations.of(context)!.offers,
      }, {
        'image': 'assets/app_icon.png',
        'label': AppLocalizations.of(context)!.offers,
      },
      {
        'image': 'assets/app_icon.png',
        'label': AppLocalizations.of(context)!.offers,
      },
      {
        'image': 'assets/app_icon.png',
        'label': AppLocalizations.of(context)!.offers,
      },
    ];

    return SizedBox(
      height: mediaQueryHeight(context) * 0.45,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
        child: GridView.builder(
          controller: _scrollController,
          scrollDirection:  Axis.horizontal,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            mainAxisExtent: mediaQueryHeight(context) * 0.22,
          ),
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return GestureDetector(
              onTap: () {
                print('Tapped on ${product['label']}');
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: mainColor,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: Image.asset(
                      product['image']!,
                      height: mediaQueryHeight(context) * 0.18,
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
            );
          },
        ),
      ),
    );
  }
}
