import 'package:Gomla/contstants.dart';
import 'package:Gomla/screens/fav_screen.dart';
import 'package:Gomla/shared/utils/app_values.dart';
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

  Future<bool> _hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }

  void _startSearch(BuildContext context) {
    showSearch(context: context, delegate: ProductSearchDelegate());
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      leading: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Image(
              image: AssetImage('assets/app_icon.png'),
              width: MediaQuery.of(context).size.width * 0.22,
              height: MediaQuery.of(context).size.height * 0.1,
              fit: BoxFit.contain,
            ),
          ),
    FutureBuilder<bool>(
      future:   _hasToken(),
          builder: (context, snapshot) => GestureDetector(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                width:  (snapshot.connectionState == ConnectionState.done &&
    snapshot.data == true)
                    ? MediaQuery.of(context).size.width * 0.62
                    : MediaQuery.of(context).size.width * 0.71,
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: Colors.grey, width: .5)),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Text(AppLocalizations.of(context)!.searchForWhat,
                          style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              _startSearch(context);
            },
          ),
          ),
          FutureBuilder<bool>(
            future: _hasToken(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data == true) {
                return Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FavScreen()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.favorite_border,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return const SizedBox(
                  width: 0,
                ); // ✅ عدم عرض الأيقونة لو مفيش توكن
              }
            },
          )
        ],
      ),
      leadingWidth: mediaQueryWidth(context) ,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
class CustomPagesAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool home;

  const CustomPagesAppBar({
    Key? key,
    required this.title,
    required this.home,
  }) : super(key: key);

  Future<bool> _hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }

  void _startSearch(BuildContext context) {
    showSearch(context: context, delegate: ProductSearchDelegate());
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      leading: Row(
        children: [
          GestureDetector(
              onTap:  () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.only( left:0.0, right: 8.0),
                child: Icon(Icons.arrow_back_ios, color:mainColor, size: 25),
              )),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Image(
              image: AssetImage('assets/app_icon.png'),
              width: MediaQuery.of(context).size.width * 0.22,
              height: MediaQuery.of(context).size.height * 0.1,
              fit: BoxFit.contain,
            ),
          ),
    FutureBuilder<bool>(
      future:   _hasToken(),
          builder: (context, snapshot) => GestureDetector(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                width:  (snapshot.connectionState == ConnectionState.done &&
    snapshot.data == true)
                    ? MediaQuery.of(context).size.width * 0.52
                    : MediaQuery.of(context).size.width * 0.61,
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: Colors.grey, width: .5)),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Text(AppLocalizations.of(context)!.searchForWhat,
                          style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              _startSearch(context);
            },
          ),
          ),
          FutureBuilder<bool>(
            future: _hasToken(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data == true) {
                return Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FavScreen()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.favorite_border,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return const SizedBox(
                  width: 0,
                ); // ✅ عدم عرض الأيقونة لو مفيش توكن
              }
            },
          )
        ],
      ),
      leadingWidth: mediaQueryWidth(context) ,
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
