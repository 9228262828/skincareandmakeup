import 'package:Gomla/contstants.dart';
import 'package:flutter/material.dart';

import '../shared/utils/app_values.dart';
import '../widgets/price^.dart';
import '../widgets/product_review_widget.dart';
import 'models.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DTreatmentCard extends StatefulWidget {
  final ProductDetails details;
  final Function(ProductDetails, bool) onSelected;

  const DTreatmentCard({
    Key? key,
    required this.details,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<DTreatmentCard> createState() => _DTreatmentCardState();
}

class _DTreatmentCardState extends State<DTreatmentCard> {
  bool isSelected = true;

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = Localizations.localeOf(context);
    final product = (currentLocale.languageCode == 'ar')
        ? widget.details.ar ?? widget.details.en
        : widget.details.en ?? widget.details.ar;

    if (product == null) return const SizedBox(); // تأمين

    double regularPrice = double.tryParse(product.regularPrice?.toString() ?? '0') ?? 0.0;
    double discountedPrice = double.tryParse(product.salePrice?.toString() ?? '0') ?? 0.0;
    if (discountedPrice == 0.0) {
      discountedPrice = double.tryParse(product.price?.toString() ?? '0') ?? 0.0;
    }

    double discountPercent = 0.0;
    if (regularPrice > 0) {
      discountPercent = ((regularPrice - discountedPrice) / regularPrice) * 100;
    }

    return Container(
      decoration: BoxDecoration(
        // shadow
        border: Border.all(color: Colors.grey, width: .1),
        color:  Colors.white,
        borderRadius: BorderRadius.circular(3.0),
      ),
      padding: const EdgeInsets.all(4.0),
      height: MediaQuery.of(context).size.height * 0.1,
      width:  MediaQuery.of(context).size.width * 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.248,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      //  fakeProduct == "fake"? SizedBox(height: 10):
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        child: Image.network(
                          product.getImageUrl(),
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset('assets/placeholder.png', height: 150, width: double.infinity, fit: BoxFit.cover),
                        ),
                      ),


                    ],
                  ),
                ),
              ),
              discountPercent == 0
                  ? Container()
                  :
              currentLocale == Locale('ar')?      Positioned(
                bottom: 0,
                right: 0,

                child: Container(
                  width: mediaQueryWidth(context) * 0.21,
                  height: mediaQueryWidth(context) * 0.07,
                  decoration: BoxDecoration(
                    color: Color(0xffcb0d39),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.grey,
                          spreadRadius: -2,
                          blurRadius: 5,
                          offset: Offset(0, 0))
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "${AppLocalizations.of(context)!.off}  ${discountPercent.toStringAsFixed(2)}%",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12),
                    ),
                  ),
                ),
              ):
              Positioned(
                bottom: 0,
                left: 0,

                child: Container(
                  width: mediaQueryWidth(context) * 0.21,

                  height: mediaQueryWidth(context) * 0.07,
                  decoration: BoxDecoration(
                    color: Color(0xffcb0d39),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.grey,
                          spreadRadius: -2,
                          blurRadius: 5,
                          offset: Offset(0, 0))
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "${discountPercent.toStringAsFixed(2)}% ${AppLocalizations.of(context)!.off} ",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                left: 8,
                child: Checkbox(
                   focusColor:   mainColor,
                  hoverColor:   mainColor,
                  checkColor: Colors.white,
                  activeColor: mainColor,
                  shape:  RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
                  side:   BorderSide(width: 2, color: mainColor),

                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      isSelected = value ?? false;
                      widget.onSelected(widget.details, isSelected);
                    });
                  },
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
                      borderRadius: BorderRadius.circular(3.0),
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
                          borderRadius: BorderRadius.circular(3.0),
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
                      borderRadius: BorderRadius.circular(3.0),
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

          SizedBox(height: 10 ),

          PriceDisplay(
            price: discountedPrice,
            lastPrice: regularPrice,
          ),
          SizedBox(height: 10 ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 2.0,
            ),
            child: Text(
              product.name ?? '',
              maxLines: 2,
              overflow: TextOverflow.visible,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.0),
            ),
          ),
          SizedBox(height: 10 ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: buildRatingIcons(double.parse(4.5
            .toString())), // Helper function to build star icons
          ),
          /*if (isSelected)
            Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: () {
                  // Add to cart functionality here
                  print('Added to cart: ${product.name}');
                },
                child: const Text('Add to Cart'),
              ),
            ),*/
        ],
      ),
    );
  }
}
