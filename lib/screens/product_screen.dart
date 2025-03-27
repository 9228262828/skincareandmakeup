import 'package:Gomla/app_locale.dart';
import 'package:Gomla/shared/components/toast_component.dart';
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

import '../Engin/models.dart';
import '../contstants.dart';
import '../main.dart';
import '../models/cart.dart';
import '../models/fav.dart';
import '../models/product.dart';
import '../models/variation.dart';
import '../services/auth_service.dart';
import '../services/woocommerce_service.dart';
import '../shared/global/app_theme.dart';
import '../shared/utils/app_assets.dart';
import '../widgets/app_bar.dart';
import '../widgets/band_and_category.dart';
import '../widgets/fade_image.dart';
import '../widgets/image_viewer.dart';
import '../widgets/product_card.dart';
import '../widgets/product_review_widget.dart';
import '../widgets/product_screen_shimmer.dart';
import 'login_screen.dart';
import 'main_screen.dart';

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
  final _reviewUserNameController = TextEditingController();
  final _reviewRateController = TextEditingController();
  late TabController _tabController;
  int quantity = 1;
  List<Product> frequentlyBoughtTogether = [];
  bool isFrequentlyBoughtTogetherLoading = true;

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
        _isLoggedIn = true;
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
        userName: _reviewUserNameController.text,
        userEmail: userInfo['email'],
        rating: _reviewRateController.text,
      );

      if (response.statusCode == 201) {
        showToast(
            text: AppLocalizations.of(context)!.reviewSubmittedMessage,
            state: ToastStates.SUCCESS);
        _reviewController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToSubmitReview)));
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
                  style: TextButton.styleFrom(
                    maximumSize: Size(400, 50),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: mainColor),
                    minimumSize: Size(400, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      isExpanded =
                          !isExpanded; // Toggle expanded/collapsed state
                    });
                  },
                  child: Text(
                      isExpanded
                          ? AppLocalizations.of(context)!.showMore
                          : AppLocalizations.of(context)!.showLess,
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
      backgroundColor: Colors.grey.shade200,
      appBar: const CustomPagesAppBar(
        title: '',
        home: false,
      ),
      body: isLoading
          ? ShimmerLoadingPage()
          : CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  fillOverscroll: true,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product image
                        SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            product!.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF000000),
                            ),
                            //textAlign: TextAlign.center,
                          ),
                        ),
                        buildImageSlider(fav),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Container(
                            color: Colors.white,
                            width: MediaQuery.of(context).size.width,
                            height: 6,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${price}',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF212224),
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Column(children: [
                                        SizedBox(
                                          height: 2,
                                        ),
                                        SvgPicture.asset("assets/SAR.svg",
                                            width: 22, height: 22),
                                      ]),
                                      SizedBox(width: 5),
                                      price == product!.regularPrice.toString()
                                          ? const Text('')
                                          : Column(children: [
                                              SizedBox(
                                                height: 4,
                                              ),
                                              Text(
                                                '${product!.regularPrice} ',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  decorationColor: Colors.grey,
                                                ),
                                              ),
                                            ]),
                                      SizedBox(width: 5),
                                      if (discount != 0)
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 2.0, vertical: 1.0),
                                            child: Row(
                                              children: [
                                                Text(
                                                  '${AppLocalizations.of(context)!.off}',
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  ' ${discount.toStringAsFixed(0)} %',
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Padding(
                                      padding: const EdgeInsets.all(0.0),
                                      child: Text(
                                          _stripHtmlTags(
                                            product!.short_description,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            height: 1.4,
                                          ))),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ProductDetailWidget(
                          product: product!,
                        ),

                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Container(
                            width: mediaQueryWidth(context) * 0.95,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment
                                    .start, // Align text to the left
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      AppLocalizations.of(context)!.description,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Flexible(
                                      // Use Flexible instead of Expanded
                                      child: Text(
                                        _stripHtmlTags(product!.description),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (product!.howToUse.isNotEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                              width: mediaQueryWidth(context) * 0.95,
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start, // Align text to the left
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .how_to_use,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Flexible(
                                        // Use Flexible instead of Expanded
                                        child: Text(
                                          _stripHtmlTags(product!.howToUse),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        if (product!.hazardsCautions.isNotEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                              width: mediaQueryWidth(context) * 0.95,
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start, // Align text to the left
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .hazards_cautions,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Flexible(
                                        // Use Flexible instead of Expanded
                                        child: Text(
                                          _stripHtmlTags(
                                              product!.hazardsCautions),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        SizedBox(
                          height: mediaQueryHeight(context) * 0.01,
                        ),
                        ReviewWidget(productId: widget.productId),

                        // const SizedBox(height: 64),
                        const Divider(
                          thickness: .5,
                        ),
                        if (!isRelatedLoading && relatedProducts.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 0.0, 8.0, 0.0),
                                child: Text(
                                  AppLocalizations.of(context)!.relatedProducts,
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
                                      MediaQuery.of(context).size.height * 0.5,
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
                                            padding: const EdgeInsets.all(4.0),
                                            child: relatedProducts[index]
                                                        .imageUrl !=
                                                    null
                                                ? ProductCard(
                                                    product:
                                                        relatedProducts[index],
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
      bottomSheet: isLoading
          ? SizedBox()
          : BottomAppBar(
              elevation: 0,
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                    height: 30.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
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
                    width: MediaQuery.of(context).size.width * .6,
                    child: ElevatedButton(
                      onPressed: _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        padding: const EdgeInsets.symmetric(vertical: 0.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.0),
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
                    if (cart.items.length >
                        0) // Show badge only if cart has items
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(3),
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
    );
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MainScreen(
                    index: index,
                  )));
      _selectedIndex = index;
    });
  }

  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentImageIndex = 0;

  Widget buildImageSlider(fav) {
    bool isSingleImage =
        product!.images.length == 1; // Check if there's only one image

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        height: MediaQuery.of(context).size.height *
            0.30, // Adjust height to 30% of screen

        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Stack(
          children: [
            isSingleImage
                // If there's only one image, just show a single Image widget
                ? Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to the image viewer screen (optional, for image details)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageViewerScreen(
                              images: product!.images,
                              initialIndex: 0, // Show the first image
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: CachedNetworkImage(
                          imageUrl: product!.images[0],
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.30,
                          placeholder: (context, url) =>
                              const Center(child: FadeInOutImage(height: 250)),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: CarouselSlider.builder(
                      controller: _carouselController, // Add the controller
                      itemCount: product!
                          .images.length, // Number of images in the product
                      itemBuilder:
                          (BuildContext context, int index, realIndex) {
                        return GestureDetector(
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
                          child: Container(
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: CachedNetworkImage(
                                imageUrl: product!.images[index],
                                fit: BoxFit.contain,
                                width: double.infinity,
                                placeholder: (context, url) => const Center(
                                    child: FadeInOutImage(height: 250)),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          ),
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
                            _currentImageIndex =
                                index; // Update the current image index
                          });
                        },
                        autoPlay: true,
                        enableInfiniteScroll: true,
                      ),
                    ),
                  ),
            // Favorite Button
            Positioned(
              top: mediaQueryHeight(context) * 0.01,
              left: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(3.0),
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
            // Share Button
            Positioned(
              top: mediaQueryHeight(context) * 0.065,
              left: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(3.0),
                ),
                width: 35.0,
                height: 35.0,
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.share,
                    color: Colors.black,
                    size: 15,
                  ),
                ),
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: buildCarouselIndicators(),
                )),
          ],
        ),
      ),
    );
  }

// Carousel Indicators
  Widget buildCarouselIndicators() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16.0), // Horizontal padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          product!.images.length,
          (index) {
            bool isSelected = _currentImageIndex == index;

            return Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.circle // Solid circle icon for selected
                      : Icons
                          .radio_button_unchecked, // Empty circle (hollow) for unselected
                  color: isSelected
                      ? Colors.black
                      : Colors.grey, // Color for the icon
                  size: 7,
                ),
                // Add space between icons
                SizedBox(
                    width:
                        4), // You can adjust the width here to control the space
              ],
            );
          },
        ),
      ),
    );
  }

  void _openReviewModalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isLoggedIn) ...[
                  TextField(
                    controller: _reviewController,
                    decoration: customInputDecoration(
                      context,
                      AppLocalizations.of(context)!.writeReview,
                      AppLocalizations.of(context)!.writeReview,
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _reviewUserNameController,
                    decoration: customInputDecoration(
                      context,
                      AppLocalizations.of(context)!.userName,
                      AppLocalizations.of(context)!.userName,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _reviewRateController,
                    decoration: customInputDecoration(
                      context,
                      AppLocalizations.of(context)!.rating,
                      AppLocalizations.of(context)!.rating,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      // Validate the rating as the user types
                      if (value.isNotEmpty) {
                        double rating = double.tryParse(value) ?? 0;
                        if (rating > 5) {
                          showToast(
                              text: AppLocalizations.of(context)!
                                  .ratingShouldBeFiveOrLess,
                              state: ToastStates.ERROR);
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                    ),
                    onPressed: () {
                      // Validate the rating before submitting
                      double rating =
                          double.tryParse(_reviewRateController.text) ?? 0;
                      if (rating > 5) {
                        showToast(
                            text: AppLocalizations.of(context)!
                                .ratingShouldBeFiveOrLess,
                            state: ToastStates.ERROR);
                      } else {
                        // Proceed with submitting the review
                        _submitReview();
                      }
                    },
                    child: Text(AppLocalizations.of(context)!.submitReview),
                  ),
                ] else ...[
                  Text(AppLocalizations.of(context)!.pleaseLoginToReview),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Text(AppLocalizations.of(context)!.login),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
