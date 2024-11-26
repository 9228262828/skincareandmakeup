import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skincare/models/fakeProduct.dart';
import 'package:html/parser.dart';
import 'package:skincare/contstants.dart';
import 'package:skincare/providers/home_screen_provider.dart';
import 'package:skincare/screens/brand_listing_screen.dart';
import 'package:skincare/screens/product_screen.dart';
import 'package:skincare/widgets/app_bar.dart';
import 'package:skincare/widgets/fade_image.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../services/woocommerce_service.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../widgets/product_card.dart';
import 'product_listing_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late WooCommerceService wooCommerceService;
  List<Category> categories = [];
  List<Product> pets = [];
  List<Product> skinCare = [];
  List<Product> hairCare = [];
  List<Product> makeupCat = [];
  bool categoriesLoading = true;
  bool petsLoading = true;
  bool skinCareLoading = true;
  bool hairCareLoading = true;
  bool makeupCatLoading = true;

  final List<Map<String, dynamic>> sliderCategories = [
    {
      'brandId': 502, // Example brand ID
      'imageUrl': 'assets/3000-x-1200-yello-color-scaled.jpg',
      'brandName': 'The Bathland',
    },
    {
      'brandId': 504, // Example brand ID
      'imageUrl': 'assets/3000-x-1200-yello-color-scaled.jpg',
      'brandName': 'TRINDIVA',
    },
    {
      'brandId': 497, // Example brand ID
      'imageUrl': 'assets/3000-x-1200-yello-color-scaled.jpg',
      'brandName': 'Clary',
    }
  ];

  @override
  void initState() {
    super.initState();
    // wooCommerceService = WooCommerceService();
    // fetchInitialData();
    // Provider.of<HomeScreenProvider>(context, listen: false).fetchInitialData(context);
  }

  Future<void> fetchInitialData() async {
    try {
      categories = await wooCommerceService.fetchHomeCategories(context);
      pets = await wooCommerceService.fetchProducts(25, 1, context);
      skinCare = await wooCommerceService.fetchProducts(153, 1, context);
      hairCare = await wooCommerceService.fetchProducts(114, 1, context);
      makeupCat = await wooCommerceService.fetchProducts(160, 2, context);
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        categoriesLoading = false;
        petsLoading = false;
        skinCareLoading = false;
        hairCareLoading = false;
        makeupCatLoading = false;
      });
    }
  }

  String _stripHtmlTags(String htmlString) {
    final document = parse(htmlString);
    return parse(document.body!.text).documentElement!.text;
  }

  @override
  Widget build(BuildContext context) {
    final homeScreenProvider = Provider.of<HomeScreenProvider>(context);
    return Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context)!.home),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                buildSlider(),
                Container(
                  height: 150,
                  decoration: const BoxDecoration(),
                  width: MediaQuery.of(context).size.width,
                  child: const SizedBox(),
                  // child: Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     crossAxisAlignment: CrossAxisAlignment.center,
                  //     mainAxisSize: MainAxisSize.max,
                  //     children: [
                  //       Container(
                  //         decoration: BoxDecoration(
                  //           borderRadius: BorderRadius.circular(8.0),
                  //           boxShadow: [
                  //             BoxShadow(
                  //               color: borderColor,
                  //               spreadRadius: 1,
                  //               blurRadius: 5,
                  //               offset: const Offset(
                  //                   0, 0), // changes position of shadow
                  //             ),
                  //           ],
                  //           color: Colors.white,
                  //         ),
                  //         child: Column(
                  //           children: [
                  //             Padding(
                  //               padding: const EdgeInsets.all(2.0),
                  //               child: GestureDetector(
                  //                 onTap: () {
                  //                   // Navigator.push(
                  //                   //   context,
                  //                   //   MaterialPageRoute(
                  //                   //     builder: (context) => const BrandListingScreen(
                  //                   //       brandId: 488, // Example brand ID
                  //                   //       brandName: 'RHEA BEAUTY',
                  //                   //     ),
                  //                   //   ),
                  //                   // );
                  //                 },
                  //                 child: Image.asset(
                  //                   width: MediaQuery.of(context).size.width /
                  //                       3.5,
                  //                   height: 110,
                  //                   fit: BoxFit.cover,
                  //                   'assets/3000-x-1200-yello-color-scaled.jpg',
                  //                 ),
                  //               ),
                  //             ),
                  //             const Text('صحة وجمال'),
                  //           ],
                  //         ),
                  //       ),
                  //       Container(
                  //         decoration: BoxDecoration(
                  //           borderRadius: BorderRadius.circular(8.0),
                  //           boxShadow: [
                  //             BoxShadow(
                  //               color: borderColor,
                  //               spreadRadius: 1,
                  //               blurRadius: 5,
                  //               offset: const Offset(
                  //                   0, 0), // changes position of shadow
                  //             ),
                  //           ],
                  //           color: Colors.white,
                  //         ),
                  //         child: Column(
                  //           children: [
                  //             Padding(
                  //               padding: const EdgeInsets.all(2.0),
                  //               child: GestureDetector(
                  //                 onTap: () {
                  //                   // Navigator.push(
                  //                   //   context,
                  //                   //   MaterialPageRoute(
                  //                   //     builder: (context) => const BrandListingScreen(
                  //                   //       brandId: 488, // Example brand ID
                  //                   //       brandName: 'RHEA BEAUTY',
                  //                   //     ),
                  //                   //   ),
                  //                   // );
                  //                 },
                  //                 child: Image.asset(
                  //                   width: MediaQuery.of(context).size.width /
                  //                       3.5,
                  //                   height: 110,
                  //                   fit: BoxFit.cover,
                  //                   'assets/3000-x-1200-yello-color-scaled.jpg',
                  //                 ),
                  //               ),
                  //             ),
                  //             const Text('فيتنس'),
                  //           ],
                  //         ),
                  //       ),
                  //       Container(
                  //         padding: const EdgeInsets.all(0.0),
                  //         decoration: BoxDecoration(
                  //           borderRadius: BorderRadius.circular(8.0),
                  //           boxShadow: [
                  //             BoxShadow(
                  //               color: borderColor,
                  //               spreadRadius: -2,
                  //               blurRadius: 10,
                  //               offset: const Offset(
                  //                   0, 10), // changes position of shadow
                  //             ),
                  //           ],
                  //           color: Colors.white,
                  //         ),
                  //         child: Column(
                  //           children: [
                  //             Padding(
                  //               padding: const EdgeInsets.all(2.0),
                  //               child: GestureDetector(
                  //                 onTap: () {
                  //                   // Navigator.push(
                  //                   //   context,
                  //                   //   MaterialPageRoute(
                  //                   //     builder: (context) => const BrandListingScreen(
                  //                   //       brandId: 488, // Example brand ID
                  //                   //       brandName: 'RHEA BEAUTY',
                  //                   //     ),
                  //                   //   ),
                  //                   // );
                  //                 },
                  //                 child: Image.asset(
                  //                   width: MediaQuery.of(context).size.width /
                  //                       3.5,
                  //                   height: 110,
                  //                   fit: BoxFit.cover,
                  //                   'assets/3000-x-1200-yello-color-scaled.jpg',
                  //                 ),
                  //               ),
                  //             ),
                  //             const Text('حيوانات اليفه'),
                  //           ],
                  //         ),
                  //       ),
                  //     ],
                  //   ),

                  // ),
                ),
              ],
            ),
            // const SizedBox(height: 100.0),

            homeScreenProvider.homeCategoriesLoading
                ? const FadeInOutImage(
                    height: 200,
                  )
                : buildCategoriesList(homeScreenProvider.homeCategories),
            buildProductSection("عروض جملة", homeScreenProvider.pets, 53),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const BrandListingScreen(
                      //       brandId: 488, // Example brand ID
                      //       brandName: 'RHEA BEAUTY',
                      //     ),
                      //   ),
                      // );
                    },
                    child: Image.asset(
                      width: MediaQuery.of(context).size.width - 4,
                      'assets/3000-x-1200-yello-color-scaled.jpg',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            buildProductSection("الاعلى تقييما", homeScreenProvider.pets, 53),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const BrandListingScreen(
                      //       brandId: 488, // Example brand ID
                      //       brandName: 'RHEA BEAUTY',
                      //     ),
                      //   ),
                      // );
                    },
                    child: Image.asset(
                      width: MediaQuery.of(context).size.width / 2 - 4,
                      'assets/3000-x-1200-yello-color-scaled.jpg',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const BrandListingScreen(
                      //       brandId: 488, // Example brand ID
                      //       brandName: 'RHEA BEAUTY',
                      //     ),
                      //   ),
                      // );
                    },
                    child: Image.asset(
                      width: MediaQuery.of(context).size.width / 2 - 4,
                      'assets/3000-x-1200-yello-color-scaled.jpg',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            buildProductSection(
                "احدث منتجات بيوتي", homeScreenProvider.pets, 53),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const BrandListingScreen(
                      //       brandId: 488, // Example brand ID
                      //       brandName: 'RHEA BEAUTY',
                      //     ),
                      //   ),
                      // );
                    },
                    child: Image.asset(
                      width: MediaQuery.of(context).size.width / 2 - 4,
                      'assets/3000-x-1200-yello-color-scaled.jpg',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const BrandListingScreen(
                      //       brandId: 488, // Example brand ID
                      //       brandName: 'RHEA BEAUTY',
                      //     ),
                      //   ),
                      // );
                    },
                    child: Image.asset(
                      width: MediaQuery.of(context).size.width / 2 - 4,
                      'assets/3000-x-1200-yello-color-scaled.jpg',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            buildProductSection(
                "احدث منتجات الجيم", homeScreenProvider.pets, 53),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const BrandListingScreen(
                      //       brandId: 488, // Example brand ID
                      //       brandName: 'RHEA BEAUTY',
                      //     ),
                      //   ),
                      // );
                    },
                    child: Image.asset(
                      width: MediaQuery.of(context).size.width / 2 - 4,
                      'assets/3000-x-1200-yello-color-scaled.jpg',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const BrandListingScreen(
                      //       brandId: 488, // Example brand ID
                      //       brandName: 'RHEA BEAUTY',
                      //     ),
                      //   ),
                      // );
                    },
                    child: Image.asset(
                      width: MediaQuery.of(context).size.width / 2 - 4,
                      'assets/3000-x-1200-yello-color-scaled.jpg',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            buildProductSection(
                "احدث منتجات بيتس", homeScreenProvider.pets, 53),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const BrandListingScreen(
                      //       brandId: 488, // Example brand ID
                      //       brandName: 'RHEA BEAUTY',
                      //     ),
                      //   ),
                      // );
                    },
                    child: Image.asset(
                      width: MediaQuery.of(context).size.width / 2 - 4,
                      'assets/3000-x-1200-yello-color-scaled.jpg',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const BrandListingScreen(
                      //       brandId: 488, // Example brand ID
                      //       brandName: 'RHEA BEAUTY',
                      //     ),
                      //   ),
                      // );
                    },
                    child: Image.asset(
                      width: MediaQuery.of(context).size.width / 2 - 4,
                      'assets/3000-x-1200-yello-color-scaled.jpg',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            buildProductSection("منتجات مميزة", homeScreenProvider.pets, 53),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget buildSlider() {
    if (sliderCategories == null || sliderCategories.isEmpty) {
      return Skeletonizer(
        child: Container(
          height: 200.0,
          color: Colors.grey[300],
        ),
      );
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 200.0,
        autoPlayCurve: Curves.easeInOutCubic,
        autoPlay: true,
        enlargeCenterPage: false,
        viewportFraction: 1.0,
      ),
      items: sliderCategories.map((brand) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BrandListingScreen(
                      brandId: brand['brandId'],
                      brandName: brand['brandName'],
                    ),
                  ),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Column(
                  children: [
                    Image.asset(
                      brand['imageUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error),
                    ),
                    Container(
                      height: 15,
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                          color: Colors.yellow.withOpacity(0.3),
                          blurRadius: 1,
                          blurStyle: BlurStyle.normal,
                          spreadRadius: 1,
                        )
                      ]),
                    )
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget buildCategoriesList(List categories) {
    int halfLength =
        (categories.length / 2).ceil(); // Calculate the halfway point

    // Split the list into two halves
    List firstRowCategories = categories.sublist(0, halfLength);
    List secondRowCategories = categories.sublist(halfLength);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                // First row of categories
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: firstRowCategories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        width: 80,
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.transparent,
                              backgroundImage: CachedNetworkImageProvider(
                                category.imageUrl,
                              ),
                              radius: 30,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _stripHtmlTags(category.name),
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32), // Add spacing between rows
                // Second row of categories
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: secondRowCategories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        width: 80,
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.transparent,
                              backgroundImage: CachedNetworkImageProvider(
                                category.imageUrl,
                              ),
                              radius: 30,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _stripHtmlTags(category.name),
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProductSection(String title, List<Product> products, categoryId) {
    return Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4.0),
                      width: 20,
                      height: 2,
                      color: mainColor,
                    ),
                  ],
                ),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductListingScreen(
                            categoryId: categoryId,
                            categoryName: title,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context)!.all,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 2.2,
                child: (products.isEmpty)
                    ? Skeletonizer(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            return SizedBox(
                              width: MediaQuery.of(context).size.width / 2.2,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                // if product loaded sho it if not show placeholder
                                child: ProductCard(product: fakeProduct),
                              ),
                            );
                          },
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductScreen(
                                      productId: products[index].id),
                                ),
                              );
                            },
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width / 2.2,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                // if product loaded sho it if not show placeholder
                                child: ProductCard(product: products[index]),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
