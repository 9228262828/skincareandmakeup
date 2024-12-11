import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/home_screen_provider.dart';
import '../services/woocommerce_service.dart';
import '../shared/utils/app_values.dart';
import '../widgets/app_bar.dart';
import '../widgets/fade_image.dart';
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
  int? selectedCategoryId; // Track the currently selected category
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    wooCommerceService = WooCommerceService();
    fetchMainCategories();
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
      appBar: CustomAppBar(title: '', home: true),
      body: ListView(
        children: [
          // Display categories in rows of 3
          for (int i = 0; i < homeScreenProvider.categories.length; i += 3)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display 3 categories in each row with space between them
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (int j = i; j < i + 3 && j < homeScreenProvider.categories.length; j++)
                      _buildCategoryTile(homeScreenProvider.categories[j]),
                  ],
                ),
                // Display subcategories for each category when clicked, directly under the category
                for (int j = i; j < i + 3 && j < homeScreenProvider.categories.length; j++)
                  if (showSubCategories[homeScreenProvider.categories[j].id] == true)
                    _buildSubCategories(homeScreenProvider.categories[j]),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(Category category) {

    showSubCategories.putIfAbsent(category.id, () => false);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {

            if (selectedCategoryId == category.id) {
              showSubCategories[category.id] = false;
              selectedCategoryId = null;
            } else {
              if (selectedCategoryId != null) {
                showSubCategories[selectedCategoryId!] = false;
              }
              showSubCategories[category.id] = true;
              selectedCategoryId = category.id;
            }
          });

          if (!subCategories.containsKey(category.id)) {
            fetchSubCategories(category.id);
          }
        },
        child: Container(
          width: double.infinity,
          margin:  EdgeInsets.all(4.0),
padding:  selectedCategoryId == category.id ? EdgeInsets.all(5.0) : EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: selectedCategoryId == category.id
                  ? Colors.grey.shade200
                  : Colors.transparent,
              width: 2.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category image container
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  imageUrl: category.imageUrl,
                  height: selectedCategoryId == category.id
                      ? MediaQuery.of(context).size.height * 0.24: mediaQueryHeight(context) * 0.23,
                  fit: BoxFit.fill,
                  placeholder: (context, url) => Center(
                    child: FadeInOutImage(height: MediaQuery.of(context).size.height * 0.23),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              const SizedBox(height: 4.0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _stripHtmlTags(category.name),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubCategories(Category category) {
    return Container(
      width: double.infinity, // Full width for subcategories
      padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 4), // Padding for subcategories
      child: Column(
        children: subCategories[category.id]?.map((subCategory) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              tileColor: Colors.grey.shade100,
              leading: CachedNetworkImage(
                imageUrl: subCategory.imageUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Center(child: FadeInOutImage(height: 40)),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              title: Text(
                _stripHtmlTags(subCategory.name),
                style: const TextStyle(fontSize: 14),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductListingScreen(
                      categoryId: subCategory.id,
                      categoryName: subCategory.name,
                      type: "id",
                      isLink: false,
                    ),
                  ),
                );
              },
            ),
          );
        }).toList() ??
            [],
      ),
    );
  }

  String _stripHtmlTags(String htmlString) {
    final document = parse(htmlString);
    return parse(document.body!.text).documentElement!.text;
  }
}
