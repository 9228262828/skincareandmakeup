import 'package:Gomla/shared/utils/app_values.dart';
import 'package:Gomla/widgets/price%5E.dart';
import 'package:Gomla/widgets/product_review_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';

import '../contstants.dart';
import '../models/cart.dart';
import '../models/fav.dart';
import '../models/product.dart';
import '../models/variation.dart';
import '../screens/product_screen.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final String fakeProduct;

  const ProductCard({Key? key, required this.product, required this.fakeProduct}) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  List<Variation> variations = [];
  Variation? selectedVariation;
  String imageUrl = '';
  String price = '';

  @override
  void initState() {
    super.initState();
    imageUrl = widget.product.imageUrl;
    price = widget.product.price.toString();
    //fetchVariations();
  }

  int quantity = 1;
  void _toggleFavorite() {
    final fav = Provider.of<Fav>(context, listen: false);
    setState(() {
      if (fav.isFavorite(widget.product)) {
        fav.removeItem(widget.product);
       /* ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.removedFromFavorites),
          ),
        );*/
      } else {
        fav.addItem(widget.product);
       /* ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.addedToFavorites),
          ),
        );*/
      }
    });
  }

  String _stripHtmlTags(String htmlString) {
    final document = parse(htmlString);
    return parse(document.body!.text).documentElement!.text;
  }

  void _addToCart() {
    final cart = Provider.of<Cart>(context, listen: false);
    if (widget.product != null) {
      cart.addItem(widget.product, selectedVariation);
      cart.updateQuantity(widget.product, quantity);
      // show snackbar
    /*  ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.addedtoCart),
        ),
      );*/
    }
  }

  @override
  Widget build(BuildContext context) {
    double regularPrice =
        double.tryParse(widget.product.regularPrice.toString()) ?? 0;
    double discountedPrice =
        double.tryParse(widget.product.price.toString()) ?? 0;

// Calculate the percentage difference
    double percentage = ((regularPrice - discountedPrice) / regularPrice) * 100;

// Round the percentage to the nearest integer
    int roundedPercentage = percentage.round();

    final fav = Provider.of<Fav>(context);
    final cart = Provider.of<Cart>(context);
    return Container(
      decoration: BoxDecoration(
        // shadow

        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.all(4.0),
      height: MediaQuery.of(context).size.height * 0.16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.248,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                    //  fakeProduct == "fake"? SizedBox(height: 10):
                      FadeInImage(
                        image: (imageUrl.isNotEmpty &&
                                Uri.tryParse(imageUrl)?.hasAbsolutePath == true)
                            ? NetworkImage(imageUrl)
                            :AssetImage('assets/placeholder.png')
                                as ImageProvider,
                        placeholder: AssetImage('assets/grey_image.jpeg'),
                        height: MediaQuery.of(context).size.height * 0.195,
                        fit: BoxFit.fitHeight,
                        width: double.infinity,
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              Positioned(
                child: Container(
                  width: mediaQueryWidth(context) * 0.17,
                  height: mediaQueryWidth(context) * 0.1,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(0.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey,
                          spreadRadius: -2,
                          blurRadius: 5,
                          offset: Offset(0, 0))
                    ],
                  ),
                  child: Center(
                    child: Text(
                      roundedPercentage.toString() +
                          "%" +
                          " " +
                          AppLocalizations.of(context)!.off,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12),
                    ),
                  ),
                ),
                bottom: 0,
                right: 0,
              ),
               Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 30.0,
                  height: 30.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),

                  ),
                  child: IconButton(
                    onPressed: _toggleFavorite,
                    icon: Icon(
                      fav.isFavorite(widget.product)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.black,
                      size: 14,
                    ),
                  ),
                ),
              ),
             /* Positioned(
                bottom: -10,
                left: 5,
                child: Container(
                  width: 30.0,
                  height: 30.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey,
                          spreadRadius: -2,
                          blurRadius: 5,
                          offset: Offset(0, 0))
                    ],
                  ),
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: _addToCart,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    child: Icon(
                      Icons.add_shopping_cart,
                      color: cart.isAddedToCart(widget.product)
                          ? mainColor
                          : Colors.black,
                      size: 14.0,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Positioned(
                bottom: -10,
                right: 5,
                child: Container(
                  padding: EdgeInsets.all(0.0),
                  height: 30.0,
                  width: MediaQuery.of(context).size.width * 0.25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey,
                          spreadRadius: -2,
                          blurRadius: 5,
                          offset: Offset(0, 0))
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                            minHeight: 0,
                            minWidth: 0,
                          ),
                          icon:
                              Icon(Icons.remove, size: 12, color: Colors.black),
                          onPressed: () {
                            if (quantity > 1) {
                              setState(() {
                                quantity--;
                              });
                            }
                          },
                        ),
                      ),
                      Center(
                        child: Text(
                          quantity.toString(),
                          style: TextStyle(fontSize: 12, color: Colors.black),
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                            minHeight: 0,
                            minWidth: 0,
                          ),
                          icon: Icon(Icons.add, size: 12, color: Colors.black),
                          onPressed: () {
                            setState(() {
                              quantity++;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),*/
            ],
          ),

          Text(
            AppLocalizations.of(context)!.limitedOffer,
            maxLines: 1,
            textAlign: TextAlign.right,
            overflow: TextOverflow.visible,
            style: TextStyle(
                fontWeight: FontWeight.w500, fontSize: 16.0, color: Colors.red),
          ),
          PriceDisplay(
            price: widget.product.price,
          ),
          LastPriceDisplay(
            price: widget.product.regularPrice,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 6.0,
            ),
            child: Text(
              widget.product.name,
              maxLines: 2,
              textAlign: TextAlign.right,
              overflow: TextOverflow.visible,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0),
            ),
          ),
          if (variations.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: variations.map((variation) {
                  final attributeWithColor = variation.attributes.firstWhere(
                    (attr) => attr.color != null,
                    orElse: () => Attribute(
                        name: '', color: null, slug: '', taxonomy: ''),
                  );

                  final color = attributeWithColor.color;
                  final hasColor = color != null;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Container(
                      alignment: Alignment.center,
                      width: hasColor ? 25 : null,
                      height: 25,
                      padding: const EdgeInsets.all(0.0),
                      // decoration: selectedVariation == variation
                      //     ? BoxDecoration(
                      //         border: Border.all(color: mainColor, width: 1.0),
                      //         borderRadius: BorderRadius.circular(0.0),
                      //       )
                      //     : null,
                      child: ChoiceChip(
                        label: Container(
                          alignment: Alignment.center,
                          width: 40,
                          height: 25,
                          child: hasColor
                              ? Container()
                              : Text(
                                  variation.attributes
                                      .map((attr) => attr.name)
                                      .join(", "),
                                  style: TextStyle(
                                      color: selectedVariation == variation
                                          ? mainColor
                                          : Colors.black,
                                      fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                        selected: selectedVariation == variation,
                        selectedColor: hasColor
                            ? Color(int.parse('0xff' + color!.substring(1)))
                            : Colors.white,
                        backgroundColor: hasColor
                            ? Color(int.parse('0xff' + color!.substring(1)))
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        side: BorderSide(color: Colors.transparent, width: 0.0),
                        showCheckmark: false,
                        selectedShadowColor: mainColor,
                        pressElevation: 0.0,
                        onSelected: (bool selected) {
                          // setState(() {
                          //   selectedVariation = variation;
                          //   imageUrl = variation.imageUrl;
                          //   price = variation.price;
                          // });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductScreen(
                                productId: widget.product.id,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          // SizedBox(height: 8.0),
          // rating

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: buildRatingIcons(double.parse(widget.product.avrage_rating)), // Helper function to build star icons
          ),

          SizedBox(height: 8.0),
        ],
      ),
    );
  }
}

class ProductCardEmpty extends StatefulWidget {
  final Product product;
  final String fakeProduct;

  const ProductCardEmpty(
      {Key? key, required this.product, required this.fakeProduct})
      : super(key: key);

  @override
  State<ProductCardEmpty> createState() => _ProductCardEmptyState();
}

class _ProductCardEmptyState extends State<ProductCardEmpty> {
  List<Variation> variations = [];
  Variation? selectedVariation;
  String imageUrl = '';
  String price = '';

  @override
  void initState() {
    super.initState();
    imageUrl = widget.product.imageUrl;
    price = widget.product.price.toString();
    //fetchVariations();
  }

  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // shadow
        border: Border.all(color: Colors.grey, width: .1),

        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.all(4.0),
      height: MediaQuery.of(context).size.height * 0.1,
      child: Image(
        image: (imageUrl.isNotEmpty &&
                Uri.tryParse(imageUrl)?.hasAbsolutePath == true)
            ? NetworkImage(imageUrl)
            : AssetImage('assets/placeholder.png') as ImageProvider,
        errorBuilder: (context, error, stackTrace) =>
            Image.asset('assets/placeholder.png'),
        height: MediaQuery.of(context).size.height * 0.1,
        fit: BoxFit.cover,
        width: mediaQueryWidth(context) * 0.25,
      ),
    );
  }
}
