import 'package:equatable/equatable.dart';

import '../../models/brand.dart';
import '../../models/product.dart';

abstract class BrandsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BrandsInitial extends BrandsState {}

class BrandsLoading extends BrandsState {}

class BrandsLoaded extends BrandsState {
  final List<Brand> brands;

  BrandsLoaded(this.brands);

  @override
  List<Object?> get props => [brands];
}

class BrandsError extends BrandsState {
  final String error;

  BrandsError(this.error);

  @override
  List<Object?> get props => [error];
}

abstract class ProductsState {}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {
  final int page;
  ProductsLoading({required this.page});
}

class ProductsLoaded extends ProductsState {
  final List<Product> Productss;
  final int page;
  final bool hasReachedMax;

  ProductsLoaded({
    required this.Productss,
    required this.page,
    required this.hasReachedMax,
  });
}

class ProductsError extends ProductsState {
  final String message;

  ProductsError({required this.message});
}
