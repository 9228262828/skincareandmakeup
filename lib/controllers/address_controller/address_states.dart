

import '../../models/adress_model.dart';

abstract class AddressState {}

class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {}

class AddressLoaded extends AddressState {
  final List<Address> addresses;

  AddressLoaded({required this.addresses});
}

class AddressError extends AddressState {
  final String message;

  AddressError({required this.message});
}

class AddressDeleted extends AddressState {}
