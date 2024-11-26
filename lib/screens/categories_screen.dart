import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:html/parser.dart';
import 'package:skincare/providers/home_screen_provider.dart';
import 'package:skincare/widgets/app_bar.dart';
import 'package:skincare/widgets/fade_image.dart';
import '../services/woocommerce_service.dart';
import '../models/category.dart';
import 'package:provider/provider.dart';
import 'product_listing_screen.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late WooCommerceService wooCommerceService;
  List<Category> mainCategories = [];
  Map<int, bool> showSubCategories = {}; // Track visibility of subcategories
  Map<int, List<Category>> subCategories = {}; // Store subcategories by parent ID
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    wooCommerceService = WooCommerceService();
    // fetchMainCategories();
  }

  Future<void> fetchMainCategories() async {
    try {
      mainCategories = await wooCommerceService.fetchCategories(context);
      // filter out categories with no image
      mainCategories = mainCategories.where((category) => category.imageUrl.isNotEmpty).toList();
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchSubCategories(int parentId) async {
    try {
      List<Category> fetchedSubCategories = await wooCommerceService.fetchSubCategories(context, parentId);
      setState(() {
        subCategories[parentId] = fetchedSubCategories;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeScreenProvider = Provider.of<HomeScreenProvider>(context);
    return Scaffold(
      appBar: CustomAppBar(title: ''),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: homeScreenProvider.categories.length,
        itemBuilder: (context, index) {
          final category = homeScreenProvider.categories[index];
          // Initialize subcategory visibility
          showSubCategories.putIfAbsent(category.id, () => false);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    showSubCategories[category.id] = !showSubCategories[category.id]!;
                  });
                  if (!subCategories.containsKey(category.id)) {
                    fetchSubCategories(category.id);
                  }
                },
                child: Column(
                  children: [
                    CachedNetworkImage(
                      imageUrl: category.imageUrl,
                      width: double.infinity,
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(child: FadeInOutImage(height: 100)),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      _stripHtmlTags(category.name),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (showSubCategories[category.id] == true)
                Column(
                  children: subCategories[category.id]?.map((subCategory) {
                        return ListTile(
                          leading: CachedNetworkImage(
                            imageUrl: subCategory.imageUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(child: FadeInOutImage(height: 40)),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                          title: Text(
                            _stripHtmlTags(subCategory.name),
                            style: TextStyle(fontSize: 14),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductListingScreen(
                                  categoryId: subCategory.id,
                                  categoryName: subCategory.name,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList() ??
                      [],
                ),
              SizedBox(height: 16.0) // Add a divider between categories for better visual separation
            ],
          );
        },
      ),
    );
  }
}

String _stripHtmlTags(String htmlString) {
  final document = parse(htmlString);
  return parse(document.body!.text).documentElement!.text;
}
