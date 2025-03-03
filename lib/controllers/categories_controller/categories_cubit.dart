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
      List<Category> categories = await wooCommerceService.fetchCategories();

      print('CategoriesLoaded');
      print(categories);
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }
}



class MainCategoriesCubit extends Cubit<MainCategoriesState> {
  final WooCommerceService wooCommerceService;

  MainCategoriesCubit(this.wooCommerceService) : super(MainCategoriesInitial());

  Future<void> fetchMainCategories() async {
    emit(MainCategoriesLoading());
    try {
      List<Category> mainCategories = await wooCommerceService.fetchCategories();
      emit(MainCategoriesLoaded(mainCategories));
    } catch (e) {
      emit(MainCategoriesError(e.toString()));
    }
  }

  Future<void> fetchSubCategories(int parentId) async {
    emit(SubCategoriesLoading(parentId));
    try {
      List<Category> subCategories = await wooCommerceService.fetchSubCategories(parentId);
      emit(SubCategoriesLoaded(parentId, subCategories));
    } catch (e) {
      emit(SubCategoriesError(parentId, e.toString()));
    }
  }
}
