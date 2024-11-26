import 'package:flutter/material.dart';
import 'package:skincare/contstants.dart';
import 'package:skincare/screens/checkout_screen.dart';
import 'package:skincare/screens/login_screen.dart';
import 'package:skincare/services/auth_service.dart';
import 'package:skincare/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart.dart';
import '../models/cart_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context)!.cart),
      body: cart.items.isEmpty
          ? Center(child: Text(AppLocalizations.of(context)!.yourCartIsEmpty))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = cart.items[index];
                      return CartItemWidget(cartItem: cartItem);
                    },
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
                      Text(
                        '${cart.totalAmount.toStringAsFixed(2)} ${AppLocalizations.of(context)!.egp}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_isLoggedIn == false) {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutScreen()));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.checkout, style: const TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ),
              ],
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
      elevation: 0,
      color: Colors.transparent,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
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
                    borderRadius: BorderRadius.circular(8.0),
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
                      Text(cartItem.product.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Text('${cartItem.variation?.price ?? cartItem.product.price} ${AppLocalizations.of(context)!.egp}', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      // if variation attributes has color return container
                      (cartItem.variation?.attributes[0].color != null)
                          ? Container(
                              margin: const EdgeInsets.only(top: 4.0),
                              width: 20,
                              height: 20,
                              color: Color(int.parse('0xff${cartItem.variation!.attributes[0].color!.substring(1)}')),
                            )
                          : (cartItem.variation != null)
                              ? Text('${cartItem.variation?.attributes[0].name}', style: const TextStyle(fontSize: 16))
                              : Container(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
            color: Colors.grey[200],
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.remove,
                        size: 14,
                      ),
                      onPressed: () {
                        if (cartItem.quantity > 1) {
                          cart.updateQuantity(cartItem.product, cartItem.quantity - 1);
                        } else {
                          cart.removeItem(cartItem.product);
                        }
                      },
                    ),
                    Text(cartItem.quantity.toString(), style: const TextStyle(fontSize: 14)),
                    IconButton(
                      icon: const Icon(
                        Icons.add,
                        size: 14,
                      ),
                      onPressed: () {
                        cart.updateQuantity(cartItem.product, cartItem.quantity + 1);
                      },
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: 16,
                  ),
                  onPressed: () {
                    cart.removeItem(cartItem.product);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
