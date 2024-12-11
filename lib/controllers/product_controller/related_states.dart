import 'package:equatable/equatable.dart';


import '../../models/product.dart';

abstract class RelatedProductState extends Equatable {
  @override
  List<Object> get props => [];
}

class RelatedProductInitial extends RelatedProductState {}

class RelatedProductLoading extends RelatedProductState {}

class RelatedProductLoaded extends RelatedProductState {
  final List<Product> relatedProducts;

  RelatedProductLoaded(this.relatedProducts);

  @override
  List<Object> get props => [relatedProducts];
}

class RelatedProductError extends RelatedProductState {
  final String message;

  RelatedProductError(this.message);

  @override
  List<Object> get props => [message];
}
