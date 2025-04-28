import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../contstants.dart';
import '../services/woocommerce_service.dart';
import '../models/product.dart';
import '../shared/utils/app_values.dart';
 import '../widgets/product_card.dart';
import 'product_screen.dart';
 import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({Key? key}) : super(key: key);

  @override
  _SearchResultsScreenState createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late WooCommerceService wooCommerceService;
  final TextEditingController _searchController = TextEditingController();

  List<Product> products = [];
  List<String> suggestions = [];  // List to hold suggestion words
  int page = 1;
  bool isLoading = false;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    wooCommerceService = WooCommerceService();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xFF212224), // Black/dark color
      statusBarIconBrightness: Brightness.dark, // Light icons (for dark background)
    ));
  }

  Future<void> searchProducts() async {
    if (isLoading || isLastPage) return;
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      List<Product> newProducts = await wooCommerceService.searchProducts(
        _searchController.text.trim(),
        page,
        context,
      );
      if (!mounted) return;
      setState(() {
        products.addAll(newProducts);
        if (newProducts.length < 10) {
          isLastPage = true;
        }
        page++;
      });
    } catch (e) {
      print(e);
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        suggestions.clear();
      });
      return;
    }

    try {
      // Call your API or service to get the suggestions based on the query
      List<Product> suggestedWords = await wooCommerceService.searchProducts(query, 1, context);
      setState(() {
        suggestions = suggestedWords.map((product) => product.name).toList();
      });
    } catch (e) {
      print(e);
    }
  }

  void onSearch() {
    setState(() {
      products.clear();
      suggestions.clear(); // Clear suggestions when search is submitted
      page = 1;
      isLastPage = false;
    });
    searchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
              color: Color(0xFF212224),
              height: mediaQueryHeight(context) * 0.05),
          SizedBox(
            height: mediaQueryHeight(context) * 0.095,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: mainColor,
                        size: 25,
                      ),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _searchController,
                      style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.normal
                      ),
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.searchProducts,
                        fillColor: Colors.grey[200],
                        label: Text(AppLocalizations.of(context)!.searchProducts),
                        labelStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: mainColor),
                          gapPadding: 10,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                              color: Color(0xFFEAEAEA),
                              width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                              color: Color(0xFFEAEAEA).withOpacity(.8),
                              width: 1),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                              color: Colors.red,
                              width: 1),
                        ),
                        errorStyle: TextStyle(fontSize: 12),
                        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        ),
                      ),
                      onChanged: (query) {
                        getSuggestions(query);  // Get suggestions as the user types
                      },
                      onFieldSubmitted: (_) => onSearch(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      onSearch();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: mainColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.search,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (suggestions.isNotEmpty)
            Container(
              height: mediaQueryHeight(context) * 0.25,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: ListView.builder(
                padding: const EdgeInsets.all(2),
                shrinkWrap: true,
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _searchController.text = suggestions[index];
                          onSearch();  // Clear suggestions and search
                        },
                        child: Text(suggestions[index], style: const TextStyle(color: Colors.black)),
                      ),
                      const Divider(
                        color: Color(0xFFEAEAEA),
                      ),
                    ],
                  );
                },
              ),
            ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!isLoading && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                  searchProducts();
                }
                return true;
              },
              child: products.isEmpty
                  ? Center(
                child: isLoading
                    ? CircularProgressIndicator(color: mainColor)
                    : Text(AppLocalizations.of(context)!.noProductsFound),
              )
                  : GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.50,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductScreen(
                            productId: products[index].id,
                          ),
                        ),
                      );
                    },
                    child: ProductCard(
                      product: products[index],
                      fakeProduct: "",
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
