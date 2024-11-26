import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skincare/contstants.dart';
import 'package:skincare/models/cart.dart';
import 'package:skincare/screens/cart_screen.dart';
import 'package:skincare/screens/search_result.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    Key? key,
    required this.title,
  }) : super(key: key);

  void _startSearch(BuildContext context) {
    showSearch(context: context, delegate: ProductSearchDelegate());
  }

  @override
  Widget build(BuildContext context) {
    // get cart count from provider
    final int cartCount = Provider.of<Cart>(context, listen: true).items.length;
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: Image.asset(
        'assets/app_icon.png',
        width: MediaQuery.of(context).size.width * 0.35,
      ),
      // centerTitle: true,
      actions: [
        GestureDetector(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.60,
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 0,
                  blurRadius: 7,
                  offset: Offset(0, 0), // changes position of shadow
                ),
              ]),
              child: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  _startSearch(context);
                },
              ),
            ),
          ),
          onTap: () {
            _startSearch(context);
          },
        ),
        // Stack(
        //   children: [
        //     Positioned(
        //       top: 0,
        //       right: 10,
        //       child: Text(
        //         cartCount.toString(),
        //         style: TextStyle(color: mainColor, fontSize: 14, fontWeight: FontWeight.bold),
        //       ),
        //     ),
        //     IconButton(
        //       icon: Icon(
        //         Icons.shopping_cart,
        //         color: Colors.black,
        //       ),
        //       onPressed: () {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(builder: (context) => CartScreen()),
        //         );
        //       },
        //     ),
        //   ],
        // ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class ProductSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    Future.microtask(() {
      close(context, query);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsScreen(query: query),
        ),
      );
    });
    return Container(); // Return an empty container to satisfy the method's requirement
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
