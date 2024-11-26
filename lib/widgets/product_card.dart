import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:skincare/contstants.dart';
import 'package:skincare/models/cart.dart';
import 'package:skincare/models/fav.dart';
import 'package:skincare/models/variation.dart';
import 'package:skincare/providers/locale_provider.dart';
import 'package:skincare/screens/product_screen.dart';
import 'package:skincare/widgets/fade_image.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

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
    fetchVariations();
  }

  void fetchVariations() async {
    try {
      List<Variation> fetchedVariations =
          await fetchProductVariations(widget.product.id);
      setState(() {
        variations = fetchedVariations;
        selectedVariation = variations.first;
        imageUrl = selectedVariation!.imageUrl;
        price = selectedVariation!.price;
      });
    } catch (e) {
      print('Error fetching variations: $e');
    }
  }

  Future<List<Variation>> fetchProductVariations(int productId) async {
    try {
      final response = await http.get(Uri.parse(
          'https://mskra.com/wp-json/custom/v1/variations/$productId'));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((variation) => Variation.fromJson(variation))
            .toList();
      } else {
        throw Exception('Failed to load variations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load variations');
    }
  }

  int quantity = 1;
  void _toggleFavorite() {
    final fav = Provider.of<Fav>(context, listen: false);
    setState(() {
      if (fav.isFavorite(widget.product)) {
        fav.removeItem(widget.product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.removedfromfavorites),
          ),
        );
      } else {
        fav.addItem(widget.product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.addedtofavorites),
          ),
        );
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
      cart.addItem(widget.product!, selectedVariation);
      cart.updateQuantity(widget.product!, quantity);
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
    final fav = Provider.of<Fav>(context);
    final cart = Provider.of<Cart>(context);
    final local = Provider.of<LocaleProvider>(context);
    return Container(
      decoration: BoxDecoration(
        // shadow
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 1,
            offset: Offset(0, 0), // changes position of shadow
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.all(8.0),
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.23,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      FadeInImage(
                        image: CachedNetworkImageProvider(imageUrl),
                        placeholder: AssetImage('assets/grey_image.jpeg'),
                        height: MediaQuery.of(context).size.height * 0.18,
                        fit: BoxFit.fitWidth,
                        width: double.infinity,
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
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
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey,
                          spreadRadius: -2,
                          blurRadius: 5,
                          offset: Offset(0, 0))
                    ],
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
              Positioned(
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
              ),
            ],
          ),
          SizedBox(height: 12.0),
          Padding(
            padding: const EdgeInsets.fromLTRB(6.0, 8.0, 6.0, 8.0),
            child: Text(
              widget.product.name,
              maxLines: 2,
              textAlign: TextAlign.right,
              overflow: TextOverflow.visible,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12.0),
            ),
          ),
          Container(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6.0, 0.0, 6.0, 0.0),
              child: Text(
                '${price} ' ' ${AppLocalizations.of(context)!.egp}',
                maxLines: 2,
                textAlign: TextAlign.right,
                overflow: TextOverflow.visible,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    color: Colors.black),
              ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              width: double.infinity,
              height: 8.0,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return Container(
                    width: 8.0,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.star, size: 16, color: mainColor),
                    ),
                  );
                },
                itemCount: 5,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
              ),
            ),
          ),
          SizedBox(height: 8.0),
        ],
      ),
    );
  }
}
