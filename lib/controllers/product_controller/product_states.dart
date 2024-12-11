
import 'package:equatable/equatable.dart';

import '../../models/brand.dart';
import '../../models/category.dart';
import '../../models/product.dart';

abstract class ProductState extends Equatable {
  final Product product;
  final int quantity;
  const ProductState({required this.product, required this.quantity});

  @override
  List<Object> get props => [product, quantity];
}

class ProductInitial extends ProductState {
  const ProductInitial({required Product product, required int quantity}) : super(product: product, quantity: quantity);
}

class ProductFavoriteAdded extends ProductState {
  const ProductFavoriteAdded({required Product product, required int quantity}) : super(product: product, quantity: quantity);
}

class ProductFavoriteRemoved extends ProductState {
  const ProductFavoriteRemoved({required Product product, required int quantity}) : super(product: product, quantity: quantity);
}

class ProductQuantityChanged extends ProductState {
  const ProductQuantityChanged({required Product product, required int quantity}) : super(product: product, quantity: quantity);
}

class ProductAddedToCart extends ProductState {
  const ProductAddedToCart({required Product product, required int quantity}) : super(product: product, quantity: quantity);
}
class ProductIsLoggedIn extends ProductState {
final bool value;
  const ProductIsLoggedIn({required Product product, required int quantity, required this.value}) : super(product: product, quantity: quantity);
}



abstract class ProductListingState {}

class ProductListingInitial extends ProductListingState {}

class ProductListingLoading extends ProductListingState {}

class ProductListingLoaded extends ProductListingState {
  final List<Product> products;
  final List<Category> categories;
  final List<Category> childCategories;
  final List<Brand> brands;
  final double? minPrice;
  final double? maxPrice;
  final bool hasReachedMax;

  ProductListingLoaded({
    required this.products,
    required this.categories,
    required this.childCategories,
    required this.brands,
    this.minPrice,
    this.maxPrice,
    required this.hasReachedMax,
  });

  ProductListingLoaded copyWith({
    List<Product>? products,
    List<Category>? categories,
    List<Category>? childCategories,
    List<Brand>? brands,
    double? minPrice,
    double? maxPrice,
    bool? isLoadingMore,
  }) {
    return ProductListingLoaded(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      childCategories: childCategories ?? this.childCategories,
      brands: brands ?? this.brands,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      hasReachedMax: hasReachedMax,
    );
  }
}

class ProductListingError extends ProductListingState {
  final String message;

  ProductListingError(this.message);
}class ProductListingEmpty extends ProductListingState {


  ProductListingEmpty();
}