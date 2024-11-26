import 'package:flutter/material.dart';
import 'package:skincare/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import '../services/woocommerce_service.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import 'product_screen.dart';
import 'cart_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({Key? key, required this.query}) : super(key: key);

  @override
  _SearchResultsScreenState createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late WooCommerceService wooCommerceService;
  List<Product> products = [];
  int page = 1;
  bool isLoading = false;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    wooCommerceService = WooCommerceService();
    searchProducts();
  }

  Future<void> searchProducts() async {
    if (isLoading || isLastPage) return;
    setState(() {
      isLoading = true;
    });

    try {
      List<Product> newProducts = await wooCommerceService.searchProducts(widget.query, page, context);
      if (!mounted) return; // Check if the widget is still mounted
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
      if (!mounted) return; // Check if the widget is still mounted
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context)!.searchResults),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!isLoading && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            searchProducts();
          }
          return true;
        },
        child: GridView.builder(
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
              child: ProductCard(product: products[index]),
            );
          },
        ),
      ),
    );
  }
}
