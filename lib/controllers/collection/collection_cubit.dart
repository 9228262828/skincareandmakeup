import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../env.dart'; // Make sure this has siteUrl defined
import 'collection_states.dart';
import 'package:Gomla/models/product.dart';

class CollectionCubit extends Cubit<CollectionState> {
  CollectionCubit() : super(CollectionInitial());

  static CollectionCubit get(context) => BlocProvider.of(context);

  List<Product> products = [];

  void fetchCollectionProducts( String id) async {
    emit(CollectionLoading());
    final prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('locale');
    if (language == null) {
      language = 'ar';
    }
    final String baseUrl = '$siteUrl/wp-json/wc/v3';
    final String consumerKey = 'ck_1c63c710561ce560194698e6f676fe67ee2ed927';
    final String consumerSecret = 'cs_a8ba1ef8b549189d415618ba993a4a0c6f2f7166';

    final String basicAuth = 'Basic ' + base64Encode(utf8.encode('$consumerKey:$consumerSecret'));
    final Uri url = Uri.parse('https://gomla.sa/wp-json/custom/v1/collections/$id/products?lang=$language');
print(url);
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        products = data.map((e) => Product.fromJson(e)).toList();
        print(products  );
        emit(CollectionSuccess());
      } else {
        print(response.body);
        emit(CollectionError("Failed with status code: ${response.statusCode}"));
      }
    } catch (e) {
      emit(CollectionError("Error: $e"));
    }
  }
}
