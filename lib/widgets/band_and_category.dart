import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:Gomla/shared/utils/app_assets.dart';
import 'package:Gomla/shared/utils/app_values.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/brand.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../env.dart';

class ProductDetailWidget extends StatefulWidget {
  final Product product;

  const ProductDetailWidget({super.key, required this.product});

  @override
  _ProductDetailWidgetState createState() => _ProductDetailWidgetState();
}

class _ProductDetailWidgetState extends State<ProductDetailWidget> {
  late Future<List<Category>> subCategoriesFuture;
  late Future<Brand> brandFuture;

  @override
  void initState() {
    super.initState();
    // Fetch data when widget is initialized
    subCategoriesFuture = fetchSubCategories(widget.product.categoryId);
    brandFuture = fetchBrand(widget.product.brandId);
  }

  Future<List<Category>> fetchSubCategories(int categoryId) async {
    final String baseUrl = '$siteUrl/wp-json/wc/v3';
    final String consumerKey = 'ck_1c63c710561ce560194698e6f676fe67ee2ed927';
    final String consumerSecret = 'cs_a8ba1ef8b549189d415618ba993a4a0c6f2f7166';

    final prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('locale');
    language ??= 'ar';

    final response = await http.get(
      Uri.parse(
          '$baseUrl/products/categories/$categoryId?lang=$language&per_page=100&'),
      headers: {
        'Authorization': 'Basic ' +
            base64Encode(utf8.encode('$consumerKey:$consumerSecret')),
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      // ✅ Since it's a single object, wrap it inside a List
      return [Category.fromJson(jsonResponse)];
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<Brand> fetchBrand(int id) async {
    final prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('locale') ?? 'ar';
    final String consumerKey = 'ck_1c63c710561ce560194698e6f676fe67ee2ed927';
    final String consumerSecret = 'cs_a8ba1ef8b549189d415618ba993a4a0c6f2f7166';

    try {
      final response = await http.get(
        Uri.parse('https://gomla.sa/wp-json/wc/v3/products/brands/$id'),
        headers: {
          'Authorization': 'Basic ' +
              base64Encode(utf8.encode('$consumerKey:$consumerSecret')),
        },
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData is Map<String, dynamic>) {
          String imageUrl = '';
          if (decodedData['image'] != null && decodedData['image']['src'] != null) {
            imageUrl = decodedData['image']['src'];
          }
          return Brand(
            name: decodedData['name'] ?? '',
            imageUrl: imageUrl,
            id: decodedData['id'] ?? 0, slug: decodedData['slug'] ?? '',
          );
        } else {
          throw Exception('Unexpected response format, expected a brand object');
        }
      } else {
        throw Exception('Failed to load brand');
      }
    } catch (e) {
      print("Error fetching brand: $e");
      return Brand(name: '', imageUrl: '', id: 0, slug: '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2),
                    child: Text(
                      AppLocalizations.of(context)!.productBrand,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  FutureBuilder<Brand>(
                    future: brandFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 100,
                            height: 50,
                            color: Colors.white,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        final brand = snapshot.data!;
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                      if (brand.imageUrl.isNotEmpty)
                      Image.network(brand.imageUrl, width: 60),
                      if (brand.imageUrl.isEmpty)
                      Image.asset(ImageAssets.logo, width: 60),
                              SizedBox(width: 10),
                              Text(
                                brand.name,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return const Text('No brand available');
                      }
                    },
                  ),

                ],
              ),
            ),
            Divider(color: Color(0xffEAEAEA)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4.0, vertical: 2.0),
                    child: Text(
                      AppLocalizations.of(context)!.categoryOfProducts,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  FutureBuilder<List<Category>>(
                    future: subCategoriesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 100,
                            height: 50,
                            color: Colors.white,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        print('Error: ${snapshot.error}');
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData &&
                          snapshot.data!.isNotEmpty) {
                        final category =
                            snapshot.data![0]; // Assuming the first category
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                              if (category.imageUrl.isNotEmpty)
                                Image.network(category.imageUrl, width: 60),
                              if (category.imageUrl.isEmpty)
                                Image.asset(ImageAssets.logo, width: 60),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  category.name.replaceAll('&amp;', '&'),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
