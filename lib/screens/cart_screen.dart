import 'package:Gomla/shared/utils/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../contstants.dart';
import '../models/cart.dart';
import '../models/cart_item.dart';
import '../services/auth_service.dart';
import '../shared/global/app_theme.dart';
import '../widgets/app_bar.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';

class CartScreen extends StatefulWidget {
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoggedIn = false;
  Future<void> _checkLoginStatus() async {
    await AuthService.isLoggedIn().then((value) {
      setState(() {
        _isLoggedIn = value;
      });
    });
  }

  final TextEditingController _discountCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _startSearch(BuildContext context) {
    showSearch(context: context, delegate: ProductSearchDelegate());
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Image.asset(
          'assets/app_icon.png',
          width: MediaQuery.of(context).size.width * 0.35,
        ),
        // centerTitle: true,
        actions: [
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.60,
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 0,
                        blurRadius: 7,
                        offset: Offset(0, 0), // changes position of shadow
                      ),
                    ]),
                child: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _startSearch(context);
                  },
                ),
              ),
            ),
            onTap: () {
              _startSearch(context);
            },
          ),
          // Stack(
          //   children: [
          //     Positioned(
          //       top: 0,
          //       right: 10,
          //       child: Text(
          //         cartCount.toString(),
          //         style: TextStyle(color: mainColor, fontSize: 14, fontWeight: FontWeight.bold),
          //       ),
          //     ),
          //     IconButton(
          //       icon: Icon(
          //         Icons.shopping_cart,
          //         color: Colors.black,
          //       ),
          //       onPressed: () {
          //         Navigator.push(
          //           context,
          //           MaterialPageRoute(builder: (context) => CartScreen()),
          //         );
          //       },
          //     ),
          //   ],
          // ),
        ],
      ),
      body: cart.items.isEmpty
          ? Center(child: Text(AppLocalizations.of(context)!.yourCartIsEmpty))
          : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                    crossAxisAlignment:   CrossAxisAlignment.start,
                children: [
                  Text(
                      "${AppLocalizations.of(context)!.cart}: ${cart.items.length.toString()} ${AppLocalizations.of(context)!.product}",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
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
                                  controller: _discountCodeController,
                                  decoration: customInputDecoration(
                                      suffixIcon: TextButton(
                                        onPressed: () {},
                                        child: Text(
                                            AppLocalizations.of(context)!.apply,style: TextStyle(
                                            color: mainColor
                                        ),),
                                      ),
                                      context,
                                      AppLocalizations.of(context)!
                                          .enterDiscountCode,
                                      AppLocalizations.of(context)!
                                          .enterDiscountCode),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${AppLocalizations.of(context)!.total}:',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${cart.totalAmount.toStringAsFixed(2)} ${AppLocalizations.of(context)!.egp}',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                        final cartItem = cart.items[index];
                        return CartItemWidget(cartItem: cartItem);
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
                            if (_isLoggedIn == false) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginScreen()));
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CheckoutScreen()));
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
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w200)),
                                  Text(
                                    '${cart.totalAmount.toStringAsFixed(2)} ${AppLocalizations.of(context)!.egp}',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Text(
                                AppLocalizations.of(context)!.checkout,
                                style: const TextStyle(
                                    fontSize: 17,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
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
                                      )))
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

  CartItemWidget({required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: false);

    return Card(
      color: lightColor,
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
                    child: Image.network(
                      cartItem.product.images.first,
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
                        Text(
                            '${cartItem.variation?.price ?? cartItem.product.price} ${AppLocalizations.of(context)!.egp}',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        // if variation attributes has color return container
                        (cartItem.variation?.attributes[0].color != null)
                            ? Container(
                                margin: const EdgeInsets.only(top: 4.0),
                                width: 20,
                                height: 20,
                                color: Color(int.parse(
                                    '0xff${cartItem.variation!.attributes[0].color!.substring(1)}')),
                              )
                            : (cartItem.variation != null)
                                ? Text(
                                    '${cartItem.variation?.attributes[0].name}',
                                    style: const TextStyle(fontSize: 16))
                                : Container(),
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
                          decoration: const BoxDecoration(
                            border: Border.fromBorderSide(
                              BorderSide(width: .5, color: Colors.grey),
                            ),
                            // Blue background for the first section
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(8)),
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
                          decoration: const BoxDecoration(
                            border: Border.fromBorderSide(
                              BorderSide(width: .5, color: Colors.grey),
                            ),
                            // Blue background for the first section
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8)),
                          ),
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
                          Icons.delete,
                          color: Colors.red,
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