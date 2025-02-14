import 'package:equatable/equatable.dart';

import '../../models/brand.dart';
import '../../models/product.dart';




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
