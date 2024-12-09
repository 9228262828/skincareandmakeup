import 'package:equatable/equatable.dart';

import '../../models/product.dart';

abstract class BestDealsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BestDealsInitial extends BestDealsState {}

class BestDealsLoading extends BestDealsState {}

class BestDealsLoaded extends BestDealsState {
  final List<Product> products;

  BestDealsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class BestDealsError extends BestDealsState {
  final String error;

  BestDealsError(this.error);

  @override
  List<Object?> get props => [error];
}
