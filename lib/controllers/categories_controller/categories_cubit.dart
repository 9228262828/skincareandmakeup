import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';


import '../../models/category.dart';
import '../../services/woocommerce_service.dart';
import 'categories_states.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final WooCommerceService wooCommerceService;

  CategoriesCubit(this.wooCommerceService) : super(CategoriesInitial());

  Future<void> fetchCategories(BuildContext context) async {
    print('CategoriesLoading');
    emit(CategoriesLoading(

    ));
    try {
      List<Category> categories = await wooCommerceService.fetchCategories(context);

      print('CategoriesLoaded');
      print(categories);
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }
}
