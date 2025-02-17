import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:shimmer/shimmer.dart';

import '../models/category.dart';
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
  Map<int, bool> showSubCategories = {};
  Map<int, List<Category>> subCategories = {};
  Map<int, bool> isSubCategoryLoading = {};
  int? selectedCategoryId;
  bool isLoading = true;
  bool isLoadingMore = false;
  bool isLastPage = false;
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    wooCommerceService = WooCommerceService();
    fetchMainCategories();
  }

  Future<void> fetchMainCategories({int page = 1}) async {
    if (isLoadingMore || isLastPage) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      List<Category> newCategories =
          await wooCommerceService.fetchCategories(page: page);
      if (newCategories.isEmpty) {
        setState(() {
          isLastPage = true;
        });
      } else {
        setState(() {
          mainCategories.addAll(newCategories);
          currentPage++;
        });
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  Future<void> fetchSubCategories(int parentId) async {
    setState(() {
      isSubCategoryLoading[parentId] = true;
    });
    try {
      List<Category> fetchedSubCategories =
          await wooCommerceService.fetchSubCategories(parentId);
      setState(() {
        subCategories[parentId] = fetchedSubCategories;
        isSubCategoryLoading[parentId] = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isSubCategoryLoading[parentId] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '', home: true),
      body: isLoading
          ? _buildMainCategoryShimmer()
          : NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollEndNotification &&
                    scrollNotification.metrics.pixels ==
                        scrollNotification.metrics.maxScrollExtent) {
                  fetchMainCategories(page: currentPage);
                }
                return false;
              },
              child: ListView(
                children: [
                  for (int i = 0; i < mainCategories.length; i += 3)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (int j = i;
                                j < i + 3 && j < mainCategories.length;
                                j++)
                              _buildCategoryTile(mainCategories[j]),
                          ],
                        ),
                        for (int j = i;
                            j < i + 3 && j < mainCategories.length;
                            j++)
                          if (showSubCategories[mainCategories[j].id] == true)
                            isSubCategoryLoading[mainCategories[j].id] == true
                                ? _buildSubCategoryShimmer()
                                : _buildSubCategories(mainCategories[j]),
                      ],
                    ),
                  if (isLoadingMore)
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.23,
                        child: _buildMainCategoryShimmer())
                ],
              ),
            ),
    );
  }
// filter the images
  Widget _buildMainCategoryShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Three items in a row
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.8, // Adjust to ensure image and text fit well
      ),
      itemCount: 12, // Number of shimmer placeholders
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder for image
              Container(
                height: MediaQuery.of(context).size.height * 0.17,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 8.0),
              // Placeholder for name container
              Container(
                height: 20.0,
                width: double.infinity,
                color: Colors.grey[300],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryTile(Category category) {

    showSubCategories.putIfAbsent(category.id, () => false);
    isSubCategoryLoading.putIfAbsent(category.id, () => false);

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

          padding: selectedCategoryId == category.id
              ? EdgeInsets.all(5.0)
              : EdgeInsets.all(4.0),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  imageUrl: category.imageUrl,
                  height: selectedCategoryId == category.id
                      ? MediaQuery.of(context).size.height * 0.12
                      : mediaQueryHeight(context) * 0.13,
                  fit: BoxFit.fill,
                  placeholder: (context, url) => Center(
                    child: FadeInOutImage(height: MediaQuery.of(context).size.height * 0.15),
                  ),
                  errorWidget: (context, url, error) => Image.asset("assets/placeholder.png"),
                ),
              ),
              const SizedBox(height: 4.0),
              Container(
                height:   mediaQueryHeight(context) * 0.05,
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Text(
                    _stripHtmlTags(category.name),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,

                    ),
                    maxLines: 2,
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
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
                    errorWidget: (context, url, error) =>
                        Center(child: FadeInOutImage(height: 40)),
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

  Widget _buildSubCategoryShimmer() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 60,
              color: Colors.grey[300],
            ),
          ),
        );
      },
    );
  }

  String _stripHtmlTags(String htmlString) {
    final document = parse(htmlString);
    return parse(document.body!.text).documentElement!.text;
  }
}
