import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PriceDisplay extends StatelessWidget {
  final double price;
  final double lastPrice;

  PriceDisplay({required this.price, required this.lastPrice});

  @override
  Widget build(BuildContext context) {
    // Convert the price to a string
    String priceString = price.toStringAsFixed(2);
    List<String> priceParts = priceString.split('.');

    String lastPriceString = lastPrice.toStringAsFixed(2);

    String discount = ((lastPrice - price)).toStringAsFixed(2);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        discount  == '0.00' ? Container() :
        Text(
          lastPrice.toStringAsFixed(2),

          style: const TextStyle(
            fontSize: 16,color: Colors.grey,

            decoration:
            TextDecoration.lineThrough,
            fontWeight: FontWeight.w500,
            height: 1,
            textBaseline: TextBaseline.ideographic,
            decorationColor: Colors.grey,
          ),
        ),

        SizedBox(width: 4),
        RichText(
          text: TextSpan(
            style: TextStyle(

              fontSize: priceParts .length > 3 ? 20 : 16,
              fontWeight: FontWeight.w500,
              color: Colors.black, // Color for main text
            ),
            children: [
              TextSpan(
                text: priceParts[1], // Integer part
              ),
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            style: TextStyle(

              fontSize: priceParts .length > 3 ? 20 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.black, // Color for main text
            ),
            children: [
              TextSpan(
                text: ".", // Integer part
              ),
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            style: TextStyle(

              fontSize: priceParts .length > 3 ? 20 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.black, // Color for main text
            ),
            children: [
              TextSpan(
                text: priceParts[0], // Integer part
              ),
            ],
          ),
        ),

        SizedBox(width: 3),
        SvgPicture.asset(
          "assets/SAR.svg",
          width: 20,
          height: 18
        ),


      ],
    );
  }
}

