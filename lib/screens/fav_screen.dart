import 'package:Gomla/screens/product_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../contstants.dart';
import '../models/cart.dart';
import '../models/fav.dart';
import '../models/fav_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/product.dart';
import '../widgets/app_bar.dart';

class FavScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fav = Provider.of<Fav>(context);
    print(fav.items);
    return Scaffold(
      appBar: CustomPagesAppBar(title: AppLocalizations.of(context)!.favorites,home: false,),
      body: fav.items.isEmpty
          ? Center(child: Text(AppLocalizations.of(context)!.yourFavoritesIsEmpty))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: fav.items.length,
                    itemBuilder: (context, index) {
                      final favItem = fav.items[index];
                      return FavItemWidget(favItem: favItem);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class FavItemWidget extends StatefulWidget {
  final Product favItem;
  int quantity = 1;
  FavItemWidget({required this.favItem});

  @override
  State<FavItemWidget> createState() => _FavItemWidgetState();
}

class _FavItemWidgetState extends State<FavItemWidget> {
  void _addToCart() {
    final cart = Provider.of<Cart>(context, listen: false);
    if (widget.favItem != null) {
      cart.addItem(widget.favItem, null);
      cart.updateQuantity(widget.favItem, widget.quantity);
      // show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.addedtoCart),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fav = Provider.of<Fav>(context, listen: false);

    return Card(
      color: Colors.white70.withOpacity(.8),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Image.network(
              widget.favItem.images.first,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProductScreen(productId: widget.favItem.id)));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.favItem.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('${widget.favItem.price} ', style: TextStyle(fontSize: 16)),
                        SvgPicture.asset(
                            "assets/SAR.svg",
                            width: 20,
                            height: 20
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _addToCart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              AppLocalizations.of(context)!.addToBag,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                fav.removeItem(widget.favItem);
              },
            ),
          ],
        ),
      ),
    );
  }
}
