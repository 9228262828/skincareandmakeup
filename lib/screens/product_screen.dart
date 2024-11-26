import 'dart:convert';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skincare/contstants.dart';
import 'package:skincare/models/cart.dart';
import 'package:skincare/providers/locale_provider.dart';
import 'package:skincare/services/auth_service.dart';
import 'package:skincare/widgets/app_bar.dart';
import 'package:skincare/widgets/fade_image.dart';
import 'package:skincare/widgets/product_card.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../main.dart';
import '../services/woocommerce_service.dart';
import '../models/product.dart';
import 'package:provider/provider.dart';
import 'package:html/parser.dart' show parse;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:skincare/models/variation.dart';

import 'login_screen.dart';

class ProductScreen extends StatefulWidget {
  final int productId;
  final String? variationId;

  const ProductScreen({super.key, required this.productId, this.variationId});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen>
    with SingleTickerProviderStateMixin {
  late WooCommerceService wooCommerceService;
  Product? product;
  bool isLoading = true;
  bool isRelatedLoading = true;
  List<Product> relatedProducts = [];
  List<Variation> variations = [];
  Variation? selectedVariation;
  String imageUrl = '';
  late String price = '';
  bool isLoggedIn = false;
  final _reviewController = TextEditingController();
  late TabController _tabController;
  int quantity = 1;
  List<Product> frequentlyBoughtTogether = [];
  bool isFrequentlyBoughtTogetherLoading = true;

  final List<Map<String, dynamic>> clientRatings = [
    {
      "rating": 5,
      "review":
          "خدمة ممتازة! فاقت كل توقعاتي. سأعود بالتأكيد للاستفادة من خدماتكم مرة أخرى."
    },
    {
      "rating": 4,
      "review":
          "عمل رائع بشكل عام. كان هناك بعض التعديلات البسيطة المطلوبة، لكنها تمت بسرعة."
    },
    {
      "rating": 3,
      "review": "تجربة متوسطة. العمل كان جيدًا، لكن لم يكن مميزًا بشكل خاص."
    },
  ];
  // Fake data for skeleton loading
  final List<String> fakeImages = [
    'assets/testproductimge.png',
    'assets/testproductimge.png',
    'assets/testproductimge.png'
  ];

  @override
  void initState() {
    super.initState();
    wooCommerceService = WooCommerceService();
    fetchProductDetails();
    fetchVariations();
    wooCommerceService
        .fetchFrequentlyBoughtTogether(widget.productId)
        .then((items) {
      setState(() {
        frequentlyBoughtTogether = items;
        isFrequentlyBoughtTogetherLoading = false;
      });
    });
    _checkLoginStatus();
    _tabController = TabController(length: 3, vsync: this);
  }

  bool _isLoggedIn = false;
  Future<void> _checkLoginStatus() async {
    await AuthService.isLoggedIn().then((value) {
      setState(() {
        _isLoggedIn = value;
      });
    });
  }

  Future<void> fetchProductDetails() async {
    try {
      product =
          await wooCommerceService.fetchProduct(widget.productId, context);
      price = product!.price.toString();
      relatedProducts = await wooCommerceService.fetchProducts(
          product!.categoryId, 1, context);
      print(relatedProducts[0].name);
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
        isRelatedLoading = false;
      });
    }
  }

  String _stripHtmlTags(String htmlString) {
    final document = parse(htmlString);
    return parse(document.body!.text).documentElement!.text;
  }

  void _addToCart() {
    final cart = Provider.of<Cart>(context, listen: false);
    if (product != null) {
      cart.addItem(product!, selectedVariation);
      cart.updateQuantity(product!, quantity);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.addedtoCart),
        ),
      );
    }
  }

  void fetchVariations() async {
    try {
      List<Variation> fetchedVariations =
          await fetchProductVariations(widget.productId);
      setState(() {
        variations = fetchedVariations;
        variations = variations.reversed.toList();
        selectedVariation = variations.first;
        imageUrl = selectedVariation!.imageUrl;
        price = selectedVariation!.price;
      });
    } catch (e) {
      print('Error fetching variations: $e');
    }
  }

  Future<List<Variation>> fetchProductVariations(int productId) async {
    final response = await http.get(
        Uri.parse('https://mskra.com/wp-json/custom/v1/variations/$productId'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((variation) => Variation.fromJson(variation))
          .toList();
    } else {
      throw Exception('Failed to load variations');
    }
  }

  void _addGroupToCart() {
    final cart = Provider.of<Cart>(context, listen: false);
    for (var item in frequentlyBoughtTogether) {
      cart.addItem(item, null); // Assuming no variations for simplicity
      cart.updateQuantity(item, 1);
    }
    // add current product to cart
    cart.addItem(product!, selectedVariation);
    cart.updateQuantity(product!, quantity);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.addToBag),
      ),
    );
  }

  Future<void> _submitReview() async {
    try {
      final userInfo = await AuthService.fetchUserInfo();
      final response = await wooCommerceService.submitReview(
        productId: widget.productId,
        review: _reviewController.text,
        userName: userInfo['username'],
        userEmail: userInfo['email'],
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review submitted successfully')));
        _reviewController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to submit review')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to submit review: $e')));
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Navigate back to the selected screen from the bottom navigation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainScreen(), // Return to the MainScreen
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    late double discount = product!.regularPrice > 0
        ? (product!.regularPrice - product!.price) / product!.regularPrice * 100
        : 0;

    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      appBar: const CustomAppBar(title: ''),
      body: isLoading
          ? Skeletonizer(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    buildSkeletonSlider(),
                    const SizedBox(height: 16),
                    Container(
                      height: 24,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "جل الكولاجين البحري وحمض الهيالورونيك من بوبانا 250مل",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 66, 66, 66),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 16,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "125.0 جنية",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 66, 66, 66),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(
                              color: borderColor), // General bottom border
                          top: BorderSide(color: borderColor),
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        tabs: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            alignment: Alignment.center,
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)!.shortDescription,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            padding: const EdgeInsets.all(8.0),
                            alignment: Alignment.center,
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)!.description,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const Text(
                            "مراجعة العملاء",
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                        indicatorColor: Colors.transparent,
                        labelColor: mainColor,
                        unselectedLabelColor: Colors.black,
                        indicatorSize: TabBarIndicatorSize.label,
                      ),
                    ),
                    SizedBox(
                      height: 150,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 0,
                                  blurRadius: 15,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Text(
                                  _stripHtmlTags('product!.short_description'),
                                  textAlign:
                                      (localeProvider.locale.languageCode ==
                                              'ar')
                                          ? TextAlign.right
                                          : TextAlign.left,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.white,
                              border: Border.all(
                                color: borderColor,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Text(
                                  _stripHtmlTags('product!.description'),
                                  textAlign:
                                      (localeProvider.locale.languageCode ==
                                              'ar')
                                          ? TextAlign.right
                                          : TextAlign.left,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: clientRatings.length,
                            itemBuilder: (context, index) {
                              final rating = clientRatings[index]['rating'];
                              final review = clientRatings[index]['review'];
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: List.generate(
                                          rating,
                                          (index) => const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 14,
                                              )),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      review,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  fillOverscroll: true,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(children: [
                          buildImageSlider(),
                        ]),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 16),
                                    Text(
                                      product!.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 66, 66, 66),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (variations.isNotEmpty)
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: variations.map((variation) {
                                      final attributeWithColor =
                                          variation.attributes.firstWhere(
                                        (attr) => attr.color != null,
                                        orElse: () => Attribute(
                                            name: '',
                                            color: null,
                                            slug: '',
                                            taxonomy: ''),
                                      );

                                      final color = attributeWithColor.color;
                                      final hasColor = color != null;

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        child: Container(
                                          width: hasColor ? 30 : null,
                                          height: 30,
                                          padding: const EdgeInsets.all(0.0),
                                          decoration:
                                              selectedVariation == variation
                                                  ? BoxDecoration(
                                                      border: Border.all(
                                                          color: mainColor,
                                                          width: 2.0),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    )
                                                  : null,
                                          child: ChoiceChip(
                                            label: hasColor
                                                ? Container()
                                                : Text(
                                                    variation.attributes
                                                        .map(
                                                            (attr) => attr.name)
                                                        .join(", "),
                                                    style: TextStyle(
                                                        color: mainColor,
                                                        fontSize: 10),
                                                  ),
                                            selected:
                                                selectedVariation == variation,
                                            selectedColor: hasColor
                                                ? Color(int.parse('0xff' +
                                                    color!.substring(1)))
                                                : null,
                                            backgroundColor: hasColor
                                                ? Color(int.parse('0xff' +
                                                    color!.substring(1)))
                                                : null,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            showCheckmark: false,
                                            selectedShadowColor: mainColor,
                                            onSelected: (bool selected) {
                                              setState(() {
                                                selectedVariation = variation;
                                                imageUrl = variation.imageUrl;
                                                price = variation.price;
                                              });
                                            },
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (discount != 0)
                                      Text(
                                        '${product!.regularPrice} ${AppLocalizations.of(context)!.egp} ',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                    Text(
                                      '${price ?? product!.price} ${AppLocalizations.of(context)!.egp} ',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    if (discount != 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        color: Colors.pink,
                                        child: Text(
                                          '-${discount.toStringAsFixed(0)} %',
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    bottom: BorderSide(
                                        color:
                                            borderColor), // General bottom border
                                    top: BorderSide(color: borderColor),
                                  ),
                                ),
                                child: TabBar(
                                  controller: _tabController,
                                  tabs: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      alignment: Alignment.center,
                                      child: Center(
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .shortDescription,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      padding: const EdgeInsets.all(8.0),
                                      alignment: Alignment.center,
                                      child: Center(
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .description,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    const Text(
                                      "مراجعة العملاء",
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                  indicatorColor: Colors
                                      .transparent, // Remove the default indicator
                                  labelColor: mainColor,
                                  unselectedLabelColor: Colors.black,
                                  indicatorSize: TabBarIndicatorSize.label,
                                ),
                              ),
                              SizedBox(
                                height: 150,
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 0,
                                            blurRadius: 15,
                                            offset: const Offset(0,
                                                0), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: Text(
                                            _stripHtmlTags(
                                                product!.short_description),
                                            textAlign: (localeProvider
                                                        .locale.languageCode ==
                                                    'ar')
                                                ? TextAlign.right
                                                : TextAlign.left,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: Colors.white,
                                        border: Border.all(
                                          color: borderColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: Text(
                                            _stripHtmlTags(
                                                product!.description),
                                            textAlign: (localeProvider
                                                        .locale.languageCode ==
                                                    'ar')
                                                ? TextAlign.right
                                                : TextAlign.left,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                    ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: clientRatings.length,
                                      itemBuilder: (context, index) {
                                        final rating =
                                            clientRatings[index]['rating'];
                                        final review =
                                            clientRatings[index]['review'];
                                        return Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: List.generate(
                                                    rating,
                                                    (index) => const Icon(
                                                          Icons.star,
                                                          color: Colors.amber,
                                                          size: 14,
                                                        )),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                review,
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              if (!isFrequentlyBoughtTogetherLoading &&
                                  frequentlyBoughtTogether.isNotEmpty)
                                Column(
                                  children: [
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            8.0, 0.0, 8.0, 0.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                Text(
                                                  "منتجات يتم شراءا معا",
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 4.0),
                                                  width: 20,
                                                  height: 2,
                                                  color: mainColor,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16.0),
                                    Padding(
                                      padding: const EdgeInsets.all(0.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                2.5,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount:
                                                  frequentlyBoughtTogether
                                                      .length,
                                              itemBuilder: (context, index) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ProductScreen(
                                                                productId:
                                                                    frequentlyBoughtTogether[
                                                                            index]
                                                                        .id), // Example product ID
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            2,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: frequentlyBoughtTogether[
                                                                      index]
                                                                  .imageUrl !=
                                                              null
                                                          ? ProductCard(
                                                              product:
                                                                  frequentlyBoughtTogether[
                                                                      index])
                                                          : Image.asset(
                                                              'assets/grey_image.jpeg'),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: ElevatedButton(
                                        onPressed: _addGroupToCart,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: mainColor,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 0.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                        ),
                                        child: Text(
                                          'أشتري المنتجات معا',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (_isLoggedIn != false) ...[
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _reviewController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: borderColor, width: 0),
                                        borderRadius:
                                            BorderRadius.circular(4.0)),
                                    labelText: AppLocalizations.of(context)!
                                        .writeReview,
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: borderColor, width: 1),
                                        borderRadius:
                                            BorderRadius.circular(4.0)),
                                  ),
                                  maxLines: 5,
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: mainColor,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                  ),
                                  onPressed: _submitReview,
                                  child: Text(AppLocalizations.of(context)!
                                      .submitReview),
                                ),
                              ] else ...[
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: mainColor,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(AppLocalizations.of(context)!
                                      .reviewProduct),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // const SizedBox(height: 64),
                        const Divider(
                          thickness: 1,
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        // ),
                        // const SizedBox(height: 16),
                        // const SizedBox(
                        //   height: 32,
                        // ),
                        if (!isRelatedLoading && relatedProducts.isNotEmpty)
                          Column(
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      8.0, 0.0, 8.0, 0.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .relatedProducts,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 4.0),
                                            width: 20,
                                            height: 2,
                                            color: mainColor,
                                          ),
                                        ],
                                      ),
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
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.5,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: relatedProducts.length,
                                        itemBuilder: (context, index) {
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ProductScreen(
                                                      productId: relatedProducts[
                                                              index]
                                                          .id), // Example product ID
                                                ),
                                              );
                                            },
                                            child: SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: relatedProducts[index]
                                                            .imageUrl !=
                                                        null
                                                    ? ProductCard(
                                                        product:
                                                            relatedProducts[
                                                                index])
                                                    : Image.asset(
                                                        'assets/grey_image.jpeg'),
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
                          ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                )
              ],
            ),
      bottomSheet: BottomAppBar(
        elevation: 0,
        color: Colors.white,
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 0,
                blurRadius: 10,
                offset:
                    const Offset(0, -2), // Positioning the shadow at the top
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 30.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  textDirection: localeProvider.locale.languageCode == 'ar'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minHeight: 0,
                        minWidth: 0,
                      ),
                      icon: const Icon(Icons.remove, size: 14),
                      onPressed: () {
                        if (quantity > 1) {
                          setState(() {
                            quantity--;
                          });
                        }
                      },
                    ),
                    Text(
                      quantity.toString(),
                      style: const TextStyle(fontSize: 14),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minHeight: 0,
                        minWidth: 0,
                      ),
                      icon: const Icon(Icons.add, size: 14),
                      onPressed: () {
                        setState(() {
                          quantity++;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2.5,
                child: ElevatedButton(
                  onPressed: _addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    padding: const EdgeInsets.symmetric(vertical: 0.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.addToBag,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildImageSlider() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 250.0,
        autoPlay: true,
        enableInfiniteScroll: true,
        autoPlayCurve: Curves.easeInOutCubic,
        enlargeCenterPage: true,
      ),
      items: product!.images.map((image) {
        return Builder(
          builder: (BuildContext context) {
            return CachedNetworkImage(
              imageUrl: image,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  const Center(child: FadeInOutImage(height: 250)),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            );
          },
        );
      }).toList(),
    );
  }

  Widget buildSkeletonSlider() {
    return Skeletonizer(
      enabled: true, // To show skeleton effect
      child: CarouselSlider(
        options: CarouselOptions(
          height: 250.0,
          autoPlay: true,
          enableInfiniteScroll: true,
          autoPlayCurve: Curves.easeInOutCubic,
          enlargeCenterPage: true,
        ),
        items: fakeImages.map((image) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                height: 250,
                color: Colors.grey.shade300, // Placeholder skeleton color
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
