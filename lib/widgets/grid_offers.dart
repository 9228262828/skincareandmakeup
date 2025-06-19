import 'dart:convert';
import 'dart:math';

import 'package:Gomla/shared/utils/app_values.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../contstants.dart';
import '../screens/collection_listing_screen.dart';
import '../screens/product_listing_screen.dart';
class CollectionItem {
  final int id;
  final String name;
  final String? image;

  CollectionItem({
    required this.id,
    required this.name,
    required this.image,
  });

  factory CollectionItem.fromJson(Map<String, dynamic> json) {
    return CollectionItem(
      id: json['id'],
      name: json['name'],
      image: json['image'] is String ? json['image'] : null,
    );
  }
}


class GridOffers extends StatefulWidget {
final   int id ;

  const GridOffers({super.key, required this.id});
  @override
  _GridOffersState createState() => _GridOffersState();
}

class _GridOffersState extends State<GridOffers> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> apiItems = [];

  @override
  void initState() {
    super.initState();
   widget.id == 1 ? fetchCollections1() : fetchCollections();
  }

  Future<void> fetchCollections1() async {
    final prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('locale');
    if (language == null) {
      language = 'ar';
    }
    final String consumerKey = 'ck_d0150d53b03646e0d5695e37739777049dda22aa';
    final String consumerSecret = 'cs_bdb53e06ca06f8fcdb6510efbbbfaca708bbb3c7';
    try {
      final response = await http.get(Uri.parse('https://gomla.egymetrix.net/wp-json/custom/v1/collections/?lang=$language') ,
        headers:  {
          'Authorization': 'Basic ' +
              base64Encode(utf8.encode('$consumerKey:$consumerSecret')),
        }
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        print("data");
        print(data);
        final List<Map<String, String>> items = data
            .take(12)
            .map<Map<String, String>>((item) {
          final dynamic imageField = item['image'];
          return {
            'image': imageField is String ? imageField : '', // fallback to empty string if it's not a string
            'label': item['name'] ?? '',
            'id': item['id']?.toString() ?? '',
          };
        }).toList();


        setState(() {
          apiItems = items;
        });
      } else {
        print('Failed to load collections. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching collections: $e');
    }
  }
  Future<void> fetchCollections() async {
    final prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('locale');
    if (language == null) {
      language = 'ar';
    }
    final String consumerKey = 'ck_d0150d53b03646e0d5695e37739777049dda22aa';
    final String consumerSecret = 'cs_bdb53e06ca06f8fcdb6510efbbbfaca708bbb3c7';
    try {
      final response = await http.get(Uri.parse('https://gomla.egymetrix.net/wp-json/custom/v1/collections/?lang=$language') ,
        headers:  {
          'Authorization': 'Basic ' +
              base64Encode(utf8.encode('$consumerKey:$consumerSecret')),
        }
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        print("data");
        print(data);
        final last12 = data.length >= 12 ? data.sublist(data.length - 12) : data;

        final List<Map<String, String>> items = last12.map<Map<String, String>>((item) {
          final dynamic imageField = item['image'];
          return {
            'image': imageField is String ? imageField : '',
            'label': item['name'] ?? '',
            'id': item['id']?.toString() ?? '',
          };
        }).toList();



        setState(() {
          apiItems = items;
        });
      } else {
        print('Failed to load collections. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching collections: $e');
    }
  }

   @override
  Widget build(BuildContext context) {
     return apiItems.isEmpty
         ? shimmerSection(context)


         : Padding(
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
          itemCount: min(3, (apiItems.length / 4).ceil()),
          itemBuilder: (context, sectionIndex) {
            final sectionLabels =  widget.id == 2? [
              AppLocalizations.of(context)!.specialAdditions,
              AppLocalizations.of(context)!.newLabel,
              AppLocalizations.of(context)!.ourPicks,

            ] :    [
              AppLocalizations.of(context)!.artisticTouch,
              AppLocalizations.of(context)!.unlimitedRelaxation,
              AppLocalizations.of(context)!.funTime,

            ];


            final label = sectionIndex < sectionLabels.length
                ? sectionLabels[sectionIndex]
                : "قسم ${sectionIndex + 1}";

            return _buildSection(
              context,
              mainLabel: label,
              items: apiItems,
              sectionIndex: sectionIndex,
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, {
        required String mainLabel,
        required List<Map<String, String>> items,
        required int sectionIndex,
      })
  {
    final startIndex = sectionIndex * 4;
    final endIndex = startIndex + 4;

    // Guard: If not enough items to render this section, return empty
    if (startIndex >= items.length) {
      return SizedBox.shrink();
    }

    final sectionItems = items.sublist(
      startIndex,
      endIndex > items.length ? items.length : endIndex,
    );

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
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                mainLabel,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
            _buildRow(context, sectionItems, 0),
            _buildRow(context, sectionItems, 2),
          ],
        ),
      ),
    );
  }


  Widget _buildRow(BuildContext context, List<Map<String, String>> items, int offset) {
    return Row(
      children: List.generate(2, (subIndex) {
        int productIndex = offset + subIndex;
        if (productIndex >= items.length) {
          return Expanded(child: Container());
        }
        final product = items[productIndex];
        print(product['id']);

        return Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CollectionListingScreen(
                    id: product['id']!,
                    categoryName: product['label']!,
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
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: product['image'] != null && product['image']!.isNotEmpty
                        ? Image.network(
                      product['image']!,
                      height: mediaQueryHeight(context) * 0.152,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                        : Image.asset(
                      'assets/placeholder.png', // Replace with your asset path
                      height: mediaQueryHeight(context) * 0.152,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )

                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      product['label']!.replaceAll("&#039;", "'"),
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

  Widget shimmerSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        height: mediaQueryHeight(context) * 0.45,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          itemBuilder: (context, index) {
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
                    Container(
                      height: 20,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      width: 100,
                      color: Colors.grey[300],
                    ),
                    shimmerRow(context),
                    shimmerRow(context),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget shimmerRow(BuildContext context) {
    return Row(
      children: List.generate(2, (index) {
        return Expanded(
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: mediaQueryHeight(context) * 0.2,
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
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
