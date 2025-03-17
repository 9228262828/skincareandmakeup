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
    final List<Map<String, dynamic>> productsAr = [
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
    final List<Map<String, dynamic>> productsEn = [
      {
        'mainLabel': "Discount World",
        'items': [
          {'image': 'assets/1.png', 'label': "Diapering", "id": "5119"},
          {'image': 'assets/2.png', 'label': "Skin Moisturizing", "id": "5584"},
          {'image': 'assets/3.png', 'label': "Makeup Discounts", "id": "5581"},
          {'image': 'assets/4.png', 'label': "Sunscreen Discounts", "id": "5582"},
        ],
      },
      {
        'mainLabel': "Cleansers World",
        'items': [
          {'image': 'assets/5.png', 'label': "Exfoliators", "id": "5588"},
          {'image': 'assets/6.png', 'label': "Dry Skin Cleanser", "id": "5588"},
          {'image': 'assets/7.png', 'label': "Sensitive Skin Cleanser", "id": "5588"},
          {'image': 'assets/8.png', 'label': "Oily Skin Cleanser", "id": "5585"},
        ],
      },
      {
        'mainLabel': "Live the Romance",
        'items': [
          {'image': 'assets/9.png', 'label': "Candles", "id": "5589"},
          {'image': 'assets/10.png', 'label': "Lenses ", "id": "5592"},
          {'image': 'assets/11.png', 'label': "Makeup", "id": "5590"},
          {'image': 'assets/12.png', 'label': "Gifts", "id": "5591"},
        ],
      },
    ];
    final String locale = Localizations.localeOf(context).languageCode;
    final List<Map<String, dynamic>> products = locale == 'ar' ? productsAr : productsEn;
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(3),
        ),
        height: mediaQueryHeight(context) * 0.45,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          controller: _scrollController,
          itemCount: products.length,
          itemBuilder: (context, sectionIndex) {
            final section = products[sectionIndex];

            return Container(
              width: mediaQueryWidth(context) * 0.78,
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
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,),
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
                      height: mediaQueryHeight(context) * 0.152,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      product['label']!,
                      maxLines:   1,
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
    final List<Map<String, dynamic>> productsAr = [
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
    final List<Map<String, dynamic>> productsEn = [
      {
        'mainLabel': "Artistic Touch",
        'items': [
          {'image': 'assets/21.jpeg', 'label': "Home Decor", "id": "5593"},
          {'image': 'assets/22.jpeg', 'label': "Heritage Decorations", "id": "5596"},
          {'image': 'assets/23.jpeg', 'label': "Occasion Decorations", "id": "5594"},
          {'image': 'assets/24.jpeg', 'label': "Home Fragrances" ,"id": "5595"},
        ],
      },
      {
        'mainLabel':"Unlimited Relaxation",
        'items': [
          {'image': 'assets/25.jpeg', 'label': "Massage Rollers", "id": "5597"},
          {'image': 'assets/26.jpeg', 'label': "Massage Oils", "id": "5598"},
          {'image': 'assets/27.jpeg', 'label': "Spa", "id": "5600"},
          {'image': 'assets/28.jpeg', 'label': "Massage Creams", "id": "5599"},
        ],
      },
      {
        'mainLabel': "Fun Time",
        'items': [
          {'image': 'assets/29.jpg', 'label': "Board Games", "id": "5602"},
          {'image': 'assets/30.jpeg', 'label': "Family Games", "id": "5603"},
          {'image': 'assets/31.jpeg', 'label': "Card Games", "id": "5601"},
          {'image': 'assets/32.jpeg', 'label': "Educational Games", "id": "5604"},
        ],
      },
    ];
    final String locale = Localizations.localeOf(context).languageCode;
    final List<Map<String, dynamic>> products = locale == 'ar' ? productsAr : productsEn;
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(3),
        ),
        height: mediaQueryHeight(context) * 0.45,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          controller: _scrollController,
          itemCount: products.length,
          itemBuilder: (context, sectionIndex) {
            final section = products[sectionIndex];

            return Container(
              width: mediaQueryWidth(context) * 0.78,
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
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,),
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
                      height: mediaQueryHeight(context) * 0.152,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      product['label']!,
                      maxLines:   1,
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
