import 'package:Gomla/shared/utils/app_values.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:html/parser.dart' show parse;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../contstants.dart';
import '../main.dart';
import '../models/cart.dart';
import '../models/fav.dart';
import '../models/product.dart';
import '../models/variation.dart';
import '../services/auth_service.dart';
import '../services/woocommerce_service.dart';
import '../shared/utils/app_assets.dart';
import '../widgets/app_bar.dart';
import '../widgets/fade_image.dart';
import '../widgets/image_viewer.dart';
import '../widgets/product_card.dart';
import '../widgets/product_screen_shimmer.dart';
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
    _loadLanguagePreference();
    // fetchVariations();
    wooCommerceService
        .fetchFrequentlyBoughtTogether(widget.productId)
        .then((items) {
      setState(() {
        frequentlyBoughtTogether = items;
        isFrequentlyBoughtTogetherLoading = false;
      });
    });
    _checkLoginStatus();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _toggleFavorite() {
    final fav = Provider.of<Fav>(context, listen: false);
    setState(() {
      if (fav.isFavorite(product!)) {
        fav.removeItem(product!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.removedFromFavorites),
          ),
        );
      } else {
        fav.addItem(product!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.addedToFavorites),
          ),
        );
      }
    });
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

/*  void fetchVariations() async {
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
  }*/

  void _addGroupToCart() {
    final cart = Provider.of<Cart>(context, listen: false);
    for (var item in frequentlyBoughtTogether) {
      cart.addItem(item, null); // Assuming no variations for simplicity
      cart.updateQuantity(item, 1);
    }
    // add current product to cart
    cart.addItem(product!, selectedVariation);
    cart.updateQuantity(product!, quantity);
    /*ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.addToBag),
      ),
    );*/
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
          builder: (context) => MainScreen(), // Return to the MainScreen
        ),
      );
    });
  }

  String languageCode = 'en'; // Default language

  Future<void> _loadLanguagePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      languageCode =
          prefs.getString('language_code') ?? 'en'; // Default to English
    });
  }

  bool isExpanded = false;

  Widget _buildExpandableText(String text) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(
            text: text,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
            ) // Use any text style you like
            );

        final tp = TextPainter(
          text: span,
          maxLines: isExpanded ? null : 4, // Show 4 lines initially
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        );

        tp.layout(maxWidth: constraints.maxWidth);

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                  maxLines: isExpanded ? null : 4,
                  overflow:
                      isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),

                // Show "See More/Less" only if the text overflows
                TextButton(

                  style:  TextButton.styleFrom(
                    maximumSize:  Size(400, 50),
                    backgroundColor: Colors.white,
                    side:   BorderSide(color:  mainColor),
                    minimumSize:  Size(400, 50),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded; // Toggle expanded/collapsed state
                    });
                  },
                  child: Text(isExpanded ? AppLocalizations.of(context)!.showMore : AppLocalizations.of(context)!.showLess,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                      )),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fav = Provider.of<Fav>(context);

    late double discount = product!.regularPrice > 0
        ? (product!.regularPrice - product!.price) / product!.regularPrice * 100
        : 0;

    Widget _getIcon(String assetPath, bool isSelected) {
      return ColorFiltered(
        colorFilter: ColorFilter.mode(
          isSelected ? mainColor : Colors.black, // Change color if selected
          BlendMode.srcIn,
        ),
        child: SvgPicture.asset(
          assetPath,
          height: 24.0, // You can adjust the size as needed
          width: 24.0, // You can adjust the size as needed
        ),
      );
    }

    return Scaffold(
      bottomNavigationBar: Consumer<Cart>(
        builder: (context, cart, child) {
          return BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: _getIcon(ImageAssets.home, _selectedIndex == 0),
                label: AppLocalizations.of(context)!.home,
              ),
              BottomNavigationBarItem(
                icon: _getIcon(ImageAssets.category, _selectedIndex == 1),
                label: AppLocalizations.of(context)!.categories,
              ),
              BottomNavigationBarItem(
                icon: _getIcon(ImageAssets.sale, _selectedIndex == 2),
                label: AppLocalizations.of(context)!.brands,
              ),
              BottomNavigationBarItem(
                icon: _getIcon(ImageAssets.account, _selectedIndex == 3),
                label: AppLocalizations.of(context)!.profile,
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: _getIcon(ImageAssets.cart, _selectedIndex == 4),
                    ),
                    if (cart.items.length > 0) // Show badge only if cart has items
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            cart.items.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                label: AppLocalizations.of(context)!.cart,
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: mainColor,
            unselectedItemColor: Colors.black,
            unselectedLabelStyle: TextStyle(color: Colors.black),
            showUnselectedLabels: true,
            onTap: _onItemTapped,
            selectedLabelStyle: TextStyle(fontSize: 12),
            unselectedFontSize: 10,
            backgroundColor: Colors.white,
            landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
            type: BottomNavigationBarType.fixed,
          );
        },
      ),
      appBar: const CustomAppBar(title: '',home: false,),
      body: isLoading
          ?

      ShimmerLoadingPage()
          :
      CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  fillOverscroll: true,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            product!.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color.fromARGB(255, 66, 66, 66),
                            ),
                            //textAlign: TextAlign.center,
                          ),
                        ),
                        buildImageSlider(fav),

                        const SizedBox(height: 16),
                        buildCarouselIndicators(),
                        Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [

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
                                                ? Color(int.parse(
                                                    '0xff${color.substring(1)}'))
                                                : null,
                                            backgroundColor: hasColor
                                                ? Color(int.parse(
                                                    '0xff${color.substring(1)}'))
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
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [

                                        Text(
                                          '${price} ${AppLocalizations.of(context)!.egp} ',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      SizedBox(width: 5),
                                  price == product!.regularPrice.toString()? const Text(''):
                                      Text(
                                        '${product!.regularPrice} ${AppLocalizations.of(context)!.egp} ',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      if (discount != 0)
                                        Text(
                                          '-${discount.toStringAsFixed(0)} %',
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontSize: 16,
                                          ),
                                        ),
                                    ],
                                  ),
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
                                  ],
                                  indicatorColor: Colors
                                      .transparent, // Remove the default indicator
                                  labelColor: mainColor,
                                  unselectedLabelColor: Colors.black,
                                  indicatorSize: TabBarIndicatorSize.label,
                                ),
                              ),
                              SizedBox(
                                height: isExpanded
                                    ? mediaQueryHeight(context) * .5
                                    : 200,
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: Colors.white,
                                        border: Border.all(
                                          color: borderColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: _buildExpandableText(
                                          _stripHtmlTags(
                                              product!.short_description)),
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
                                      child: _buildExpandableText(
                                          _stripHtmlTags(product!.description)),
                                    ),
                                  ],
                                ),
                              ),

      /*   const Text(
                                "مراجعة العملاء",
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
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
                              ),*/
                              if (!isFrequentlyBoughtTogetherLoading &&
                                  frequentlyBoughtTogether.isNotEmpty)
                                Column(
                                  crossAxisAlignment:   CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        AppLocalizations.of(context)!.alwaysSoldWith,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight:
                                            FontWeight.bold),
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
                                                2,
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
                                                                      index],
                                                              fakeProduct: "",
                                                            )
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
                                      decoration:   BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: _addGroupToCart,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: mainColor,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 0.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                        ),
                                        child: Text(
                                          '${AppLocalizations.of(context)!.buyTogether}',
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
                                            color: mainColor, width: 1),
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
                          thickness: .5,
                        ),
                        if (!isRelatedLoading && relatedProducts.isNotEmpty)
                          Column(
                            crossAxisAlignment:   CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 0.0, 8.0, 0.0),
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .relatedProducts,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: SizedBox(
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
                                                            index],
                                                    fakeProduct: "",
                                                  )
                                                : Image.asset(
                                                    'assets/grey_image.jpeg'),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
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
      bottomSheet:isLoading
          ? SizedBox(): BottomAppBar(
        elevation: 0,
        color: Colors.white,
        child: Row(
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
                textDirection: languageCode == 'ar'
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
            SizedBox(width: 5),
            SizedBox(
              width: MediaQuery.of(context).size.width*.6,
              child: ElevatedButton(
                onPressed: _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
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
    );
  }

  Widget buildImageSlider(fav) {
    return SizedBox(
      height: MediaQuery.of(context).size.height *
          0.30, // Adjust height to 30% of screen
      child: CarouselSlider.builder(
        controller: _carouselController, // Add the controller
        itemCount: product!.images.length, // Number of images in the product
        itemBuilder: (BuildContext context, int index, realIndex) {
          return Stack(
            children: [
              Container(
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: product!.images[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => const Center(child: FadeInOutImage(height: 250)),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to the image viewer screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageViewerScreen(
                        images: product!.images,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
              ),

              Positioned(
                top: mediaQueryHeight(context) * 0.01,
                left: 10,
                child: Container(
                  decoration:   BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  width: 35.0,
                  height: 35.0,
                  child: IconButton(
                    onPressed: _toggleFavorite,
                    icon: Icon(
                      fav.isFavorite(product!)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.black,
                      size: 15,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: mediaQueryHeight(context) * 0.09,
                left: 10,
                child: Container(
                  decoration:   BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  width: 35.0,
                  height: 35.0,
                  child: IconButton(
                    onPressed: (){},
                    icon: Icon(
                       Icons.share,
                      color: Colors.black,
                      size: 15,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        options: CarouselOptions(
          height: MediaQuery.of(context).size.height * 0.30,
          // Adjust height to 30% of screen
          viewportFraction: 1.0,
          initialPage: _currentImageIndex,
          // To set the starting image
          onPageChanged: (index, reason) {
            setState(() {
              _currentImageIndex = index; // Update the current image index
            });
          },
          autoPlay: true,
          enableInfiniteScroll: true,
        ),
      ),
    );
  }

  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentImageIndex = 0;

// Carousel Indicators
  Widget buildCarouselIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(product!.images.length, (index) {
        return Container(
          width: _currentImageIndex == index ? 12 : 8,
          height: _currentImageIndex == index ? 12 : 8,
          margin: EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentImageIndex == index
                ? Colors.grey // Selected indicator (all grey)
                : Colors.white, // Unselected indicators (white circle)
            border: Border.all(
              color: _currentImageIndex == index
                  ? Colors.transparent // No border for selected
                  : Colors.grey, // Grey border for unselected
              width: 1,
            ),
          ),
        );
      }),
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




