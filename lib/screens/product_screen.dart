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
  late String regularPrice = '';
  bool isLoggedIn = false;
  final _reviewController = TextEditingController();
  final _reviewUserNameController = TextEditingController();
  final _reviewRateController = TextEditingController();
   int quantity = 1;
  List<Product> frequentlyBoughtTogether = [];
  bool isFrequentlyBoughtTogetherLoading = true;

  @override
  void initState() {
    super.initState();
    wooCommerceService = WooCommerceService();
    fetchProductDetails();
    _loadLanguagePreference();


   }

  void _toggleFavorite() {
    final fav = Provider.of<Fav>(context, listen: false);
    setState(() {
      if (fav.isFavorite(product!)) {
        fav.removeItem(product!);
       showToast(text:  AppLocalizations.of(context)!.removedFromFavorites, state: ToastStates.SUCCESS);
      } else {
        fav.addItem(product!);
        showToast(text:  AppLocalizations.of(context)!.addedToFavorites, state: ToastStates.SUCCESS);
      }
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

  void _addToCart() async {
    final cart = Provider.of<Cart>(context, listen: false);
    if (product != null) {
      cart.addItem(product!);
      cart.updateQuantity(product!, quantity);
      await cart.saveCartToSharedPreferences();
      Future.delayed(const Duration(seconds: 2), () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: mediaQueryWidth(context) * 0.95,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 50,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product!.name,
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(context)!.in_cart,
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(width: 1, color: Color(0xFF212224)),
                      maximumSize: Size(double.infinity, 50),
                      fixedSize: Size(double.infinity, 45),
                      minimumSize: Size(mediaQueryWidth(context) * .9, 40),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      AppLocalizations.of(context)!.show_another_product,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212224),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      maximumSize: Size(double.infinity, 50),
                      fixedSize: Size(double.infinity, 45),
                      minimumSize: Size(mediaQueryWidth(context) * .9, 40),
                      backgroundColor: Color(0xFF212224),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainScreen(index: 4),
                        ),
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context)!.goToCart,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      });
    }
  }



  Future<void> _submitReview() async {
    try {
      // Fetch user info
      final userInfo = await AuthService.fetchUserInfo();
      print(userInfo);

      // Access the email correctly
      String userEmail = userInfo['data']['email'] ?? ''; // Safe fallback if email is not found
print(userEmail);
      // Make sure the rating is an integer
      int rating = (double.tryParse(_reviewRateController.text) ?? 0).toInt();

      // Submit the review
      final response = await wooCommerceService.submitReview(
        productId: widget.productId,
        review: _reviewController.text,
        userName: _reviewUserNameController.text,
        userEmail: userEmail, // Pass the email
        rating: rating, // Pass the rating as an integer
      );

      if (response.statusCode == 201) {
        // Successfully submitted the review
        Navigator.pop(context);
        showToast(
          text: AppLocalizations.of(context)!.reviewSubmittedMessage,
          state: ToastStates.SUCCESS,
        );
        _reviewController.clear();
      } else {
        // Handle failure in submitting the review
        print('Failed to submit review: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.failedToSubmitReview),
        ));
      }
    } catch (e) {
      // Catch any exceptions and show a snack bar
      print('Error submitting review: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to submit review: $e'),
      ));
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
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

  @override
  Widget build(BuildContext context) {
print("stock_quantity");
print(product?.stock_quantity  );
    print("product?.brandId");
    print("product?.categoryId");
    print(product?.categoryId);
    print(product?.brandId);
    print(widget.productId);
    final fav = Provider.of<Fav>(context);
    late double discount = 0.0;

    if (product != null && product!.regularPrice > 0) {
      discount = (product!.regularPrice - product!.price) / product!.regularPrice * 100;
    } else {
      discount = 0;
    }

    if (product != null && product!.shipping_taxable == true) {
      double calculatedPrice = product!.price + (product!.price * 0.15);
      price = calculatedPrice.toStringAsFixed(2);

      double calculatedRegularPrice = product!.regularPrice + (product!.regularPrice * 0.15);
      regularPrice = calculatedRegularPrice.toStringAsFixed(2);
    }

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
    Locale currentLocale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: const CustomPagesAppBar(
        title: '',
        home: false,
      ),
      body: isLoading
          ? ShimmerLoadingPage()
          : RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  isLoading = true;
                });
                await fetchProductDetails();
                setState(() {
                  isLoading = false;
                });
              },
            child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        product!.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    price,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF212224),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Column(children: [
                                    const SizedBox(
                                      height: 7,
                                    ),
                                    SvgPicture.asset("assets/SAR.svg",
                                        color: Colors.black,
                                        width: 18, height: 18),
                                  ]),
                                  const SizedBox(width: 5),
                                  price == product!.regularPrice.toStringAsFixed(2)
                                      ? const Text('')
                                      : Column(children: [
                                          const SizedBox(
                                            height: 4.5,
                                          ),
                                          Text(
                                            regularPrice,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              decorationColor: Colors.grey,
                                            ),
                                          ),
                                        ]),
                                  SizedBox(width: 8),
                                  if (discount != 0)
                                    Column(
                                      children: [
                                        SizedBox(
                                          height: 2,
                                        ),
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
                                               currentLocale.languageCode == 'en'? '${discount.toStringAsFixed(2)} % ${AppLocalizations.of(context)!.off}':   '${AppLocalizations.of(context)!.off} ${discount.toStringAsFixed(2)} %',
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
                                  const Spacer(),
                                  product?.shipping_taxable== true?
                                  Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child:Column(
                                      children: [
                                        SizedBox(height: 3),
                                        Text( '${AppLocalizations.of(context)!.fullTax}',),
                                      ],
                                    ) ,):const Text(''),
                                ],
                              ),
                              SizedBox(height: 18),
                              Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: Text(
                                      _stripHtmlTags(
                                        product!.short_description,
                                      ),
                                      softWrap: true,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        height: 1.4,
                                      ))),
                              product?.stock_status == "outofstock" ?     Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.outOfStock,
                                      textAlign:  TextAlign.center,
                                      style:   TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: mainColor,
                                      ),
                                      //textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ) : Container(),
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
                                  softWrap: true,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  _stripHtmlTags(product!.description),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                  softWrap: true,  // This ensures the text wraps within the container

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
                                    AppLocalizations.of(context)!.how_to_use,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    _stripHtmlTags(product!.howToUse),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                    softWrap: true,
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
                                  child: Text(
                                    _stripHtmlTags(product!.hazardsCautions),
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
                          ),
                        ),
                      ),
                    ReviewWidget(productId: widget.productId),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor:  Colors.black,
                            backgroundColor: Colors.transparent,
                            minimumSize: Size(mediaQueryWidth(context) * .6, 50),
                            maximumSize: Size(mediaQueryWidth(context) * .6, 50),
                          ),
                          onPressed: () {
                            _openReviewModalSheet(context);
                          },
                          child: Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.review_the_product,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                                SizedBox(
                                  width:  MediaQuery.of(context).size.width * 0.05,
                                ),
                              Icon(Icons.arrow_forward_ios, color: Colors.black,size: 20,),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    if (!isRelatedLoading && relatedProducts.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                            child: Text(
                              AppLocalizations.of(context)!.relatedProducts,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.41,
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
                                              productId: relatedProducts[index]
                                                  .id), // Example product ID
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: relatedProducts[index].imageUrl !=
                                                null
                                            ? ProductCard(
                                                product: relatedProducts[index],
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
                    product?.stock_status != "outofstock" ?    const SizedBox(height: 84) : const SizedBox(height: 16),
                  ],
                ),
              ),
          ),
      bottomSheet: isLoading
          ? SizedBox()
          :
      product?.stock_status == "outofstock" ?  BottomAppBar(
        notchMargin: 0,
        padding: const EdgeInsets.all(10),
        elevation: 0,
        height: 0,
        color: Colors.white,
        child: Container()
      ) :
      BottomAppBar(
        notchMargin: 0,
        padding: const EdgeInsets.all(10),
        elevation: 0,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 40.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.0),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                textDirection: languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minHeight: 0, minWidth: 0),
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
                    constraints: const BoxConstraints(minHeight: 0, minWidth: 0),
                    icon: const Icon(Icons.add, size: 14),
                    onPressed: () {
                      if (quantity < product!.stock_quantity) { // <-- check if less than stock
                        setState(() {
                          quantity++;
                        });
                      } else {
                         showToast(text: AppLocalizations.of(context)!.there_is_no_more_is_stock , state: ToastStates.WARNING );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
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
                icon: _getIcon(ImageAssets.sale, _selectedIndex == 2),
                label: AppLocalizations.of(context)!.brands,
              ),
              BottomNavigationBarItem(
                icon: _getIcon(ImageAssets.category, _selectedIndex == 2),
                label: AppLocalizations.of(context)!.categories,
              ),
              BottomNavigationBarItem(
                icon: _getIcon(ImageAssets.account, _selectedIndex== 3),
                label: AppLocalizations.of(context)!.profile,
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: _getIcon(ImageAssets.cart, _selectedIndex== 4),
                    ),
                    if (cart.items.length > 0) // Show badge only if cart has items
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
    print(product!.images.length);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        height: MediaQuery.of(context).size.height *
            0.30, // Adjust height to 30% of screen
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Stack(
          children: [
            if (product!.images.length == 0)
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: Image.asset(
                      'assets/placeholder.png',
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.30,
                    )),
              ),
            isSingleImage
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
                          imageUrl: _isValidUrl(product!.images[0])
                              ? product!.images[0]
                              : 'assets/placeholder.png', // Fallback to placeholder if URL is invalid
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
                      itemCount: product!.images.length,

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
                                imageUrl: _isValidUrl(product!.images[index])
                                    ? product!.images[index]
                                    : 'assets/placeholder.png', // Fallback to placeholder if URL is invalid
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
                        viewportFraction: 1.0,
                        initialPage: _currentImageIndex,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentImageIndex = index;
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

   bool _isValidUrl(String url) {
    Uri? uri = Uri.tryParse(url);
    return uri != null && uri.isAbsolute;
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
  Future<bool> _hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _openReviewModalSheet(BuildContext context) async {
    final isLoggedIn = await _hasToken(); // Check login dynamically

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
            ),
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey, // Set the form key for validation
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoggedIn) ...[
                    TextFormField(
                      controller: _reviewController,
                      decoration: customInputDecoration(
                        context,
                        AppLocalizations.of(context)!.writeReview,
                        AppLocalizations.of(context)!.writeReview,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.reviewRequired;
                        }
                        return null; // No error
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _reviewUserNameController,
                      decoration: customInputDecoration(
                        context,
                        AppLocalizations.of(context)!.userName,
                        AppLocalizations.of(context)!.userName,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.userNameRequired;
                        }
                        return null; // No error
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _reviewRateController,
                      decoration: customInputDecoration(
                        context,
                        AppLocalizations.of(context)!.rating,
                        AppLocalizations.of(context)!.rating,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.ratingRequired;
                        }
                        double rating = double.tryParse(value) ?? 0;
                        if (rating > 5) {
                          return AppLocalizations.of(context)!.ratingShouldBeFiveOrLess;
                        }
                        return null; // No error
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF212224),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.0),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _submitReview(); // Submit the review if valid
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.submitReview),
                    ),
                  ] else ...[
                    Text(AppLocalizations.of(context)!.pleaseLoginToReview),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF212224),
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
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
