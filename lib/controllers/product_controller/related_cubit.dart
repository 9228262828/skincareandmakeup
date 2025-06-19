import 'package:Gomla/controllers/product_controller/related_states.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../env.dart';
import '../../models/product.dart';
import '../../providers/locale_provider.dart';

class RelatedProductCubit extends Cubit<RelatedProductState> {
  RelatedProductCubit() : super(RelatedProductInitial());
   final String baseUrl = '$siteUrl/wp-json/wc/v3';
  final String consumerKey = 'ck_d0150d53b03646e0d5695e37739777049dda22aa';
  final String consumerSecret = 'cs_bdb53e06ca06f8fcdb6510efbbbfaca708bbb3c7';


  Future<void> fetchRelatedProducts(int categoryId, BuildContext context) async {
    emit(RelatedProductLoading());
    try {
 final prefs = await SharedPreferences.getInstance();
      String? language = prefs.getString('locale') ;
      final response = await http.get(
        Uri.parse('$baseUrl/products?category=$categoryId&page=1&lang=$language'),
        headers: {
          'Authorization': 'Basic ' + base64Encode(utf8.encode('$consumerKey:$consumerSecret')),
        },
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        print(jsonResponse);
        List<Product> relatedProducts = jsonResponse.map((product) => Product.fromJson(product)).toList();
        emit(RelatedProductLoaded(relatedProducts));
      } else {
        emit(RelatedProductError('Failed to load RelatedProducts'));
      }
    } catch (error) {
      emit(RelatedProductError(error.toString()));
    }
  }
}
