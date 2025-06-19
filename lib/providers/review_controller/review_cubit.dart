import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../models/review_model.dart';
import 'review_states.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  ReviewBloc() : super(ReviewInitial()) {
    on<FetchReviews>(_onFetchReviews);
  }

  Future<void> _onFetchReviews(FetchReviews event, Emitter<ReviewState> emit) async {
    final String consumerKey = 'ck_d0150d53b03646e0d5695e37739777049dda22aa';
    final String consumerSecret = 'cs_bdb53e06ca06f8fcdb6510efbbbfaca708bbb3c7';
    emit(ReviewLoading());
    try {
      final response = await http.get(Uri.parse(
          'https://gomla.egymetrix.net/wp-json/wc/v3/products/reviews?product=${event.productId}')
        ,headers: {
        'Authorization': 'Basic ' +
        base64Encode(utf8.encode('$consumerKey:$consumerSecret')),
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print("data");
        print(data);
        print("data");
        List<Review> reviews = data.map((json) => Review.fromJson(json)).toList();
        print('reviews');
        print(reviews);
        emit(ReviewLoaded(reviews));
      } else {
        emit(ReviewError('Failed to load reviews'));
      }
    } catch (e) {
      emit(ReviewError('An error occurred: $e'));
      print('Error fetching reviews: $e'); // Log the error for debugging
    }
  }
}