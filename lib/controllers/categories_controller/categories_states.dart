import 'package:equatable/equatable.dart';

import '../../models/category.dart';

abstract class CategoriesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CategoriesInitial extends CategoriesState {}

class CategoriesLoading extends CategoriesState {}

class CategoriesLoaded extends CategoriesState {
  final List<Category> categories;

  CategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class CategoriesError extends CategoriesState {
  final String error;

  CategoriesError(this.error);

  @override
  List<Object?> get props => [error];
}



//

abstract class MainCategoriesState {}

class MainCategoriesInitial extends MainCategoriesState {}

class MainCategoriesLoading extends MainCategoriesState {}

class MainCategoriesLoaded extends MainCategoriesState {
  final List<Category> categories;

  MainCategoriesLoaded(this.categories);
}

class MainCategoriesError extends MainCategoriesState {
  final String error;

  MainCategoriesError(this.error);
}

class SubCategoriesLoading extends MainCategoriesState {
  final int parentId;

  SubCategoriesLoading(this.parentId);
}

class SubCategoriesLoaded extends MainCategoriesState {
  final int parentId;
  final List<Category> subCategories;

  SubCategoriesLoaded(this.parentId, this.subCategories);
}

class SubCategoriesError extends MainCategoriesState {
  final int parentId;
  final String error;

  SubCategoriesError(this.parentId, this.error);
}
