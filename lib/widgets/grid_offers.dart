import 'package:Gomla/shared/utils/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../contstants.dart';
import '../screens/product_listing_screen.dart';

class GridOffers extends StatefulWidget {
  @override
  _GridOffersState createState() => _GridOffersState();
}

class _GridOffersState extends State<GridOffers> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> products = [
      {
        'mainLabel': AppLocalizations.of(context)!.worldofdiscounts,
        'items': [
          {'image': 'assets/1.png', 'label': AppLocalizations.of(context)!.diapers, "id": "5559"},
          {'image': 'assets/2.png', 'label': AppLocalizations.of(context)!.moisturizingtheskin, "id": "5560"},
          {'image': 'assets/3.png', 'label': AppLocalizations.of(context)!.makeupdiscounts, "id": "5557"},
          {'image': 'assets/4.png', 'label': AppLocalizations.of(context)!.sunscreenDiscounts, "id": "5558"},
        ],
      },
      {
        'mainLabel': AppLocalizations.of(context)!.worldofwashes,
        'items': [
          {'image': 'assets/5.png', 'label': AppLocalizations.of(context)!.exfoliants, "id": "5564"},
          {'image': 'assets/6.png', 'label': AppLocalizations.of(context)!.dryskincleansers, "id": "5562"},
          {'image': 'assets/7.png', 'label': AppLocalizations.of(context)!.sensitiveskincleansers, "id": "5563"},
          {'image': 'assets/8.png', 'label': AppLocalizations.of(context)!.oilyskincleansers, "id": "5561"},
        ],
      },
      {
        'mainLabel': "عيشي الرومانسية في اختيارك",
        'items': [
          {'image': 'assets/9.png', 'label': "الشموع", "id": "5565"},
          {'image': 'assets/10.png', 'label': "العدسات ", "id": "5568"},
          {'image': 'assets/11.png', 'label': "المكياج", "id": "5566"},
          {'image': 'assets/12.png', 'label': "الهدايا", "id": "5567"},
        ],
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(3),
        ),
        height: mediaQueryHeight(context) * 0.44,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          controller: _scrollController,
          itemCount: products.length,
          itemBuilder: (context, sectionIndex) {
            final section = products[sectionIndex];

            return Container(
              width: mediaQueryWidth(context) * 0.8,
              margin: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // **Main Label for Each Section**
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Text(
                        section['mainLabel'],
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildRow(context, section['items'], 0),
                    _buildRow(context, section['items'], 2),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, List<Map<String, String>> items, int offset) {
    return Row(
      children: List.generate(2, (subIndex) {
        int productIndex = offset + subIndex;
        if (productIndex >= items.length) {
          return Expanded(child: Container()); // Empty container to maintain layout
        }
        final product = items[productIndex];

        return Expanded(
          child: GestureDetector(
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
            child: Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(3)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: mainColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Image.asset(
                      product['image']!,
                      height: mediaQueryHeight(context) * 0.15,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      product['label']!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class GridOffers2 extends StatefulWidget {
  @override
  _GridOffers2State createState() => _GridOffers2State();
}

class _GridOffers2State extends State<GridOffers2> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> products = [
      {
        'mainLabel': "لمسة فنية",
        'items': [
          {'image': 'assets/21.jpeg', 'label': "ديكور المنزل", "id": "5569"},
          {'image': 'assets/22.jpeg', 'label': "ديكورات تعكس تراثنا", "id": "5572"},
          {'image': 'assets/23.jpeg', 'label': "زينة المناسبات", "id": "5570"},
          {'image': 'assets/24.jpeg', 'label': "عطور منزلية" ,"id": "5571"},
        ],
      },
      {
        'mainLabel':"إسترخاء بلا حدود",
        'items': [
          {'image': 'assets/25.jpeg', 'label': "اسطوانات التدليك", "id": "5573"},
          {'image': 'assets/26.jpeg', 'label': "زيوت التدليك", "id": "5574"},
          {'image': 'assets/27.jpeg', 'label': "سبا", "id": "5575"},
          {'image': 'assets/28.jpeg', 'label': "كريمات التدليك", "id": "5576"},
        ],
      },
      {
        'mainLabel': "وقت المرح",
        'items': [
          {'image': 'assets/29.jpg', 'label': "العاب الطاولة", "id": "5578"},
          {'image': 'assets/30.jpeg', 'label': "العاب العائلة ", "id": "5579"},
          {'image': 'assets/31.jpeg', 'label': "العاب الورق", "id": "5577"},
          {'image': 'assets/32.jpeg', 'label': "العاب تعليمية", "id": "5580"},
        ],
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(3),
        ),
        height: mediaQueryHeight(context) * 0.44,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          controller: _scrollController,
          itemCount: products.length,
          itemBuilder: (context, sectionIndex) {
            final section = products[sectionIndex];

            return Container(
              width: mediaQueryWidth(context) * 0.8,
              margin: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // **Main Label for Each Section**
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Text(
                          section['mainLabel'],
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ),
                      _buildRow(context, section['items'], 0),
                      _buildRow(context, section['items'], 2),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, List<Map<String, String>> items, int offset) {
    return Row(
      children: List.generate(2, (subIndex) {
        int productIndex = offset + subIndex;
        if (productIndex >= items.length) {
          return Expanded(child: Container()); // Empty container to maintain layout
        }
        final product = items[productIndex];

        return Expanded(
          child: GestureDetector(
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
            child: Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(3)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: mainColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Image.asset(
                      product['image']!,
                      height: mediaQueryHeight(context) * 0.15,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      product['label']!,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
