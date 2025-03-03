import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/product.dart';
import '../../services/woocommerce_service.dart';
import 'best_deals_states.dart';

class BestDealsCubit extends Cubit<BestDealsState> {
  final WooCommerceService wooCommerceService;

  BestDealsCubit(this.wooCommerceService) : super(BestDealsInitial());

  Future<void> fetchBestDeals(BuildContext context,int id) async {
    emit(BestDealsLoading());
    try {
      List<Product> products = await wooCommerceService.fetchProducts(id, 1, context);
      print("best deals");
      print(products);
      emit(BestDealsLoaded(products));
    } catch (e) {
      emit(BestDealsError(e.toString()));
    }
  }


  Future<void> fetchBestDeals1(BuildContext context, String url) async {
    emit(BestDealsLoading());
    try {
      List<Product> products = await wooCommerceService.fetchProductsBest(context, url);
      print("Fetched products: $products");

      if (products.isEmpty) {
        emit(BestDealsError("No products found"));
      } else {
        emit(BestDealsLoaded(products));
      }
    } catch (e) {
      emit(BestDealsError(e.toString()));
    }
  }
}
