import 'package:Gomla/contstants.dart';
import 'package:Gomla/screens/fav_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart.dart';
import '../screens/search_result.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool home;

  const CustomAppBar({
    Key? key,
    required this.title,
    required this.home,
  }) : super(key: key);

  void _startSearch(BuildContext context) {
    showSearch(context: context, delegate: ProductSearchDelegate());
  }
  tokenFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs.getString('auth_token'));
    return prefs.getString('auth_token');
  }

  @override
  Widget build(BuildContext context) {
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
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: Colors.grey, width: .5)),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(AppLocalizations.of(context)!.searchForWhat,
                        style: TextStyle(color: Colors.black)),
                  ),
                  Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: mainColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _startSearch(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            _startSearch(context);
          },
        ),
        tokenFromSharedPreferences() == null ? Container() :  IconButton(
          icon: const Icon(
            Icons.favorite_border,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FavScreen()),
            );
          },
        ),
      ],

      leading: home
          ? null
          : IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded, color:mainColor),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
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
