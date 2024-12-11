// Cubit States
import '../../models/category.dart';

abstract class ChildCategoryState {}

class ChildCategoryInitial extends ChildCategoryState {}

class ChildCategoryLoading extends ChildCategoryState {}

class ChildCategoryLoaded extends ChildCategoryState {
  final List<Category> childCategories;

  ChildCategoryLoaded(this.childCategories);
}

class ChildCategoryError extends ChildCategoryState {
  final String message;

  ChildCategoryError(this.message);
}
