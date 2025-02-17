import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PriceDisplay extends StatelessWidget {
  final double price;

  PriceDisplay({required this.price});

  @override
  Widget build(BuildContext context) {
    // Convert the price to a string
    String priceString = price.toStringAsFixed(2);
    List<String> priceParts = priceString.split('.');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Color for main text
            ),
            children: [
              TextSpan(
                text: priceParts[1], // Decimal part (in superscript)
                style: TextStyle(
                  fontSize: 14,
                  // Smaller font size for the decimal part
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                  // Raises the decimal part to look like a superscript
                  textBaseline: TextBaseline
                      .ideographic, // Ensure correct alignment (raise it)
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 2),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 22,
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
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Color for main text
            ),
            children: [
              TextSpan(
                text: ' ${AppLocalizations.of(context)!.egp}',
                // Decimal part (in superscript)
                style: TextStyle(
                  fontSize: 16,
                  // Smaller font size for the decimal part
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                  // Raises the decimal part to look like a superscript
                  textBaseline: TextBaseline
                      .ideographic, // Ensure correct alignment (raise it)
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LastPriceDisplay extends StatelessWidget {
  final double price;

  LastPriceDisplay({required this.price});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${AppLocalizations.of(context)!.was} : ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        SizedBox(width: 2),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
            children: [
              TextSpan(
                text: price.toStringAsFixed(2) +
                    " ${AppLocalizations.of(context)!.egp}",
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ), // Integer part
              ),
            ],
          ),
        ),
      ],
    );
  }
}
