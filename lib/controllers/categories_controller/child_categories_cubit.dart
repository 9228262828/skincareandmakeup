import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/category.dart';
import '../../services/woocommerce_service.dart';
import 'child_categories_states.dart';

class ChildCategoryCubit extends Cubit<ChildCategoryState> {
  final WooCommerceService wooCommerceService;

  ChildCategoryCubit(this.wooCommerceService) : super(ChildCategoryInitial());

  Future<void> fetchChildCategories(BuildContext context, int parentId) async {
    emit(ChildCategoryLoading());

    try {
      List<Category> childCategories = await wooCommerceService.fetchChildCategories(parentId, context);
      emit(ChildCategoryLoaded(childCategories));
    } catch (e) {
      emit(ChildCategoryError(e.toString()));
    }
  }
}
