import 'package:Gomla/services/woocommerce_service.dart';
import 'package:Gomla/shared/components/toast_component.dart';
import 'package:Gomla/shared/utils/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../contstants.dart';
import '../models/cart.dart';
import '../models/cart_item.dart';
import '../services/auth_service.dart';
import '../shared/global/app_theme.dart';
import '../test.dart';
import '../widgets/app_bar.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../services/woocommerce_service.dart'; // WooCommerce service import
import '../models/cart.dart'; // Cart model import
import '../models/cart_item.dart'; // CartItem model import
import '../shared/global/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/woocommerce_service.dart'; // WooCommerce service import
import '../models/cart.dart'; // Cart model import
import '../models/cart_item.dart'; // CartItem model import
import '../shared/global/app_theme.dart';
import '../widgets/app_bar.dart';
import 'checkout_screen.dart'; // Import the CheckoutScreen

class CartScreen extends StatefulWidget {
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoggedIn = false;
  double discountAmount = 0.0; // Store the discount amount
  String discountType = ''; // Store discount type (percent or fixed)

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('auth_token');
    setState(() {
      if (authToken != null) {
        _isLoggedIn = true;
      }
    });
  }

  WooCommerceService wooCommerceService = WooCommerceService();

  final TextEditingController _discountCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    Future.delayed(Duration.zero, () async {
      await _loadCart();
      setState(() {

      }); // 🔥 after loading, rebuild the screen
    });
  }

  Future<void> _loadCart() async {
    final cart = Provider.of<Cart>(context, listen: false);
    await cart.loadCartFromSharedPreferences();
  }


  // Apply the coupon to the cart and update total
  void _applyCoupon(String couponCode) {
    wooCommerceService.validateCoupon(couponCode, context).then((discountData) {
      if (discountData != null) {
        setState(() {
          discountAmount = discountData[0]; // Get the discount amount
          discountType = discountData[1]; // Get the discount type (percent or fixed)
        });
        // Show success message for applying the coupon
        showToast(text: AppLocalizations.of(context)!.couponAppliedSuccessfully, state: ToastStates.SUCCESS);
      } else {
        showToast(text: AppLocalizations.of(context)!.invalidCoupon, state: ToastStates.ERROR);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    // Apply discount to total
    double total = cart.totalAmount;
    if (discountType == 'percent') {
      // Apply percent discount
      total = total - (total * (discountAmount / 100));
    } else {
      // Apply fixed discount
      total = total - discountAmount;
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: "",
        home: true,
      ),
      backgroundColor: Colors.grey.shade200,
      body: cart.items.isEmpty
          ? Center(child: Text(AppLocalizations.of(context)!.yourCartIsEmpty))
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${AppLocalizations.of(context)!.cart}: ${cart.items.length.toString()} ${AppLocalizations.of(context)!.product}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Expanded(
              child: ListView.builder(
                itemCount: cart.items.length + 1,
                itemBuilder: (context, index) {
                  if (index == cart.items.length) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            cursorColor: mainColor,
                            cursorWidth: 2.0,
                            cursorHeight: 24,
                            controller: _discountCodeController,
                            decoration: customInputDecoration(
                              suffixIcon: TextButton(
                                onPressed: () {
                                  _applyCoupon(_discountCodeController.text);
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.apply,
                                  style: TextStyle(color: mainColor),
                                ),
                              ),
                              context,
                              AppLocalizations.of(context)!.enterDiscountCode,
                              AppLocalizations.of(context)!.enterDiscountCode,
                            ),
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${AppLocalizations.of(context)!.total}:',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${total.toStringAsFixed(2)} ',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 4),
                                  SvgPicture.asset(
                                    "assets/SAR.svg",
                                    width: 16,
                                    height: 16,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  final cartItem = cart.items[index];
                  double price = cartItem.product.price;
                  double regularPrice = cartItem.product.regularPrice;

                  // Apply tax if shipping is taxable
                  if (cartItem.product.shipping_taxable == true) {
                    price += price * 0.15;
                    regularPrice += regularPrice * 0.15;
                  }

                  return CartItemWidget(
                    cartItem: cartItem,
                    price: price,
                    regularPrice: regularPrice,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: mediaQueryHeight(context) * .08,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_isLoggedIn) {
                        showToast(text: AppLocalizations.of(context)!.pleaseLogin, state: ToastStates.ERROR);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      } else {
                        // Navigate to the checkout screen and pass the updated total
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutScreen(updatedTotal: total),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${cart.items.length.toString()} ${AppLocalizations.of(context)!.product}",
                              style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w200),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${total.toStringAsFixed(2)} ',
                                  style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                SvgPicture.asset(
                                  "assets/SAR.svg",
                                  width: 16,
                                  height: 16,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          AppLocalizations.of(context)!.checkout,
                          style: const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(3.0),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(
                              Icons.arrow_forward,
                              color: mainColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  final double price;
  final double regularPrice;

  CartItemWidget({required this.cartItem, required this.price, required this.regularPrice});

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = Localizations.localeOf(context);

    final cart = Provider.of<Cart>(context, listen: false);
    BorderRadius borderRadius = currentLocale.languageCode == 'ar'
        ? BorderRadius.only(
      topRight: Radius.circular(8),
      bottomRight: Radius.circular(8),
    )
        : BorderRadius.only(
      topLeft: Radius.circular(8),
      bottomLeft: Radius.circular(8),
    );
    BorderRadius borderRadiusleft = currentLocale.languageCode == 'ar'
        ? BorderRadius.only(
      topLeft: Radius.circular(8),
      bottomLeft: Radius.circular(8),
    )
        : BorderRadius.only(
      topRight: Radius.circular(8),
      bottomRight: Radius.circular(8),

    );




    return Card(
      color: Colors.white,
      elevation: .01,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                    child: cartItem.product.images.isNotEmpty
                        ? Image.network(
                      cartItem.product.images.first,
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    )
                        : Image.asset(
                      'assets/placeholder.png', // Use a default placeholder image
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cartItem.product.name,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                                '${price.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            SvgPicture.asset(
                                "assets/SAR.svg",
                                width: 16,
                                height: 16,
                              color: Colors.black,
                            ),
                          Spacer(),
                          cartItem.product.shipping_taxable== true?
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
                        const SizedBox(height: 8),
                        // if variation attributes has color return container

                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: mediaQueryWidth(context) * .3,
                    height: 30, // Total height of the container
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Row(
                      children: [
                        // First Section: Add button with blue background
                        Container(
                          width: 30,
                          decoration: BoxDecoration(
                            border: const Border.fromBorderSide(
                              BorderSide(width: .5, color: Colors.grey),
                            ),
                            // Blue background for the first section
                            borderRadius: borderRadius,
                          ),
                          child: Center(
                            child: IconButton(
                              icon: const Icon(
                                Icons.remove,
                                color: Colors.grey,
                                size: 12,
                              ),
                              onPressed: () {
                                if (cartItem.quantity > 1) {
                                  cart.updateQuantity(
                                      cartItem.product, cartItem.quantity - 1);
                                } else {
                                  cart.removeItem(cartItem.product);
                                }
                              },
                            ),
                          ),
                        ),
                        Container(
                          width: 35,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              border: const Border.symmetric(
                                horizontal:
                                    BorderSide(width: .5, color: Colors.grey),
                              )),
                          child: Center(
                            child: Text(
                              cartItem.quantity.toString(),
                              // Display the current counter value
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        // Third Section: Minus button with grey background
                        Container(
                          width: 30,
                          decoration:   BoxDecoration(
                            border: Border.fromBorderSide(
                              BorderSide(width: .5, color: Colors.grey),
                            ),
                            // Blue background for the first section
                            borderRadius: borderRadiusleft, ),
                          child: Center(
                            child: IconButton(
                              icon: const Icon(
                                Icons.add,
                                color: Colors.grey,
                                size: 12,
                              ),
                              onPressed: () {
                                cart.updateQuantity(
                                    cartItem.product, cartItem.quantity + 1);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      cart.removeItem(cartItem.product);
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.0),
                        border: Border.all(color: Colors.grey, width: .5),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.black,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}