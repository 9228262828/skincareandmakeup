import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PriceDisplay extends StatefulWidget {
  final double price;
  final double lastPrice;

  PriceDisplay({required this.price, required this.lastPrice});

  @override
  State<PriceDisplay> createState() => _PriceDisplayState();
}

class _PriceDisplayState extends State<PriceDisplay> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadLanguagePreference();
  }
  String languageCode = 'en'; // Default language

  Future<void> _loadLanguagePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      languageCode =
          prefs.getString('language_code') ?? 'en'; // Default to English
    });
  }

  @override
  Widget build(BuildContext context) {

     // Convert the price to a string
    String priceString = widget.price.toStringAsFixed(2);
    List<String> priceParts = priceString.split('.');

    String lastPriceString = widget.lastPrice.toStringAsFixed(2);

    String discount = ((widget.lastPrice - widget.price)).toStringAsFixed(2);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        discount  == '0.00' ? Container() :
        Text(
          widget.lastPrice.toStringAsFixed(2),

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
        Text(
          priceString,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w600,
            height: 1,
            textBaseline: TextBaseline.ideographic,
          ),
        ),

        SizedBox(width: 3),
        SvgPicture.asset(
          "assets/SAR.svg",
          width: 16,
          height: 16,
          color: Colors.black,
        ),


      ],
    );
  }
}

