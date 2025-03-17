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
              fontWeight: FontWeight.w500,
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
              fontWeight: FontWeight.w500,
              color: Colors.black, // Color for main text
            ),
            children: [
              TextSpan(
                text: priceParts[0], // Integer part
              ),
            ],
          ),
        ),

        SizedBox(width: 2),
        SvgPicture.asset(
          "assets/SAR.svg",
          width: 20,
          height: 18
        ),
        SizedBox(width: 2),

      /*  RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Color for main text
            ),
            children: [
            *//*  TextSpan(
                text: ' ${AppLocalizations.of(context)!.egp}',
                // Decimal part (in superscript)
                style: TextStyle(
                  fontSize: 14,
                  // Smaller font size for the decimal part
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                  // Raises the decimal part to look like a superscript
                  textBaseline: TextBaseline
                      .ideographic, // Ensure correct alignment (raise it)
                ),
              ),*//*
            ],
          ),
        ),*/
        SizedBox(width: 2),
        discount  == '0.00' ? Container() :
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Color for main text
            ),
            children: [
              TextSpan(
                text:"${AppLocalizations.of(context)!.save} $discount",
                style: const TextStyle(
                  fontSize: 12,color: Colors.green,
                  fontWeight: FontWeight.w600,
                  height: 1,
                  textBaseline: TextBaseline
                      .ideographic,
                ),
              ),

             /* TextSpan(
                text: ' ${AppLocalizations.of(context)!.egp}',
                style: const TextStyle(
                  fontSize: 10,color: Colors.green,
                  fontWeight: FontWeight.w600,
                  height: 1,
                  textBaseline: TextBaseline
                      .ideographic,
                ),
              ),*/
            ],
          ),
        ),  SvgPicture.asset(
            "assets/SAR.svg",
            width: 20,
            height: 12,
          color: Colors.green,
        ),

      ],
    );
  }
}

