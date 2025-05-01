// collection_state.dart
abstract class CollectionState {}

class CollectionInitial extends CollectionState {}

class CollectionLoading extends CollectionState {}

class CollectionSuccess extends CollectionState {}

class CollectionError extends CollectionState {
  final String error;
  CollectionError(this.error);
}
